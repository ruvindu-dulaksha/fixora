import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import 'provider_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final searchController = TextEditingController();
  @override
  void dispose() { searchController.dispose(); super.dispose(); }
  void openList({String? categoryId}) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProviderListPage(categoryId: categoryId, query: searchController.text)));

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Good day, ${state.userName}', style: Theme.of(context).textTheme.titleMedium),
                        Text('What can we fix today?', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(state.userName.isEmpty ? 'F' : state.userName[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 20), sliver: SliverToBoxAdapter(child: TextField(controller: searchController, onSubmitted: (_) => openList(), decoration: InputDecoration(hintText: 'Search services or providers', prefixIcon: const Icon(Icons.search), suffixIcon: IconButton(onPressed: () => openList(), icon: const Icon(Icons.arrow_forward)))))),
          SliverPadding(padding: const EdgeInsets.fromLTRB(20, 26, 20, 12), sliver: SliverToBoxAdapter(child: Text('Explore services', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)))),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final category = state.categories[index];
                  final icons = [Icons.water_drop, Icons.bolt, Icons.chair, Icons.format_paint, Icons.ac_unit, Icons.cleaning_services];
                  return InkWell(
                    onTap: () => openList(categoryId: category.id),
                    borderRadius: BorderRadius.circular(18),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icons[index], size: 30, color: Theme.of(context).colorScheme.secondary),
                            const SizedBox(height: 8),
                            Text(category.name, textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: state.categories.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: .9,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            sliver: SliverToBoxAdapter(
              child: Card(
                color: Theme.of(context).colorScheme.primary,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Need a hand?', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            SizedBox(height: 5),
                            Text('Find trusted professionals near you.', style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),
                      const Icon(Icons.handyman, color: Colors.white, size: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
