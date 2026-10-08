import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/provider_repository.dart';
import '../models/booking.dart';
import '../models/provider.dart';
import '../utils/booking_rules.dart';

class AppState extends ChangeNotifier {
  AppState(this.repository, this.box);
  final ProviderRepository repository;
  final Box<String> box;
  ThemeMode themeMode = ThemeMode.system;
  bool isAuthenticated = false;
  bool hasSeenOnboarding = false;
  bool isProviderMode = false;
  String userName = '';
  String userEmail = '';
  String userPassword = '';
  String? profileImageBase64;
  List<ServiceCategory> categories = [];
  List<ProviderProfile> providers = [];
  List<Booking> bookings = [];

  Future<void> initialize() async {
    isAuthenticated = box.get('authenticated') == 'true';
    hasSeenOnboarding = box.get('onboardingSeen') == 'true';
    isProviderMode = box.get('providerMode') == 'true';
    userName = box.get('userName') ?? '';
    userEmail = box.get('userEmail') ?? '';
    userPassword = box.get('userPassword') ?? '';
    profileImageBase64 = box.get('profileImage');
    final savedTheme = box.get('theme');
    themeMode = savedTheme == ThemeMode.dark.name
        ? ThemeMode.dark
        : ThemeMode.light;
    final raw = box.get('bookings');
    if (raw != null) {
      bookings = (jsonDecode(raw) as List)
          .map((e) => Booking.fromJson(e))
          .toList();
    }
    categories = await repository.fetchCategories();
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    hasSeenOnboarding = true;
    await box.put('onboardingSeen', 'true');
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final savedEmail = box.get('userEmail') ?? '';
    final savedPassword = box.get('userPassword') ?? '';
    if (savedEmail.isEmpty ||
        savedPassword.isEmpty ||
        savedEmail.toLowerCase() != email.trim().toLowerCase() ||
        savedPassword != password) {
      return false;
    }
    userEmail = savedEmail;
    userPassword = savedPassword;
    userName = box.get('userName') ?? '';
    isAuthenticated = true;
    await box.putAll({'authenticated': 'true'});
    notifyListeners();
    return true;
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final savedEmail = box.get('userEmail');
    if (savedEmail != null &&
        savedEmail.isNotEmpty &&
        savedEmail.toLowerCase() == email.trim().toLowerCase() &&
        (box.get('userPassword') ?? '').isNotEmpty) {
      return false;
    }
    userName = name.trim();
    userEmail = email.trim();
    userPassword = password;
    isAuthenticated = true;
    await box.putAll({
      'authenticated': 'true',
      'userName': userName,
      'userEmail': userEmail,
      'userPassword': userPassword,
    });
    notifyListeners();
    return true;
  }

  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    userName = name;
    userEmail = email;
    await box.putAll({'userName': name, 'userEmail': email});
    notifyListeners();
  }

  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (currentPassword != userPassword ||
        newPassword.trim().length < 6 ||
        newPassword == currentPassword) {
      return false;
    }
    userPassword = newPassword;
    await box.put('userPassword', newPassword);
    notifyListeners();
    return true;
  }

  Future<void> updateProfileImage(String? base64Image) async {
    profileImageBase64 = base64Image;
    if (base64Image == null) {
      await box.delete('profileImage');
    } else {
      await box.put('profileImage', base64Image);
    }
    notifyListeners();
  }

  Future<void> logout() async {
    isAuthenticated = false;
    isProviderMode = false;
    await box.put('authenticated', 'false');
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    await setThemeMode(
      themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    await box.put('theme', themeMode.name);
    notifyListeners();
  }

  Future<void> toggleMode() async {
    isProviderMode = !isProviderMode;
    await box.put('providerMode', isProviderMode.toString());
    notifyListeners();
  }

  Future<List<ProviderProfile>> loadProviders({
    int page = 1,
    String? categoryId,
    String query = '',
  }) async => repository.fetchProviders(
    page: page,
    categoryId: categoryId,
    query: query,
  );

  bool isSlotFree(String providerId, DateTime date, String slot) =>
      isAvailableSlot(bookings, providerId, date, slot);

  Future<void> addBooking(Booking booking) async {
    if (!isSlotFree(booking.providerId, booking.date, booking.slot)) {
      throw StateError('This time slot is no longer available.');
    }
    bookings = [...bookings, booking];
    await _saveBookings();
    notifyListeners();
  }

  Future<void> updateBooking(String id, BookingStatus status) async {
    final index = bookings.indexWhere((booking) => booking.id == id);
    if (index < 0) return;
    final action = switch (status) {
      BookingStatus.confirmed => 'accept',
      BookingStatus.rejected => 'reject',
      BookingStatus.inProgress => 'start',
      BookingStatus.completed => 'complete',
      BookingStatus.cancelled => 'cancel',
      _ => '',
    };
    final current = bookings[index].status;
    if (action == 'cancel' &&
        ![BookingStatus.pending, BookingStatus.confirmed].contains(current)) {
      throw StateError('This booking cannot be cancelled.');
    }
    final next = action == 'cancel'
        ? BookingStatus.cancelled
        : nextStatus(current, action);
    if (next == null) {
      throw StateError('This status transition is not allowed.');
    }
    final updated = [...bookings];
    updated[index] = bookings[index].copyWith(status: next);
    bookings = updated;
    await _saveBookings();
    notifyListeners();
  }

  Future<void> _saveBookings() =>
      box.put('bookings', jsonEncode(bookings.map((e) => e.toJson()).toList()));
}
