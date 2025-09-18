import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../searchable_dropdown.dart';

// Base class for ad form data
abstract class AdFormData {
  String? get make;
  String? get model;
  String? get title;
  String? get description;
  String? get color;
  String? get transmissionType;
  String? get fuelType;
  String? get bodyType;
  String? get steeringPosition;
  String? get cylinderCount;
  String? get carCondition;
  String? get doorCount;
  String? get region;
  String? get city;
  List<String> get features;
  int? get year;
  int? get horsepower;
  int? get displacement;
  int? get mileage;
  int? get price;
  int? get ownerCount;
  String? get phone;
}

// Image management section
class AdImageSection extends StatelessWidget {
  final List<String> existingImages;
  final List<XFile> newImages;
  final VoidCallback onAddImages;
  final Function(String) onRemoveExistingImage;
  final Function(int) onRemoveNewImage;
  final bool isEditing;

  const AdImageSection({
    super.key,
    this.existingImages = const [],
    this.newImages = const [],
    required this.onAddImages,
    required this.onRemoveExistingImage,
    required this.onRemoveNewImage,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Снимки',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ElevatedButton.icon(
                  onPressed: onAddImages,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: Text(isEditing ? 'Добави снимки' : 'Избери снимки'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Existing images (for edit mode)
            if (isEditing && existingImages.isNotEmpty) ...[
              const Text('Съществуващи снимки:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: existingImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              existingImages[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => onRemoveExistingImage(existingImages[index]),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // New images
            if (newImages.isNotEmpty) ...[
              Text(
                isEditing ? 'Нови снимки:' : 'Избрани снимки:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: newImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(newImages[index].path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => onRemoveNewImage(index),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            
            if (existingImages.isEmpty && newImages.isEmpty)
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Няма избрани снимки',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Basic information section
class AdBasicInfoSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final List<String> brands;
  final List<String> models;
  final List<String> colors;
  final String? selectedBrand;
  final String? selectedModel;
  final String? selectedColor;
  final Function(String?) onBrandChanged;
  final Function(String?) onModelChanged;
  final Function(String?) onColorChanged;
  final Function(String) onTitleChanged;
  final Function(String) onDescriptionChanged;

  const AdBasicInfoSection({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.brands,
    required this.models,
    required this.colors,
    required this.selectedBrand,
    required this.selectedModel,
    required this.selectedColor,
    required this.onBrandChanged,
    required this.onModelChanged,
    required this.onColorChanged,
    required this.onTitleChanged,
    required this.onDescriptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Основна информация',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            SearchableDropdown<String>(
              labelText: 'Марка',
              value: selectedBrand,
              items: brands.map((brand) => DropdownMenuItem(
                value: brand,
                child: Text(brand),
              )).toList(),
              onChanged: onBrandChanged,
            ),
            const SizedBox(height: 16),
            
            SearchableDropdown<String>(
              labelText: 'Модел',
              value: selectedModel,
              items: [
                // Include the currently selected model if it's not in the list
                if (selectedModel != null && !models.contains(selectedModel))
                  DropdownMenuItem(
                    value: selectedModel,
                    child: Text(selectedModel!),
                  ),
                // Add all other models
                ...models.map((model) => DropdownMenuItem(
                  value: model,
                  child: Text(model),
                )).toList(),
              ],
              onChanged: onModelChanged,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Заглавие',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Моля въведете заглавие';
                }
                return null;
              },
              onChanged: onTitleChanged,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Моля въведете описание';
                }
                return null;
              },
              onChanged: onDescriptionChanged,
            ),
            const SizedBox(height: 16),
            
            SearchableDropdown<String>(
              labelText: 'Цвят',
              value: selectedColor,
              items: colors.map((color) => DropdownMenuItem(
                value: color,
                child: Text(color),
              )).toList(),
              onChanged: onColorChanged,
            ),
          ],
        ),
      ),
    );
  }
}

// Technical specifications section
class AdTechnicalSpecsSection extends StatelessWidget {
  final TextEditingController yearController;
  final TextEditingController horsepowerController;
  final TextEditingController displacementController;
  final TextEditingController mileageController;
  final TextEditingController priceController;
  final TextEditingController ownerCountController;
  final List<String> transmissionTypes;
  final List<String> fuelTypes;
  final List<String> bodyTypes;
  final List<String> steeringPositions;
  final List<String> cylinderCounts;
  final List<String> driveTypes;
  final List<String> carConditions;
  final List<String> doorCounts;
  final String? selectedTransmissionType;
  final String? selectedFuelType;
  final String? selectedBodyType;
  final String? selectedSteeringPosition;
  final String? selectedCylinderCount;
  final String? selectedDriveType;
  final String? selectedCarCondition;
  final String? selectedDoorCount;
  final Function(String?) onTransmissionTypeChanged;
  final Function(String?) onFuelTypeChanged;
  final Function(String?) onBodyTypeChanged;
  final Function(String?) onSteeringPositionChanged;
  final Function(String?) onCylinderCountChanged;
  final Function(String?) onDriveTypeChanged;
  final Function(String?) onCarConditionChanged;
  final Function(String?) onDoorCountChanged;

  const AdTechnicalSpecsSection({
    super.key,
    required this.yearController,
    required this.horsepowerController,
    required this.displacementController,
    required this.mileageController,
    required this.priceController,
    required this.ownerCountController,
    required this.transmissionTypes,
    required this.fuelTypes,
    required this.bodyTypes,
    required this.steeringPositions,
    required this.cylinderCounts,
    required this.driveTypes,
    required this.carConditions,
    required this.doorCounts,
    required this.selectedTransmissionType,
    required this.selectedFuelType,
    required this.selectedBodyType,
    required this.selectedSteeringPosition,
    required this.selectedCylinderCount,
    required this.selectedDriveType,
    required this.selectedCarCondition,
    required this.selectedDoorCount,
    required this.onTransmissionTypeChanged,
    required this.onFuelTypeChanged,
    required this.onBodyTypeChanged,
    required this.onSteeringPositionChanged,
    required this.onCylinderCountChanged,
    required this.onDriveTypeChanged,
    required this.onCarConditionChanged,
    required this.onDoorCountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Технически характеристики',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: yearController,
                    decoration: const InputDecoration(
                      labelText: 'Година',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Въведете година';
                      }
                      final year = int.tryParse(value);
                      if (year == null || year < 1900 || year > DateTime.now().year) {
                        return 'Невалидна година';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Цена (€)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Въведете цена';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Невалидно число';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: horsepowerController,
                    decoration: const InputDecoration(
                      labelText: 'Мощност (к.с.)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Въведете мощност';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Невалидно число';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: displacementController,
                    decoration: const InputDecoration(
                      labelText: 'Обем двигател (cc)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Въведете обем';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Невалидно число';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: mileageController,
                    decoration: const InputDecoration(
                      labelText: 'Пробег (км)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Въведете пробег';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Невалидно число';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: ownerCountController,
                    decoration: const InputDecoration(
                      labelText: 'Брой собственици',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Въведете брой собственици';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Невалидно число';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedDoorCount,
                    decoration: const InputDecoration(
                      labelText: 'Брой врати',
                      border: OutlineInputBorder(),
                    ),
                    items: doorCounts.map((count) => DropdownMenuItem(
                      value: count,
                      child: Text(count),
                    )).toList(),
                    onChanged: onDoorCountChanged,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedTransmissionType,
                    decoration: const InputDecoration(
                      labelText: 'Трансмисия',
                      border: OutlineInputBorder(),
                    ),
                    items: transmissionTypes.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    )).toList(),
                    onChanged: onTransmissionTypeChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedFuelType,
                    decoration: const InputDecoration(
                      labelText: 'Гориво',
                      border: OutlineInputBorder(),
                    ),
                    items: fuelTypes.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    )).toList(),
                    onChanged: onFuelTypeChanged,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedBodyType,
                    decoration: const InputDecoration(
                      labelText: 'Тип купе',
                      border: OutlineInputBorder(),
                    ),
                    items: bodyTypes.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    )).toList(),
                    onChanged: onBodyTypeChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedSteeringPosition,
                    decoration: const InputDecoration(
                      labelText: 'Позиция на волана',
                      border: OutlineInputBorder(),
                    ),
                    items: steeringPositions.map((position) => DropdownMenuItem(
                      value: position,
                      child: Text(position),
                    )).toList(),
                    onChanged: onSteeringPositionChanged,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedCylinderCount,
                    decoration: const InputDecoration(
                      labelText: 'Брой цилиндри',
                      border: OutlineInputBorder(),
                    ),
                    items: cylinderCounts.map((count) => DropdownMenuItem(
                      value: count,
                      child: Text(count),
                    )).toList(),
                    onChanged: onCylinderCountChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedDriveType,
                    decoration: const InputDecoration(
                      labelText: 'Задвижване',
                      border: OutlineInputBorder(),
                    ),
                    items: driveTypes.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    )).toList(),
                    onChanged: onDriveTypeChanged,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedCarCondition,
                    decoration: const InputDecoration(
                      labelText: 'Състояние',
                      border: OutlineInputBorder(),
                    ),
                    items: carConditions.map((condition) => DropdownMenuItem(
                      value: condition,
                      child: Text(condition),
                    )).toList(),
                    onChanged: onCarConditionChanged,
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

// Features section
class AdFeaturesSection extends StatelessWidget {
  final List<String> features;
  final List<String> selectedFeatures;
  final Function(List<String>) onFeaturesChanged;

  const AdFeaturesSection({
    super.key,
    required this.features,
    required this.selectedFeatures,
    required this.onFeaturesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Опции',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: features.map((feature) {
                final isSelected = selectedFeatures.contains(feature);
                return FilterChip(
                  label: Text(feature),
                  selected: isSelected,
                  onSelected: (selected) {
                    final newSelected = List<String>.from(selectedFeatures);
                    if (selected) {
                      newSelected.add(feature);
                    } else {
                      newSelected.remove(feature);
                    }
                    onFeaturesChanged(newSelected);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// Location section
class AdLocationSection extends StatelessWidget {
  final List<Map<String, dynamic>> regions;
  final List<Map<String, dynamic>> cities;
  final String? selectedRegion;
  final String? selectedCity;
  final Function(String?) onRegionChanged;
  final Function(String?) onCityChanged;

  const AdLocationSection({
    super.key,
    required this.regions,
    required this.cities,
    required this.selectedRegion,
    required this.selectedCity,
    required this.onRegionChanged,
    required this.onCityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Местоположение',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            SearchableDropdown<String>(
              labelText: 'Област',
              value: selectedRegion,
              items: regions.map((region) => DropdownMenuItem<String>(
                value: region['name'] as String,
                child: Text(region['name'] as String),
              )).toList(),
              onChanged: onRegionChanged,
            ),
            const SizedBox(height: 16),
            
            SearchableDropdown<String>(
              labelText: 'Град',
              value: selectedCity,
              items: cities.map((city) => DropdownMenuItem<String>(
                value: city['name'] as String,
                child: Text(city['name'] as String),
              )).toList(),
              onChanged: onCityChanged,
            ),
          ],
        ),
      ),
    );
  }
}

// Contact section
class AdContactSection extends StatelessWidget {
  final TextEditingController phoneController;
  final Function(String) onPhoneChanged;

  const AdContactSection({
    super.key,
    required this.phoneController,
    required this.onPhoneChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Контакт',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Телефон',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Моля въведете телефон';
                }
                return null;
              },
              onChanged: onPhoneChanged,
            ),
          ],
        ),
      ),
    );
  }
}
