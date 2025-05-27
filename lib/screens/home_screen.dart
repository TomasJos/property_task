

import 'package:flutter/material.dart';
import 'package:property_list/provider/property_provider.dart';
import 'package:property_list/widget/property_card.dart';
import 'package:provider/provider.dart';
import 'filter_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        backgroundColor: Colors.deepOrangeAccent,
        title: const Text('Properties'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list,color: Colors.blue),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const FilterSheet(),
            ),
          ),
        ],
      ),
      body: Consumer<PropertyProvider>(

        builder: (_, provider, __) {
          if (provider.isLoading && provider.properties.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.properties.isEmpty) {
            return const Center(child: Text('No properties found.'));
          }
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: provider.refresh,
                  child: ListView.builder(
                    itemCount: provider.properties.length,
                    itemBuilder: (context, index) {
                      return PropertyCard(property: provider.properties[index]);
                    },
                  ),
                ),
              ),
              Container(
                height: 56,
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: provider.currentPage == 1
                          ? null
                          : () => provider.previousPage(),
                    ),
                    Text('Page ${provider.currentPage}'),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: provider.hasMore
                          ? () => provider.nextPage()
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}