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
  final scrollController = ScrollController();
  final providers = <ProviderProfile>[];
  Future<List<ProviderProfile>>? future;
  Object? nextPageError;
  bool isLoadingNextPage = false;
  bool hasMore = true;
  int nextPage = 1;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
    _loadFirstPage();
  }

  @override
  void dispose() {
    scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (scrollController.position.extentAfter < 300) {
      _loadNextPage();
    }
  }

  void _loadFirstPage() {
    providers.clear();
    nextPageError = null;
    hasMore = true;
    nextPage = 1;
    future = _fetchPage(1);
  }

  Future<List<ProviderProfile>> _fetchPage(int page) async {
    final result = await context.read<AppState>().loadProviders(
      page: page,
      categoryId: widget.categoryId,
      query: widget.query,
    );
    if (!mounted) return result;
    setState(() {
      providers.addAll(result);
      nextPage = page + 1;
      hasMore = result.isNotEmpty;
    });
    return result;
  }

  Future<void> _loadNextPage() async {
    if (isLoadingNextPage || !hasMore || nextPageError != null) return;
    setState(() {
      isLoadingNextPage = true;
    });
    try {
      await _fetchPage(nextPage);
    } catch (error) {
      if (mounted) {
        setState(() {
          nextPageError = error;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoadingNextPage = false;
        });
      }
    }
  }

  Future<void> _retryNextPage() async {
    setState(() {
      nextPageError = null;
    });
    await _loadNextPage();
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
              onPressed: () => setState(_loadFirstPage),
              child: const Text('Retry'),
            ),
          );
        }
        if (providers.isEmpty) {
          return const Center(child: Text('No professionals found'));
        }
        return RefreshIndicator(
          onRefresh: () async {
            setState(_loadFirstPage);
            await future;
          },
          child: ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: providers.length + 1,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == providers.length) {
                if (nextPageError != null) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Could not load more providers.'),
                      TextButton(
                        onPressed: _retryNextPage,
                        child: const Text('Retry'),
                      ),
                    ],
                  );
                }
                if (isLoadingNextPage) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return const SizedBox(height: 12);
              }
              final provider = providers[index];
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
