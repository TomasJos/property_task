
import 'package:flutter/material.dart';
import 'package:property_list/provider/property_provider.dart';
import 'package:provider/provider.dart';


class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  RangeValues _price = const RangeValues(100000, 200000);
  final TextEditingController _locationCtrl = TextEditingController();
  final List<String> _allTags = ['New', 'Furnished', 'Available'];
  final Set<String> _selectedTags = {};
  String? _status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Price Range',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Row(
              children: [
                Expanded(
                  child: RangeSlider(
                    values: _price,
                    min: 0,
                    max: 1000000,
                    divisions: 100,
                    labels: RangeLabels(
                      _price.start.toInt().toString(),
                      _price.end.toInt().toString(),
                    ),
                    onChanged: (v) => setState(() => _price = v),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${_price.start.toInt()} - ${_price.end.toInt()}',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationCtrl,
              decoration: const InputDecoration(
                labelText: 'Location',
                hintText: 'Enter Location',
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: _allTags
                  .map((tag) => FilterChip(
                label: Text(tag),
                selected: _selectedTags.contains(tag),
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _selectedTags.add(tag);
                    } else {
                      _selectedTags.remove(tag);
                    }
                  });
                },
              ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              hint: const Text('Status'),
              items: const [
                DropdownMenuItem(value: 'Available', child: Text('Available')),
                DropdownMenuItem(value: 'Sold', child: Text('Sold')),
                DropdownMenuItem(value: 'Upcoming', child: Text('Upcoming')),
              ],
              onChanged: (val) => setState(() => _status = val),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<PropertyProvider>().applyFilters(
                        minPrice: _price.start.toInt(),
                        maxPrice: _price.end.toInt(),
                        location: _locationCtrl.text.trim(),
                        tags: _selectedTags.toList(),
                        status: _status,
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Apply Filters'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<PropertyProvider>().clearFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Remove Filters'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

