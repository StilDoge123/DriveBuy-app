import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../widgets/sort_dropdown.dart';
import '../bloc/marketplace_bloc.dart';
import '../bloc/marketplace_event.dart';
import '../bloc/marketplace_state.dart';

class SortSection extends StatelessWidget {
  const SortSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketplaceBloc, MarketplaceState>(
      builder: (context, state) {
        // Determine current sort option from filter
        SortOption? currentSort;
        if (state.filter.sortBy != null) {
          currentSort = SortOption.values.cast<SortOption?>().firstWhere(
            (option) => option?.backendValue == state.filter.sortBy,
            orElse: () => null,
          );
        }

        return Row(
          children: [
            const Text(
              'Сортиране',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SortDropdown(
                currentSort: currentSort,
                onSortChanged: (sortOption) {
                  context.read<MarketplaceBloc>().add(
                    MarketplaceUpdateSort(
                      sortBy: sortOption?.backendValue,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
