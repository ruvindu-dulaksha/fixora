import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/provider.dart';
import '../state/app_state.dart';
import 'provider_detail_page.dart';

class ProviderListPage extends StatefulWidget {
  const ProviderListPage({super.key, this.categoryId, this.query = ''});
  final String? categoryId;
  final String query;
  @override
  State<ProviderListPage> createState() => _ProviderListPageState();
}

class _ProviderListPageState extends State<ProviderListPage> {
  late Future<List<ProviderProfile>> future;
  @override
  void initState() {
    super.initState();
    future = context.read<AppState>().loadProviders(
      categoryId: widget.categoryId,
      query: widget.query,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Find a professional')),
    body: FutureBuilder<List<ProviderProfile>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: FilledButton(
              onPressed: () => setState(
                () => future = context.read<AppState>().loadProviders(
                  categoryId: widget.categoryId,
                  query: widget.query,
                ),
              ),
              child: const Text('Retry'),
            ),
          );
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const Center(child: Text('No professionals found'));
        }
        return RefreshIndicator(
          onRefresh: () async => setState(
            () => future = context.read<AppState>().loadProviders(
              categoryId: widget.categoryId,
              query: widget.query,
            ),
          ),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final provider = items[index];
              final category = context.read<AppState>().categories.firstWhere(
                (item) => item.id == provider.categoryId,
              );
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.handyman,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    provider.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${category.name}  •  ${provider.location}\n★ ${provider.rating}   LKR ${provider.hourlyRate}/hr',
                    ),
                  ),
                  trailing: Chip(
                    label: Text(provider.isAvailable ? 'Available' : 'Busy'),
                    backgroundColor: provider.isAvailable
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProviderDetailPage(provider: provider),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    ),
  );
}
