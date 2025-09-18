import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/services/image_upload_service.dart';
import '../../../data/services/dropdown_data_service.dart';
import '../../widgets/ad_form/ad_form_sections.dart';
import 'bloc/create_ad_bloc.dart';
import 'bloc/create_ad_event.dart';
import 'bloc/create_ad_state.dart';

class CreateAdPage extends StatelessWidget {
  const CreateAdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateAdBloc(
        imageUploadService: ImageUploadService(),
      ),
      child: const CreateAdView(),
    );
  }
}

class CreateAdView extends StatefulWidget {
  const CreateAdView({super.key});

  @override
  State<CreateAdView> createState() => _CreateAdViewState();
}

class _CreateAdViewState extends State<CreateAdView> {
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
  List<String> _selectedFeatures = [];
  
  bool _isLoading = true;
  List<XFile> _selectedImages = [];

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
    if (images.isNotEmpty && mounted) {
      setState(() {
        _selectedImages.addAll(images);
      });
      // Update bloc state
      final files = images.map((xFile) => File(xFile.path)).toList();
      context.read<CreateAdBloc>().add(CreateAdImagesAdded(files));
    }
  }

  void _removeImage(int index) {
    final imageToRemove = _selectedImages[index];
    setState(() {
      _selectedImages.removeAt(index);
    });
    // Update bloc state
    context.read<CreateAdBloc>().add(CreateAdImageRemoved(File(imageToRemove.path)));
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Update all form values in the bloc
      context.read<CreateAdBloc>().add(CreateAdTitleChanged(_titleController.text));
      context.read<CreateAdBloc>().add(CreateAdDescriptionChanged(_descriptionController.text));
      if (_selectedBrand != null) context.read<CreateAdBloc>().add(CreateAdMakeChanged(_selectedBrand!));
      if (_selectedModel != null) context.read<CreateAdBloc>().add(CreateAdModelChanged(_selectedModel!));
      if (_selectedColor != null) context.read<CreateAdBloc>().add(CreateAdColorChanged(_selectedColor!));
      context.read<CreateAdBloc>().add(CreateAdYearChanged(int.tryParse(_yearController.text) ?? 2024));
      context.read<CreateAdBloc>().add(CreateAdHpChanged(int.tryParse(_horsepowerController.text) ?? 0));
      context.read<CreateAdBloc>().add(CreateAdDisplacementChanged(int.tryParse(_displacementController.text) ?? 0));
      context.read<CreateAdBloc>().add(CreateAdMileageChanged(int.tryParse(_mileageController.text) ?? 0));
      context.read<CreateAdBloc>().add(CreateAdPriceChanged(int.tryParse(_priceController.text) ?? 0));
      context.read<CreateAdBloc>().add(CreateAdOwnerCountChanged(int.tryParse(_ownerCountController.text) ?? 0));
      context.read<CreateAdBloc>().add(CreateAdPhoneChanged(_phoneController.text));
      if (_selectedRegion != null) context.read<CreateAdBloc>().add(CreateAdRegionChanged(_selectedRegion!));
      if (_selectedCity != null) context.read<CreateAdBloc>().add(CreateAdCityChanged(_selectedCity!));
      if (_selectedDoorCount != null) context.read<CreateAdBloc>().add(CreateAdDoorCountChanged(_selectedDoorCount!));
      if (_selectedTransmissionType != null) context.read<CreateAdBloc>().add(CreateAdTransmissionTypeChanged(_selectedTransmissionType!));
      if (_selectedFuelType != null) context.read<CreateAdBloc>().add(CreateAdFuelTypeChanged(_selectedFuelType!));
      if (_selectedBodyType != null) context.read<CreateAdBloc>().add(CreateAdBodyTypeChanged(_selectedBodyType!));
      if (_selectedSteeringPosition != null) context.read<CreateAdBloc>().add(CreateAdSteeringPositionChanged(_selectedSteeringPosition!));
      if (_selectedCylinderCount != null) context.read<CreateAdBloc>().add(CreateAdCylinderCountChanged(_selectedCylinderCount!));
      if (_selectedDriveType != null) context.read<CreateAdBloc>().add(CreateAdDriveTypeChanged(_selectedDriveType!));
      if (_selectedCarCondition != null) context.read<CreateAdBloc>().add(CreateAdConditionChanged(_selectedCarCondition!));
      context.read<CreateAdBloc>().add(CreateAdFeaturesChanged(_selectedFeatures));
      
      // Submit the form
      context.read<CreateAdBloc>().add(const CreateAdSubmitted());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Създай нова обява'),
        actions: [
          TextButton(
            onPressed: _submitForm,
            child: const Text(
              'Създай',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: BlocListener<CreateAdBloc, CreateAdState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == CreateAdStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Обявата е създадена успешно!')),
            );
            Navigator.of(context).pop();
          } else if (state.status == CreateAdStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Неуспешно създаване на обява')),
            );
          }
        },
        child: BlocBuilder<CreateAdBloc, CreateAdState>(
          builder: (context, state) {
            if (state.status == CreateAdStatus.uploading) {
              return const Center(child: CircularProgressIndicator());
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
                      newImages: _selectedImages,
                      isEditing: false,
                      onAddImages: _pickImages,
                      onRemoveExistingImage: (_) {}, // Not used in create mode
                      onRemoveNewImage: _removeImage,
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
                        // Title is handled by controller
                      },
                      onDescriptionChanged: (value) {
                        // Description is handled by controller
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
                        // Phone is handled by controller
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
