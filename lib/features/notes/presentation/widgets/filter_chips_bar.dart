import 'package:flutter/material.dart';

class FilterChipsBar extends StatelessWidget {
  final String activeFilter;
  final Function(String filter) onFilterSelected;

  const FilterChipsBar({
    super.key,
    required this.activeFilter,
    required this.onFilterSelected,
  });

  static const List<Map<String, String>> filters = [
    {'id': 'todos', 'label': 'Todos'},
    {'id': 'fav', 'label': 'Fav ⭐'},
    {'id': 'borrador', 'label': 'borrador'},
    {'id': 'pap', 'label': 'Pap 🗑️'},
    {'id': 'voz', 'label': 'Nota de voz'},
    {'id': 'escrita', 'label': 'Nota escrita'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
          child: Text(
            'Filtros',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: 38,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = filters[index];
              final isSelected = activeFilter == filter['id'];

              return GestureDetector(
                onTap: () => onFilterSelected(filter['id']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFFD6D6D6).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(18),
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 1.5)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      filter['label']!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
