import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/provider.dart';

abstract class ProviderRepository {
  Future<List<ProviderProfile>> fetchProviders({
    required int page,
    String? categoryId,
    String query = '',
  });
  Future<List<ServiceCategory>> fetchCategories();
}

class AssetProviderRepository implements ProviderRepository {
  List<ProviderProfile>? _providers;
  Future<void> _load() async {
    if (_providers != null) return;
    final raw = await rootBundle.loadString('assets/data/providers.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    _providers = (data['providers'] as List)
        .map((item) => ProviderProfile.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ServiceCategory>> fetchCategories() async {
    await _load();
    return const [
      ServiceCategory(id: 'plumbing', name: 'Plumbing'),
      ServiceCategory(id: 'electrical', name: 'Electrical'),
      ServiceCategory(id: 'carpentry', name: 'Carpentry'),
      ServiceCategory(id: 'painting', name: 'Painting'),
      ServiceCategory(id: 'ac_repair', name: 'AC Repair'),
      ServiceCategory(id: 'cleaning', name: 'Cleaning'),
    ];
  }

  @override
  Future<List<ProviderProfile>> fetchProviders({
    required int page,
    String? categoryId,
    String query = '',
  }) async {
    await Future<void>.delayed(Duration(milliseconds: 800 + Random().nextInt(700)));
    await _load();
    final lower = query.toLowerCase();
    final filtered = _providers!.where((provider) {
      final categoryMatches = categoryId == null || provider.categoryId == categoryId;
      final queryMatches = lower.isEmpty ||
          provider.name.toLowerCase().contains(lower) ||
          provider.skills.any((skill) => skill.toLowerCase().contains(lower));
      return categoryMatches && queryMatches;
    }).toList();
    final start = (page - 1) * 10;
    if (start >= filtered.length) return [];
    return filtered.sublist(start, min(start + 10, filtered.length));
  }
}
