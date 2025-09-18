import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/services/image_upload_service.dart';
import '../../../data/services/dropdown_data_service.dart';
import '../../../data/repositories/ad_repository.dart';
import '../../../domain/models/car_ad.dart';
import '../../widgets/ad_form/ad_form_sections.dart';
import 'bloc/edit_ad_bloc.dart';
import 'bloc/edit_ad_event.dart';
import 'bloc/edit_ad_state.dart';

class EditAdPage extends StatelessWidget {
  final int adId;
  
  const EditAdPage({super.key, required this.adId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditAdBloc(
        imageUploadService: ImageUploadService(),
        adRepository: AdRepository(),
      )..add(EditAdLoad(adId)),
      child: EditAdView(adId: adId),
    );
  }
}

class EditAdView extends StatefulWidget {
  final int adId;
  
  const EditAdView({super.key, required this.adId});

  @override
  State<EditAdView> createState() => _EditAdViewState();
}

class _EditAdViewState extends State<EditAdView> {
  final _dropdownService = DropdownDataService();
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _yearController = TextEditingController();
  final _horsepowerController = TextEditingController();
  final _displacementController = TextEditingController();
  final _mileageController = TextEditingController();
  final _priceController = TextEditingController();
  final _ownerCountController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Dropdown data
  List<String> _features = [];
  List<String> _transmissionTypes = [];
  List<String> _fuelTypes = [];
  List<String> _bodyTypes = [];
  List<String> _steeringPositions = [];
  List<String> _cylinderCounts = [];
  List<String> _driveTypes = [];
  List<String> _carConditions = [];
  List<String> _doorCounts = [];
  List<String> _brands = [];
  List<String> _models = [];
  List<Map<String, dynamic>> _regions = [];
  List<Map<String, dynamic>> _cities = [];
  List<String> _colors = [];
  
  // Selected values
  String? _selectedBrand;
  String? _selectedModel;
  String? _selectedColor;
  String? _selectedTransmissionType;
  String? _selectedFuelType;
  String? _selectedBodyType;
  String? _selectedSteeringPosition;
  String? _selectedCylinderCount;
  String? _selectedDriveType;
  String? _selectedCarCondition;
  String? _selectedDoorCount;
  String? _selectedRegion;
  String? _selectedCity;
  String? _selectedRegionId;
  List<String> _selectedFeatures = [];
  
  bool _isLoading = true;
  bool _isFormPopulated = false; // Flag to prevent repeated population
  List<String> _existingImages = [];
  List<XFile> _newImages = [];
  List<String> _imagesToDelete = [];

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _yearController.dispose();
    _horsepowerController.dispose();
    _displacementController.dispose();
    _mileageController.dispose();
    _priceController.dispose();
    _ownerCountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _populateFormWithAd(CarAd ad) {
    setState(() {
      _titleController.text = ad.title;
      _descriptionController.text = ad.description;
      _yearController.text = ad.year.toString();
      _horsepowerController.text = ad.horsepower.toString();
      _displacementController.text = ad.displacement.toString();
      _mileageController.text = ad.mileage.toString();
      _priceController.text = ad.price.toString();
      _ownerCountController.text = ad.ownerCount.toString();
      _phoneController.text = ad.phone;
      
      _selectedBrand = ad.make;
      _selectedModel = ad.model;
      _selectedColor = ad.color;
      _selectedTransmissionType = ad.transmissionType;
      _selectedFuelType = ad.fuelType;
      _selectedBodyType = ad.bodyType;
      _selectedSteeringPosition = ad.steeringPosition;
      _selectedCylinderCount = ad.cylinderCount;
      _selectedDriveType = ad.driveType;
      _selectedCarCondition = ad.carCondition;
      _selectedDoorCount = ad.doorCount;
      _selectedRegion = ad.region;
      _selectedCity = ad.city;
      _selectedFeatures = List.from(ad.features);
      _existingImages = List.from(ad.imageUrls);
    });
    
    // Load models for the selected brand
    if (ad.make.isNotEmpty) {
      _loadModels(ad.make);
    }
    
    // Load cities for the selected region
    if (ad.region != null && ad.region!.isNotEmpty) {
      final region = _regions.firstWhere(
        (r) => r['name'] == ad.region,
        orElse: () => {},
      );
      if (region.isNotEmpty) {
        _selectedRegionId = region['id']?.toString();
        _loadCities(_selectedRegionId!);
      }
    }
  }

  Future<void> _loadDropdownData() async {
    try {
      final futures = await Future.wait([
        _dropdownService.getFeatures(),
        _dropdownService.getTransmissionTypes(),
        _dropdownService.getFuelTypes(),
        _dropdownService.getBodyTypes(),
        _dropdownService.getSteeringPositions(),
        _dropdownService.getCylinderCounts(),
        _dropdownService.getDriveTypes(),
        _dropdownService.getCarConditions(),
        _dropdownService.getDoorCounts(),
        _dropdownService.getBrands(),
        _dropdownService.getRegions(),
        _dropdownService.getColors(),
      ]);
      
      if (mounted) {
        setState(() {
          _features = futures[0] as List<String>;
          _transmissionTypes = futures[1] as List<String>;
          _fuelTypes = futures[2] as List<String>;
          _bodyTypes = futures[3] as List<String>;
          _steeringPositions = futures[4] as List<String>;
          _cylinderCounts = futures[5] as List<String>;
          _driveTypes = futures[6] as List<String>;
          _carConditions = futures[7] as List<String>;
          _doorCounts = futures[8] as List<String>;
          _brands = futures[9] as List<String>;
          _regions = futures[10] as List<Map<String, dynamic>>;
          _colors = futures[11] as List<String>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dropdown data: $e')),
        );
      }
    }
  }

  Future<void> _loadCities(String regionId) async {
    setState(() => _cities = []);
    try {
      final cities = await _dropdownService.getCitiesByRegion(regionId);
      if (mounted) {
        setState(() => _cities = cities);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cities = []);
      }
    }
  }

  Future<void> _loadModels(String brandName) async {
    setState(() => _models = []);
    try {
      final response = await _dropdownService.dio.get('${_dropdownService.baseUrl}/brands');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final brand = data.firstWhere((b) => b['brandName'] == brandName, orElse: () => null);
        if (brand != null) {
          final models = await _dropdownService.getModels(brand['id'].toString());
          if (mounted) {
            setState(() => _models = models);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _models = []);
      }
    }
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _newImages.addAll(images);
      });
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  void _removeExistingImage(String imageUrl) {
    setState(() {
      _existingImages.remove(imageUrl);
      _imagesToDelete.add(imageUrl);
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final adData = {
        'make': _selectedBrand,
        'model': _selectedModel,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'year': int.parse(_yearController.text),
        'color': _selectedColor,
        'horsepower': int.parse(_horsepowerController.text),
        'displacement': int.parse(_displacementController.text),
        'mileage': int.parse(_mileageController.text),
        'price': int.parse(_priceController.text),
        'doorCount': _selectedDoorCount,
        'ownerCount': int.parse(_ownerCountController.text),
        'phone': _phoneController.text,
        'region': _selectedRegion,
        'city': _selectedCity,
        'features': _selectedFeatures,
        'transmissionType': _selectedTransmissionType,
        'fuelType': _selectedFuelType,
        'bodyType': _selectedBodyType,
        'steeringPosition': _selectedSteeringPosition,
        'cylinderCount': _selectedCylinderCount,
        'driveType': _selectedDriveType,
        'condition': _selectedCarCondition,
      };

      context.read<EditAdBloc>().add(EditAdSubmit(
        adId: widget.adId,
        adData: adData,
        newImages: _newImages,
        imagesToDelete: _imagesToDelete,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактирай обява'),
        actions: [
          TextButton(
            onPressed: _submitForm,
            child: const Text(
              'Запази',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: BlocListener<EditAdBloc, EditAdState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == EditAdStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Обявата е обновена успешно!')),
            );
            // Return true to indicate the ad was successfully updated
            Navigator.of(context).pop(true);
          } else if (state.status == EditAdStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Неуспешно обновяване на обява')),
            );
          }
        },
        child: BlocBuilder<EditAdBloc, EditAdState>(
          builder: (context, state) {
            if (state.status == EditAdStatus.loading || _isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == EditAdStatus.loaded && state.ad != null && !_isFormPopulated) {
              // Populate form when ad is loaded (only once)
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _populateFormWithAd(state.ad!);
                _isFormPopulated = true;
              });
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Images section
                    AdImageSection(
                      existingImages: _existingImages,
                      newImages: _newImages,
                      isEditing: true,
                      onAddImages: _pickImages,
                      onRemoveExistingImage: _removeExistingImage,
                      onRemoveNewImage: _removeNewImage,
                    ),
                    const SizedBox(height: 16),
                    
                    // Basic info
                    AdBasicInfoSection(
                      titleController: _titleController,
                      descriptionController: _descriptionController,
                      brands: _brands,
                      models: _models,
                      colors: _colors,
                      selectedBrand: _selectedBrand,
                      selectedModel: _selectedModel,
                      selectedColor: _selectedColor,
                      onBrandChanged: (value) {
                        setState(() {
                          _selectedBrand = value;
                          _selectedModel = null;
                          _models = [];
                        });
                        if (value != null) {
                          _loadModels(value);
                        }
                      },
                      onModelChanged: (value) {
                        setState(() => _selectedModel = value);
                      },
                      onColorChanged: (value) {
                        setState(() => _selectedColor = value);
                      },
                      onTitleChanged: (value) {
                        // Title is already handled by controller
                      },
                      onDescriptionChanged: (value) {
                        // Description is already handled by controller
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Technical specs
                    AdTechnicalSpecsSection(
                      yearController: _yearController,
                      horsepowerController: _horsepowerController,
                      displacementController: _displacementController,
                      mileageController: _mileageController,
                      priceController: _priceController,
                      ownerCountController: _ownerCountController,
                      transmissionTypes: _transmissionTypes,
                      fuelTypes: _fuelTypes,
                      bodyTypes: _bodyTypes,
                      steeringPositions: _steeringPositions,
                      cylinderCounts: _cylinderCounts,
                      driveTypes: _driveTypes,
                      carConditions: _carConditions,
                      doorCounts: _doorCounts,
                      selectedTransmissionType: _selectedTransmissionType,
                      selectedFuelType: _selectedFuelType,
                      selectedBodyType: _selectedBodyType,
                      selectedSteeringPosition: _selectedSteeringPosition,
                      selectedCylinderCount: _selectedCylinderCount,
                      selectedDriveType: _selectedDriveType,
                      selectedCarCondition: _selectedCarCondition,
                      selectedDoorCount: _selectedDoorCount,
                      onTransmissionTypeChanged: (value) {
                        setState(() => _selectedTransmissionType = value);
                      },
                      onFuelTypeChanged: (value) {
                        setState(() => _selectedFuelType = value);
                      },
                      onBodyTypeChanged: (value) {
                        setState(() => _selectedBodyType = value);
                      },
                      onSteeringPositionChanged: (value) {
                        setState(() => _selectedSteeringPosition = value);
                      },
                      onCylinderCountChanged: (value) {
                        setState(() => _selectedCylinderCount = value);
                      },
                      onDriveTypeChanged: (value) {
                        setState(() => _selectedDriveType = value);
                      },
                      onCarConditionChanged: (value) {
                        setState(() => _selectedCarCondition = value);
                      },
                      onDoorCountChanged: (value) {
                        setState(() => _selectedDoorCount = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Features
                    AdFeaturesSection(
                      features: _features,
                      selectedFeatures: _selectedFeatures,
                      onFeaturesChanged: (features) {
                        setState(() => _selectedFeatures = features);
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Location
                    AdLocationSection(
                      regions: _regions,
                      cities: _cities,
                      selectedRegion: _selectedRegion,
                      selectedCity: _selectedCity,
                      onRegionChanged: (regionName) async {
                        setState(() {
                          _selectedRegion = regionName;
                          _selectedCity = null;
                          _cities = [];
                        });
                        
                        if (regionName != null) {
                          final region = _regions.firstWhere((r) => r['name'] == regionName, orElse: () => {});
                          final regionId = region['id']?.toString();
                          if (regionId != null) {
                            _selectedRegionId = regionId;
                            await _loadCities(regionId);
                          }
                        }
                      },
                      onCityChanged: (cityName) {
                        setState(() => _selectedCity = cityName);
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Contact
                    AdContactSection(
                      phoneController: _phoneController,
                      onPhoneChanged: (value) {
                        // Phone is already handled by controller
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

}
