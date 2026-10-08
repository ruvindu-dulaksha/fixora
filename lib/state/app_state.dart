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
    await _createDemoAccountIfNeeded();
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
    await _addDemoBookingIfNeeded();
    categories = await repository.fetchCategories();
    notifyListeners();
  }

  Future<void> _createDemoAccountIfNeeded() async {
    final accounts = _readAccounts();
    if (accounts.isNotEmpty) return;

    await box.putAll({
      'userName': 'Ruvindu',
      'userEmail': 'ruvindu@gmail.com',
      'userPassword': 'dulaksha',
      'authenticated': 'false',
      'accounts': jsonEncode([
        {
          'name': 'Ruvindu',
          'email': 'ruvindu@gmail.com',
          'password': 'dulaksha',
        },
      ]),
    });
  }

  List<Map<String, String>> _readAccounts() {
    final raw = box.get('accounts');
    if (raw == null) {
      final email = box.get('userEmail');
      final password = box.get('userPassword');
      if (email == null ||
          email.isEmpty ||
          password == null ||
          password.isEmpty) {
        return [];
      }
      return [
        {
          'name': box.get('userName') ?? '',
          'email': email,
          'password': password,
        },
      ];
    }
    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((item) => Map<String, String>.from(item as Map))
        .toList();
  }

  Future<void> _saveAccounts(List<Map<String, String>> accounts) =>
      box.put('accounts', jsonEncode(accounts));

  Map<String, String>? _accountForEmail(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    for (final account in _readAccounts()) {
      if (account['email']!.toLowerCase() == normalizedEmail) return account;
    }
    return null;
  }

  Future<void> _addDemoBookingIfNeeded() async {
    final demo = switch (userEmail.toLowerCase()) {
      'ruvindu1@gmail.com' => (
        id: 'FX-DEMO-RUVINDU1',
        providerId: 'p002',
        providerName: 'Nuwan Silva',
        category: 'electrical',
        description: 'Install and check the living room lights.',
        total: 6500,
      ),
      'ruvindu2@gmail.com' => (
        id: 'FX-DEMO-RUVINDU2',
        providerId: 'p001',
        providerName: 'Kamal Perera',
        category: 'plumbing',
        description: 'Repair a leaking kitchen pipe.',
        total: 5500,
      ),
      _ => null,
    };
    if (demo == null || bookings.any((booking) => booking.id == demo.id)) {
      return;
    }

    var bookingDate = DateTime.now().add(const Duration(days: 2));
    while (bookingDate.weekday == DateTime.sunday) {
      bookingDate = bookingDate.add(const Duration(days: 1));
    }

    final booking = Booking(
      id: demo.id,
      providerId: demo.providerId,
      providerName: demo.providerName,
      category: demo.category,
      date: bookingDate,
      slot: '10 AM–12 PM',
      customerName: userName.isEmpty ? 'Ruvindu' : userName,
      phone: '0712345678',
      address: 'Colombo',
      hours: 2,
      description: demo.description,
      total: demo.total,
      status: BookingStatus.confirmed,
    );
    bookings = [...bookings, booking];
    await _saveBookings();
  }

  Future<void> completeOnboarding() async {
    hasSeenOnboarding = true;
    await box.put('onboardingSeen', 'true');
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final account = _accountForEmail(email);
    if (account == null || account['password'] != password) {
      return false;
    }
    userEmail = account['email']!;
    userPassword = account['password']!;
    userName = account['name']!;
    isAuthenticated = true;
    await box.putAll({
      'authenticated': 'true',
      'userName': userName,
      'userEmail': userEmail,
      'userPassword': userPassword,
    });
    await _addDemoBookingIfNeeded();
    notifyListeners();
    return true;
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final accounts = _readAccounts();
    if (_accountForEmail(email) != null) {
      return false;
    }
    final account = {
      'name': name.trim(),
      'email': email.trim(),
      'password': password,
    };
    await _saveAccounts([...accounts, account]);
    userName = account['name']!;
    userEmail = account['email']!;
    userPassword = account['password']!;
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
    final accounts = _readAccounts();
    final current = _accountForEmail(userEmail);
    if (current != null) {
      current['name'] = name;
      current['email'] = email;
      await _saveAccounts(accounts);
    }
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
    final accounts = _readAccounts();
    final current = _accountForEmail(userEmail);
    if (current != null) {
      current['password'] = newPassword;
      await _saveAccounts(accounts);
    }
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
