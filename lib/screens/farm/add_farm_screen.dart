import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../constants/app_constants.dart';
import '../../models/farm_model.dart';
import '../../providers/farm_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_overlay.dart';

class AddFarmScreen extends StatefulWidget {
  static const String routeName = '/add-farm';

  const AddFarmScreen({super.key});

  @override
  State<AddFarmScreen> createState() => _AddFarmScreenState();
}

class _AddFarmScreenState extends State<AddFarmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _areaController = TextEditingController();
  
  String? _selectedCropType;
  bool _isEditing = false;
  Farm? _farmToEdit;
  bool _isLoadingLocation = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Check if we're editing an existing farm
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Farm) {
      _farmToEdit = args;
      _isEditing = true;
      _populateFields();
    }
  }

  void _populateFields() {
    if (_farmToEdit != null) {
      _nameController.text = _farmToEdit!.name;
      _descriptionController.text = _farmToEdit!.description ?? '';
      _latitudeController.text = _farmToEdit!.latitude.toString();
      _longitudeController.text = _farmToEdit!.longitude.toString();
      _areaController.text = _farmToEdit!.area?.toString() ?? '';
      _selectedCropType = _farmToEdit!.cropType;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Check if location is within Sub-Saharan Africa
      if (!FarmProvider.isValidCoordinates(position.latitude, position.longitude)) {
        throw Exception('Location is outside Sub-Saharan Africa region');
      }

      setState(() {
        _latitudeController.text = position.latitude.toStringAsFixed(6);
        _longitudeController.text = position.longitude.toStringAsFixed(6);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    
    final latitude = double.parse(_latitudeController.text);
    final longitude = double.parse(_longitudeController.text);
    final area = _areaController.text.isEmpty ? null : double.parse(_areaController.text);

    bool success;
    
    if (_isEditing && _farmToEdit != null) {
      success = await farmProvider.updateFarm(
        _farmToEdit!.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        latitude: latitude,
        longitude: longitude,
        area: area,
        cropType: _selectedCropType,
      );
    } else {
      success = await farmProvider.createFarm(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        latitude: latitude,
        longitude: longitude,
        area: area,
        cropType: _selectedCropType,
      );
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? AppConstants.farmUpdatedMessage : AppConstants.farmCreatedMessage),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(farmProvider.errorMessage ?? 'Failed to save farm'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Farm' : 'Add New Farm'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<FarmProvider>(
        builder: (context, farmProvider, child) {
          return LoadingOverlay(
            isLoading: farmProvider.isLoading || _isLoadingLocation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _isEditing ? Icons.edit : Icons.add_location,
                            size: 48,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            _isEditing ? 'Update Farm Details' : 'Add Your Farm',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            _isEditing 
                                ? 'Modify the farm information below'
                                : 'Enter your farm details to start soil analysis',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Farm Name
                    CustomTextField(
                      controller: _nameController,
                      label: 'Farm Name',
                      prefixIcon: Icons.agriculture,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      validator: FarmProvider.validateFarmName,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    // Description
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Description (Optional)',
                      prefixIcon: Icons.description,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      maxLines: 3,
                      validator: FarmProvider.validateDescription,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    // Location Section
                    Text(
                      'Location',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    
                    // Get Current Location Button
                    CustomButton(
                      text: 'Use Current Location',
                      onPressed: _getCurrentLocation,
                      type: ButtonType.outline,
                      icon: Icons.my_location,
                      isLoading: _isLoadingLocation,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    // Latitude and Longitude
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _latitudeController,
                            label: 'Latitude',
                            prefixIcon: Icons.location_on,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textInputAction: TextInputAction.next,
                            validator: FarmProvider.validateLatitude,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: CustomTextField(
                            controller: _longitudeController,
                            label: 'Longitude',
                            prefixIcon: Icons.location_on,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textInputAction: TextInputAction.next,
                            validator: FarmProvider.validateLongitude,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    // Area
                    CustomTextField(
                      controller: _areaController,
                      label: 'Area (hectares) - Optional',
                      prefixIcon: Icons.landscape,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.next,
                      validator: FarmProvider.validateArea,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    // Crop Type
                    DropdownButtonFormField<String>(
                      value: _selectedCropType,
                      decoration: InputDecoration(
                        labelText: 'Crop Type (Optional)',
                        prefixIcon: const Icon(Icons.eco),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: CropTypes.commonCrops.map((cropType) {
                        return DropdownMenuItem<String>(
                          value: cropType,
                          child: Text(cropType),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCropType = value;
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Submit Button
                    CustomButton(
                      text: _isEditing ? 'Update Farm' : 'Add Farm',
                      onPressed: _handleSubmit,
                      isLoading: farmProvider.isLoading,
                      icon: _isEditing ? Icons.update : Icons.add,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    // Cancel Button
                    CustomButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.of(context).pop(),
                      type: ButtonType.outline,
                    ),
                    
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[700],
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Your farm location must be within Sub-Saharan Africa for soil analysis to work properly.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

