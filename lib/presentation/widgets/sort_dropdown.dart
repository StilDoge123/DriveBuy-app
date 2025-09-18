import 'package:flutter/material.dart';

enum SortOption {
  priceLowToHigh('PRICE_LOW_TO_HIGH', 'Цена: ниска към висока'),
  priceHighToLow('PRICE_HIGH_TO_LOW', 'Цена: висока към ниска'),
  yearNewestFirst('YEAR_NEWEST_FIRST', 'Година: нова към стара'),
  yearOldestFirst('YEAR_OLDEST_FIRST', 'Година: стара към нова'),
  mileageLowToHigh('MILEAGE_LOW_TO_HIGH', 'Пробег: нисък към висок'),
  mileageHighToLow('MILEAGE_HIGH_TO_LOW', 'Пробег: висок към нисък'),
  dateNewestFirst('DATE_NEWEST_FIRST', 'Дата: най-нови първо'),
  dateOldestFirst('DATE_OLDEST_FIRST', 'Дата: най-стари първо'),
  hpLowToHigh('HP_LOW_TO_HIGH', 'Мощност: ниска към висока'),
  hpHighToLow('HP_HIGH_TO_LOW', 'Мощност: висока към ниска');

  const SortOption(this.backendValue, this.displayName);

  final String backendValue;
  final String displayName;
}

class SortDropdown extends StatelessWidget {
  final SortOption? currentSort;
  final Function(SortOption?) onSortChanged;

  const SortDropdown({
    super.key,
    this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SortOption?>(
          value: currentSort,
          hint: const Text(
            'Сортиране',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          icon: const Icon(Icons.sort, size: 20),
          items: [
            const DropdownMenuItem<SortOption?>(
              value: null,
              child: Text(
                'Без сортиране',
                style: TextStyle(fontSize: 14),
              ),
            ),
            ...SortOption.values.map((option) {
              return DropdownMenuItem<SortOption?>(
                value: option,
                child: Text(
                  option.displayName,
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }),
          ],
          onChanged: onSortChanged,
          isExpanded: false,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
          ),
          dropdownColor: Colors.white,
        ),
      ),
    );
  }
}
