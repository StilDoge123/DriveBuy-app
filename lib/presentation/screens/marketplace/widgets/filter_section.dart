import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/services/dropdown_data_service.dart';
import '../../../../domain/models/car_search_filter.dart';
import '../../../widgets/searchable_dropdown.dart';
import '../bloc/marketplace_bloc.dart';
import '../bloc/marketplace_event.dart';
import '../bloc/marketplace_state.dart';

class FilterSection extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  
  const FilterSection({super.key, required this.formKey});
  
  @override
  State<FilterSection> createState() => _FilterSectionState();
}

class _FilterSectionState extends State<FilterSection> {
  final _dropdownService = DropdownDataService();
  List<String> _brands = [];
  List<String> _models = [];
  List<String> _transmissionTypes = [];
  List<String> _fuelTypes = [];
  List<String> _bodyTypes = [];
  List<String> _doorCounts = [];
  List<String> _features = [];
  List<String> _steeringPositions = [];
  List<String> _cylinderCounts = [];
  List<String> _driveTypes = [];
  List<String> _carConditions = [];
  List<String> _colors = [];
  List<Map<String, dynamic>> _regions = [];
  List<Map<String, dynamic>> _cities = [];
  bool _isLoading = true;
  bool _collapsed = true;

  final _keywordController = TextEditingController();
  final _priceFromController = TextEditingController();
  final _priceToController = TextEditingController();
  final _yearFromController = TextEditingController();
  final _yearToController = TextEditingController();
  final _hpFromController = TextEditingController();
  final _hpToController = TextEditingController();
  final _displacementFromController = TextEditingController();
  final _displacementToController = TextEditingController();
  final _mileageFromController = TextEditingController();
  final _mileageToController = TextEditingController();
  final _ownerCountFromController = TextEditingController();
  final _ownerCountToController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  void collapse() {
    if (!_collapsed) {
      setState(() => _collapsed = true);
    }
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _priceFromController.dispose();
    _priceToController.dispose();
    _yearFromController.dispose();
    _yearToController.dispose();
    _hpFromController.dispose();
    _hpToController.dispose();
    _displacementFromController.dispose();
    _displacementToController.dispose();
    _mileageFromController.dispose();
    _mileageToController.dispose();
    _ownerCountFromController.dispose();
    _ownerCountToController.dispose();
    super.dispose();
  }

  String? _validateYear(String? value) {
    if (value == null || value.isEmpty) return null;
    final year = int.tryParse(value);
    if (year == null) return 'Невалидна година';
    final currentYear = DateTime.now().year;
    if (year < 1900 || year > currentYear) {
      return '1900 < Година < $currentYear';
    }
    return null;
  }

  String? _validateRangeFrom(String? value, String? toValue, String fieldName) {
    if (value == null || value.isEmpty) return null;
    final from = int.tryParse(value);
    if (from == null) return 'Невалидно число';
    if (toValue != null && toValue.isNotEmpty) {
      final to = int.tryParse(toValue);
      if (to != null && from > to) {
        return 'От > До';
      }
    }
    return null;
  }

  String? _validateRangeTo(String? value, String? fromValue, String fieldName) {
    if (value == null || value.isEmpty) return null;
    final to = int.tryParse(value);
    if (to == null) return 'Невалидно число';
    if (fromValue != null && fromValue.isNotEmpty) {
      final from = int.tryParse(fromValue);
      if (from != null && from > to) {
        return 'До < От';
      }
    }
    return null;
  }

  Future<void> _loadDropdownData() async {
    try {
      final futures = await Future.wait([
        _dropdownService.getBrands(),
        _dropdownService.getTransmissionTypes(),
        _dropdownService.getFuelTypes(),
        _dropdownService.getBodyTypes(),
        _dropdownService.getDoorCounts(),
        _dropdownService.getFeatures(),
        _dropdownService.getSteeringPositions(),
        _dropdownService.getCylinderCounts(),
        _dropdownService.getDriveTypes(),
        _dropdownService.getCarConditions(),
        _dropdownService.getColors(),
        _dropdownService.getRegions(),
      ]);

      if (!mounted) return;

      setState(() {
        _brands = futures[0] as List<String>;
        _transmissionTypes = futures[1] as List<String>;
        _fuelTypes = futures[2] as List<String>;
        _bodyTypes = futures[3] as List<String>;
        _doorCounts = futures[4] as List<String>;
        _features = futures[5] as List<String>;
        _steeringPositions = futures[6] as List<String>;
        _cylinderCounts = futures[7] as List<String>;
        _driveTypes = futures[8] as List<String>;
        _carConditions = futures[9] as List<String>;
        _colors = futures[10] as List<String>;
        _regions = futures[11] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading filter data: $e')),
      );
    }
  }

  Future<void> _loadCities(String regionId) async {
    setState(() {
      _cities = [];
    });
    try {
      final cities = await _dropdownService.getCitiesByRegion(regionId);
      if (!mounted) return;
      setState(() => _cities = cities);
    } catch (e) {
      if (!mounted) return;
      setState(() => _cities = []);
    }
  }

  Future<void> _loadModels(String brandName) async {
    try {
      final response = await _dropdownService.dio.get('${_dropdownService.baseUrl}/brands');
      if (!mounted) return;

      final List<dynamic> data = response.data;
      final brand = data.firstWhere(
        (b) => b['brandName'] == brandName,
        orElse: () => null,
      );
      List<String> models = [];
      if (brand != null) {
        models = await _dropdownService.getModels(brand['id'].toString());
      }
      
      if (!mounted) return;
      setState(() {
        _models = models;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _models = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading models: $e')),
      );
    }
  }

  Widget _buildRangeFields({
    required String label,
    required TextEditingController fromController,
    required TextEditingController toController,
    required void Function(String) onFromChanged,
    required void Function(String) onToChanged,
    TextInputType keyboardType = TextInputType.number,
    String? Function(String?)? fromValidator,
    String? Function(String?)? toValidator,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: fromController,
            decoration: InputDecoration(
              labelText: '$label От',
              border: const OutlineInputBorder(),
            ),
            keyboardType: keyboardType,
            inputFormatters: keyboardType == TextInputType.number 
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            validator: fromValidator,
            onChanged: onFromChanged,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: toController,
            decoration: InputDecoration(
              labelText: '$label До',
              border: const OutlineInputBorder(),
            ),
            keyboardType: keyboardType,
            inputFormatters: keyboardType == TextInputType.number 
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            validator: toValidator,
            onChanged: onToChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildMultiChoiceChips({
    required String label,
    required List<String> options,
    required List<String> selected,
    required void Function(List<String>) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: options.map((option) {
            final isSelected = selected.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selectedNow) {
                final newSelected = List<String>.from(selected);
                if (selectedNow) {
                  newSelected.add(option);
                } else {
                  newSelected.remove(option);
                }
                onChanged(newSelected);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSelectedFilterChips(Map<String, dynamic> selectedFilters, void Function(String key) onClear) {
    return Wrap(
      spacing: 8,
      children: selectedFilters.entries.map((entry) {
        final key = entry.key;
        final value = entry.value;
        if (value == null || (value is String && value.isEmpty) || (value is List && value.isEmpty)) return const SizedBox.shrink();
        return Chip(
          label: Text('$key: ${value is List ? value.join(", ") : value}'),
          deleteIcon: const Icon(Icons.close),
          onDeleted: () => onClear(key),
        );
      }).toList(),
    );
  }

  Map<String, dynamic> _getSelectedFilters(CarSearchFilter filter) {
    return <String, dynamic>{
      if (filter.make != null) 'Марка': filter.make,
      if (filter.model != null) 'Модел': filter.model,
      if (filter.keywordSearch != null) 'Търсене по ключова дума': filter.keywordSearch,
      if (filter.color != null) 'Цвят': filter.color,
      if (filter.conditions != null && filter.conditions!.isNotEmpty) 'Състояние': filter.conditions,
      if (filter.features != null && filter.features!.isNotEmpty) 'Опции': filter.features,
      if (filter.minPrice != null) 'Цена От': filter.minPrice,
      if (filter.maxPrice != null) 'Цена До': filter.maxPrice,
      if (filter.yearFrom != null) 'Година От': filter.yearFrom,
      if (filter.yearTo != null) 'Година До': filter.yearTo,
      if (filter.hpFrom != null) 'Мощност От': filter.hpFrom,
      if (filter.hpTo != null) 'Мощност До': filter.hpTo,
      if (filter.displacementFrom != null) 'Кубатура двигател От': filter.displacementFrom,
      if (filter.displacementTo != null) 'Кубатура двигател До': filter.displacementTo,
      if (filter.mileageFrom != null) 'Пробег От': filter.mileageFrom,
      if (filter.mileageTo != null) 'Пробег До': filter.mileageTo,
      if (filter.ownerCountFrom != null) 'Брой предишни собственици От': filter.ownerCountFrom,
      if (filter.ownerCountTo != null) 'Брой предишни собственици До': filter.ownerCountTo,
      if (filter.transmissionType != null) 'Скоростна кутия': filter.transmissionType,
      if (filter.fuelType != null) 'Гориво': filter.fuelType,
      if (filter.driveType != null) 'Задвижване': filter.driveType,
      if (filter.bodyType != null) 'Вид купе': filter.bodyType,
      if (filter.doorCount != null) 'Брой врати': filter.doorCount,
      if (filter.steeringPosition != null) 'Позиция на волана': filter.steeringPosition,
      if (filter.cylinderCount != null) 'Брой цилиндри': filter.cylinderCount,
      if (filter.region != null) 'Област': filter.region,
      if (filter.city != null) 'Град': filter.city,
    };
  }

  void _clearFilter(String key, CarSearchFilter filter) {
    CarSearchFilter newFilter;
    switch (key) {
      case 'Марка':
        newFilter = filter.copyWith(make: null, model: null);
        setState(() => _models = []);
        break;
      case 'Модел':
        newFilter = filter.copyWith(model: null);
        break;
      case 'Търсене по ключова дума':
        newFilter = filter.copyWith(keywordSearch: null);
        break;
      case 'Цена От':
        newFilter = filter.copyWith(minPrice: null);
        break;
      case 'Цена До':
        newFilter = filter.copyWith(maxPrice: null);
        break;
      case 'Година От':
        newFilter = filter.copyWith(yearFrom: null);
        break;
      case 'Година До':
        newFilter = filter.copyWith(yearTo: null);
        break;
      case 'Скоростна кутия':
        newFilter = filter.copyWith(transmissionType: null);
        break;
      case 'Гориво':
        newFilter = filter.copyWith(fuelType: null);
        break;
      case 'Задвижване':
        newFilter = filter.copyWith(driveType: null);
        break;
      case 'Цвят':
        newFilter = filter.copyWith(color: null);
        break;
      case 'Опции':
        newFilter = filter.copyWith(features: <String>[]);
        break;
      case 'Състояние':
        newFilter = filter.copyWith(conditions: <String>[]);
        break;
      case 'Мощност От':
        newFilter = filter.copyWith(hpFrom: null);
        break;
      case 'Мощност До':
        newFilter = filter.copyWith(hpTo: null);
        break;
      case 'Пробег От':
        newFilter = filter.copyWith(mileageFrom: null);
        break;
      case 'Пробег До':
        newFilter = filter.copyWith(mileageTo: null);
        break;
      case 'Позиция на волана':
        newFilter = filter.copyWith(steeringPosition: null);
        break;
      case 'Брой цилиндри':
        newFilter = filter.copyWith(cylinderCount: null);
        break;
      case 'Кубатура двигател От':
        newFilter = filter.copyWith(displacementFrom: null);
        break;
      case 'Кубатура двигател До':
        newFilter = filter.copyWith(displacementTo: null);
        break;
      case 'Брой предишни собственици От':
        newFilter = filter.copyWith(ownerCountFrom: null);
        break;
      case 'Брой предишни собственици До':
        newFilter = filter.copyWith(ownerCountTo: null);
        break;
      case 'Вид купе':
        newFilter = filter.copyWith(bodyType: null);
        break;
      case 'Брой врати':
        newFilter = filter.copyWith(doorCount: null);
        break;
      case 'Област':
        newFilter = filter.copyWith(region: null, city: null);
        setState(() {
          _cities = [];
        });
        break;
      case 'Град':
        newFilter = filter.copyWith(city: null);
        break;
      default:
        newFilter = filter;
    }
    context.read<MarketplaceBloc>().add(MarketplaceUpdateFilter(newFilter));
  }

  Widget _buildExpandedContent() {
    return BlocBuilder<MarketplaceBloc, MarketplaceState>(
              buildWhen: (previous, current) => previous.filter != current.filter,
              builder: (context, state) {
                final filter = state.filter;
                _keywordController.text = filter.keywordSearch ?? '';
                _priceFromController.text = filter.minPrice?.toString() ?? '';
                _priceToController.text = filter.maxPrice?.toString() ?? '';
                _yearFromController.text = filter.yearFrom?.toString() ?? '';
                _yearToController.text = filter.yearTo?.toString() ?? '';
                _hpFromController.text = filter.hpFrom?.toString() ?? '';
                _hpToController.text = filter.hpTo?.toString() ?? '';
                _displacementFromController.text = filter.displacementFrom?.toString() ?? '';
                _displacementToController.text = filter.displacementTo?.toString() ?? '';
                _mileageFromController.text = filter.mileageFrom?.toString() ?? '';
                _mileageToController.text = filter.mileageTo?.toString() ?? '';
                _ownerCountFromController.text = filter.ownerCountFrom?.toString() ?? '';
                _ownerCountToController.text = filter.ownerCountTo?.toString() ?? '';

                // Ensure models are loaded if a make is selected but models list is empty
                if (filter.make != null && _models.isEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _loadModels(filter.make!);
                  });
                }

                final selectedFilters = <String, dynamic>{
                  if (filter.make != null) 'Марка': filter.make,
                  if (filter.model != null) 'Модел': filter.model,
                  if (filter.keywordSearch != null) 'Търсене по ключова дума': filter.keywordSearch,
                  if (filter.color != null) 'Цвят': filter.color,
                  if (filter.conditions != null && filter.conditions!.isNotEmpty) 'Състояние': filter.conditions,
                  if (filter.features != null && filter.features!.isNotEmpty) 'Опции': filter.features,
                  if (filter.minPrice != null) 'Цена От': filter.minPrice,
                  if (filter.maxPrice != null) 'Цена До': filter.maxPrice,
                  if (filter.yearFrom != null) 'Година От': filter.yearFrom,
                  if (filter.yearTo != null) 'Година До': filter.yearTo,
                  if (filter.hpFrom != null) 'Мощност От': filter.hpFrom,
                  if (filter.hpTo != null) 'Мощност До': filter.hpTo,
                  if (filter.displacementFrom != null) 'Кубатура двигател От': filter.displacementFrom,
                  if (filter.displacementTo != null) 'Кубатура двигател До': filter.displacementTo,
                  if (filter.mileageFrom != null) 'Пробег От': filter.mileageFrom,
                  if (filter.mileageTo != null) 'Пробег До': filter.mileageTo,
                  if (filter.ownerCountFrom != null) 'Брой собственици От': filter.ownerCountFrom,
                  if (filter.ownerCountTo != null) 'Брой собственици До': filter.ownerCountTo,
                  if (filter.transmissionType != null) 'Скоростна кутия': filter.transmissionType,
                  if (filter.fuelType != null) 'Гориво': filter.fuelType,
                  if (filter.bodyType != null) 'Вид купе': filter.bodyType,
                  if (filter.driveType != null) 'Задвижване': filter.driveType,
                  if (filter.doorCount != null) 'Брой врати': filter.doorCount,
                  if (filter.steeringPosition != null) 'Позиция на волана': filter.steeringPosition,
                  if (filter.cylinderCount != null) 'Брой цилиндри': filter.cylinderCount,
                  if (filter.region != null) 'Област': filter.region,
                  if (filter.city != null) 'Град': filter.city,
                };

                return Stack(
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Form(
                              key: widget.formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                _buildSelectedFilterChips(selectedFilters, (key) => _clearFilter(key, filter)),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _keywordController,
                                  decoration: const InputDecoration(
                                    labelText: 'Търсене по ключова дума',
                                    border: OutlineInputBorder(),
                                    hintText: 'Търсене в заглавие и описание',
                                  ),
                                  onChanged: (value) {
                                    final newFilter = filter.copyWith(keywordSearch: value.isEmpty ? null : value);
                                    context.read<MarketplaceBloc>().add(MarketplaceUpdateFilter(newFilter));
                                  },
                                ),
                                const SizedBox(height: 8),
                                SearchableDropdown<String>(
                                  labelText: 'Марка',
                                  value: filter.make,
                                  items: _brands.map((brand) => DropdownMenuItem(
                                    value: brand,
                                    child: Text(brand),
                                  )).toList(),
                                  onChanged: (value) {
                                    final newFilter = filter.copyWith(make: value, model: null);
                                    context.read<MarketplaceBloc>().add(MarketplaceUpdateFilter(newFilter));
                                    if (value != null) {
                                      _loadModels(value);
                                    } else {
                                      setState(() => _models = []);
                                    }
                                  },
                                ),
                                const SizedBox(height: 8),
                                SearchableDropdown<String>(
                                  labelText: 'Модел',
                                  value: filter.model,
                                  items: [
                                    if (filter.model != null && !_models.contains(filter.model))
                                      DropdownMenuItem(
                                        value: filter.model,
                                        child: Text(filter.model!),
                                      ),
                                    ..._models.map((model) => DropdownMenuItem(
                                      value: model,
                                      child: Text(model),
                                    )).toList(),
                                  ],
                                  onChanged: (value) {
                                    final newFilter = filter.copyWith(model: value);
                                    context.read<MarketplaceBloc>().add(MarketplaceUpdateFilter(newFilter));
                                  },
                                ),
                                const SizedBox(height: 8),
                                SearchableDropdown<String>(
                                  labelText: 'Цвят',
                                  value: filter.color,
                                  items: _colors.map((color) => DropdownMenuItem(
                                    value: color,
                                    child: Text(color),
                                  )).toList(),
                                  onChanged: (value) {
                                    final newFilter = filter.copyWith(color: value);
                                    context.read<MarketplaceBloc>().add(MarketplaceUpdateFilter(newFilter));
                                  },
                                ),
                                const SizedBox(height: 8),
                                _buildRangeFields(
                                  label: 'Цена',
                                  fromController: _priceFromController,
                                  toController: _priceToController,
                                  onFromChanged: (v) {
                                    final newFilter = filter.copyWith(minPrice: int.tryParse(v));
                                    context.read<MarketplaceBloc>().add(MarketplaceUpdateFilter(newFilter));
                                  },
                                  onToChanged: (v) {
                                    final newFilter = filter.copyWith(maxPrice: int.tryParse(v));
                                    context.read<MarketplaceBloc>().add(MarketplaceUpdateFilter(newFilter));
                                  },
                                  fromValidator: (value) => _validateRangeFrom(value, _priceToController.text, 'Цена'),
                                  toValidator: (value) => _validateRangeTo(value, _priceFromController.text, 'Цена'),
                                ),
                                const SizedBox(height: 8),
                                _buildRangeFields(
                                  label: 'Година',
                                  fromController: _yearFromController,
                                  toController: _yearToController,
                                  onFromChanged: (v) {
                                    final newFilter = filter.copyWith(yearFrom: int.tryParse(v));
                                    context.read<MarketplaceBloc>().add(MarketplaceUpdateFilter(newFilter));
                                  },
                                  onToChanged: (v) {
                                    final newFilter = filter.copyWith(yearTo: int.tryParse(v));
                                    context.read<MarketplaceBloc>().add(MarketplaceUpdateFilter(newFilter));
                                  },
                                  fromValidator: (value) {
                                    final yearValidation = _validateYear(value);
                                    if (yearValidation != null) return yearValidation;
                                    return _validateRangeFrom(value, _yearToController.text, 'Година');
                                  },
                                  toValidator: (value) {
                                    final yearValidation = _validateYear(value);
                                    if (yearValidation != null) return yearValidation;
                                    return _validateRangeTo(value, _yearFromController.text, 'Година');
                                  },
                                ),
                                const SizedBox(height: 8),
                                _buildRangeFields(
                                  label: 'Мощност',
                                  fromController: _hpFromController,
                                  toController: _hpToController,
                                  onFromChanged: (v) {
                                    final newFilter = filter.copyWith(hpFrom: int.tryParse(v));
                                    context.read<MarketplaceBloc>().add(MarketplaceUpdateFilter(newFilter));
                                  },
                                  onToChanged: (v) {
                                    final newFilter = filter.copyWith(hpTo: int.tryParse(v));
                                    context.read<MarketplaceBloc>().add(MarketplaceUpdateFilter(newFilter));
                                  },
                                  fromValidator: (value) => _validateRangeFrom(value, _hpToController.text, 'Мощност'),
                                  toValidator: (value) => _validateRangeTo(value, _hpFromController.text, 'Мощност'),
                                ),
                                const SizedBox(height: 8),
                                _buildRangeFields(
                                  label: 'Кубатура двигател',
                                  fromController: _displacementFromController,
                                  toController: _displacementToController,
                                  onFromChanged: (v) {
                                    final newFilter = filter.copyWith(displacementFrom: int.tryParse(v));
                                    context.read<MarketplaceBloc>().add(MarketplaceUpdateFilter(newFilter));
                                  },
                                  onToChanged: (v) {
                                    final newFilter = filter.copyWith(displacementTo: int.tryParse(v));
                                    context.read<MarketplaceBloc>().add(MarketplaceUpdateFilter(newFilter));
                                  },
                                  fromValidator: (value) => _validateRangeFrom(value, _displacementToController.text, 'Кубатура двигател'),
                                  toValidator: (value) => _validateRangeTo(value, _displacementFromController.text, 'Кубатура двигател'),
                                ),
                                const SizedBox(height: 8),
                                _buildRangeFields(
                                  label: 'Пробег',
                                  fromController: _mileageFromController,
                                  toController: _mileageToController,
                                  onFromChanged: (v) {
                                    final newFilter = filter.copyWith(mileageFrom: int.tryParse(v));
                                    context.read<MarketplaceBloc>().add(MarketplaceUpdateFilter(newFilter));
                                  },
                                  onToChanged: (v) {
                                    final newFilter = filter.copyWith(mileageTo: int.tryParse(v));
                                    context.read<MarketplaceBloc>().add(MarketplaceUpdateFilter(newFilter));
                                  },
                                  fromValidator: (value) => _validateRangeFrom(value, _mileageToController.text, 'Пробег'),
                                  toValidator: (value) => _validateRangeTo(value, _mileageFromController.text, 'Пробег'),
                                ),
                                const SizedBox(height: 8),
                                _buildRangeFields(
                                  label: 'Брой собственици',
                                  fromController: _ownerCountFromController,
                                  toController: _ownerCountToController,
                                  onFromChanged: (v) {
                                    final newFilter = filter.copyWith(ownerCountFrom: int.tryParse(v));
                                    context.read<MarketplaceBloc>().add(MarketplaceUpdateFilter(newFilter));
                                  },
                                  onToChanged: (v) {
                                    final newFilter = filter.copyWith(ownerCountTo: int.tryParse(v));
                                    context.read<MarketplaceBloc>().add(MarketplaceUpdateFilter(newFilter));
                                  },
                                  fromValidator: (value) => _validateRangeFrom(value, _ownerCountToController.text, 'Брой предишни собственици'),
                                  toValidator: (value) => _validateRangeTo(value, _ownerCountFromController.text, 'Брой предишни собственици'),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Скоростна кутия',
                                    border: OutlineInputBorder(),
                                  ),
                                  value: filter.transmissionType,
                                  items: _transmissionTypes.map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  )).toList(),
                                  onChanged: (value) {
                                    final newFilter = filter.copyWith(transmissionType: value);
                                    context.read<MarketplaceBloc>().add(MarketplaceUpdateFilter(newFilter));
                                  },
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Гориво',
                                    border: OutlineInputBorder(),
                                  ),
                                  value: filter.fuelType,
                                  items: _fuelTypes.map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  )).toList(),
                                  onChanged: (value) {
                                    final newFilter = filter.copyWith(fuelType: value);
                                    context.read<MarketplaceBloc>().add(MarketplaceUpdateFilter(newFilter));
                                  },
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Вид купе',
                                    border: OutlineInputBorder(),
                                  ),
                                  value: filter.bodyType,
                                  items: _bodyTypes.map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  )).toList(),
                                  onChanged: (value) {
                                    final newFilter = filter.copyWith(bodyType: value);
                                    context.read<MarketplaceBloc>().add(MarketplaceUpdateFilter(newFilter));
                                  },
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Задвижване',
                                    border: OutlineInputBorder(),
                                  ),
                                  value: filter.driveType,
                                  items: _driveTypes.map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  )).toList(),
                                  onChanged: (value) {
                                    final newFilter = filter.copyWith(driveType: value);
                                    context.read<MarketplaceBloc>().add(MarketplaceUpdateFilter(newFilter));
                                  },
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Брой врати',
                                    border: OutlineInputBorder(),
                                  ),
                                  value: filter.doorCount,
                                  items: _doorCounts.map((count) => DropdownMenuItem(
                                    value: count,
                                    child: Text(count),
                                  )).toList(),
                                  onChanged: (value) {
                                    final newFilter = filter.copyWith(doorCount: value);
                                    context.read<MarketplaceBloc>().add(MarketplaceUpdateFilter(newFilter));
                                  },
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Позиция на волана',
                                    border: OutlineInputBorder(),
                                  ),
                                  value: filter.steeringPosition,
                                  items: _steeringPositions.map((position) => DropdownMenuItem(
                                    value: position,
                                    child: Text(position),
                                  )).toList(),
                                  onChanged: (value) {
                                    final newFilter = filter.copyWith(steeringPosition: value);
                                    context.read<MarketplaceBloc>().add(MarketplaceUpdateFilter(newFilter));
                                  },
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Брой цилиндри',
                                    border: OutlineInputBorder(),
                                  ),
                                  value: filter.cylinderCount,
                                  items: _cylinderCounts.map((count) => DropdownMenuItem(
                                    value: count,
                                    child: Text(count),
                                  )).toList(),
                                  onChanged: (value) {
                                    final newFilter = filter.copyWith(cylinderCount: value);
                                    context.read<MarketplaceBloc>().add(MarketplaceUpdateFilter(newFilter));
                                  },
                                ),
                                const SizedBox(height: 8),
                                SearchableDropdown<String>(
                                  labelText: 'Област',
                                  value: filter.region,
                                  items: _regions.map((region) => DropdownMenuItem<String>(
                                    value: region['name'] as String,
                                    child: Text(region['name'] as String),
                                  )).toList(),
                                  onChanged: (regionName) async {
                                    final newFilter = filter.copyWith(region: regionName, city: null);
                                    context.read<MarketplaceBloc>().add(MarketplaceUpdateFilter(newFilter));

                                    if (regionName != null) {
                                      final region = _regions.firstWhere((r) => r['name'] == regionName, orElse: () => {});
                                      final regionId = region['id']?.toString();
                                      if (regionId != null) {
                                        await _loadCities(regionId);
                                      }
                                    } else {
                                      setState(() => _cities = []);
                                    }
                                  },
                                ),
                                const SizedBox(height: 8),
                                SearchableDropdown<String>(
                                  labelText: 'Град',
                                  value: filter.city,
                                  items: _cities.map((city) => DropdownMenuItem<String>(
                                    value: city['name'] as String,
                                    child: Text(city['name'] as String),
                                  )).toList(),
                                  onChanged: (cityName) {
                                    final newFilter = filter.copyWith(city: cityName);
                                    context.read<MarketplaceBloc>().add(MarketplaceUpdateFilter(newFilter));
                                  },
                                ),
                                const SizedBox(height: 8),
                                _buildMultiChoiceChips(
                                      label: 'Състояние',
                                      options: _carConditions,
                                      selected: filter.conditions ?? [],
                                      onChanged: (selected) {
                                        final newFilter = filter.copyWith(conditions: selected);
                                        context.read<MarketplaceBloc>().add(MarketplaceUpdateFilter(newFilter));
                                      },
                                    ),
                                const SizedBox(height: 8),
                                ExpansionTile(
                                  title: const Text("Опции", style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),

                                  initiallyExpanded: false,
                                  children: [
                                    _buildMultiChoiceChips(
                                      label: '',
                                      options: _features,
                                      selected: filter.features ?? [],
                                      onChanged: (selected) {
                                        final newFilter = filter.copyWith(features: selected);
                                        context.read<MarketplaceBloc>().add(MarketplaceUpdateFilter(newFilter));
                                      },
                                    ),
                                  ],
                                ),
                              ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
              },
            );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return BlocListener<MarketplaceBloc, MarketplaceState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == MarketplaceStatus.loading) {
          collapse();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Always visible header with selected filters when collapsed
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Филтри',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: AnimatedRotation(
                          turns: _collapsed ? 0.0 : 0.5,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: IconButton(
                            icon: const Icon(Icons.expand_more),
                            tooltip: _collapsed ? 'Покажи филтри' : 'Скрий филтри',
                            onPressed: () => setState(() => _collapsed = !_collapsed),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Show selected filters when collapsed with remove functionality
                  if (_collapsed)
                    BlocBuilder<MarketplaceBloc, MarketplaceState>(
                      builder: (context, state) {
                        final selectedFilters = _getSelectedFilters(state.filter);
                        if (selectedFilters.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Няма активни филтри',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: _buildSelectedFilterChips(selectedFilters, (key) => _clearFilter(key, state.filter)),
                        );
                      },
                    ),
                ],
              ),
            ),
            // Animated content
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return SizeTransition(
                  sizeFactor: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: _collapsed
                  ? const SizedBox.shrink()
                  : _buildExpandedContent(),
            ),
          ],
        ),
      ),
    );
  }
}
