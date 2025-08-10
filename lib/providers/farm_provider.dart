import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../models/farm_model.dart';
import '../services/api_service.dart';
import '../utils/logger.dart';

enum FarmState {
  initial,
  loading,
  loaded,
  error,
}

class FarmProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  FarmState _state = FarmState.initial;
  List<Farm> _farms = [];
  Farm? _selectedFarm;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  FarmState get state => _state;
  List<Farm> get farms => _farms;
  Farm? get selectedFarm => _selectedFarm;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get hasFarms => _farms.isNotEmpty;

  // Initialize farms
  Future<void> initialize() async {
    await loadFarms();
  }

  // Load all farms
  Future<void> loadFarms() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.getFarms();
      _farms = response.farms;
      _setState(FarmState.loaded);
      
      AppLogger.info('Loaded ${_farms.length} farms');
    } catch (e) {
      _setError(e.toString());
      AppLogger.error('Failed to load farms: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create a new farm
  Future<bool> createFarm({
    required String name,
    String? description,
    required double latitude,
    required double longitude,
    double? area,
    String? cropType,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final request = CreateFarmRequest(
        name: name,
        description: description,
        latitude: latitude,
        longitude: longitude,
        area: area,
        cropType: cropType,
      );
      
      final response = await _apiService.createFarm(request);
      _farms.add(response.farm);
      _setState(FarmState.loaded);
      
      AppLogger.info('Farm created successfully: ${response.farm.name}');
      return true;
    } catch (e) {
      _setError(e.toString());
      AppLogger.error('Failed to create farm: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing farm
  Future<bool> updateFarm(
    int farmId, {
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    double? area,
    String? cropType,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final request = UpdateFarmRequest(
        name: name,
        description: description,
        latitude: latitude,
        longitude: longitude,
        area: area,
        cropType: cropType,
      );
      
      final response = await _apiService.updateFarm(farmId, request);
      
      // Update the farm in the list
      final index = _farms.indexWhere((farm) => farm.id == farmId);
      if (index != -1) {
        _farms[index] = response.farm;
        
        // Update selected farm if it's the one being updated
        if (_selectedFarm?.id == farmId) {
          _selectedFarm = response.farm;
        }
        
        notifyListeners();
      }
      
      AppLogger.info('Farm updated successfully: ${response.farm.name}');
      return true;
    } catch (e) {
      _setError(e.toString());
      AppLogger.error('Failed to update farm: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a farm
  Future<bool> deleteFarm(int farmId) async {
    _setLoading(true);
    _clearError();

    try {
      await _apiService.deleteFarm(farmId);
      
      // Remove the farm from the list
      _farms.removeWhere((farm) => farm.id == farmId);
      
      // Clear selected farm if it's the one being deleted
      if (_selectedFarm?.id == farmId) {
        _selectedFarm = null;
      }
      
      _setState(FarmState.loaded);
      
      AppLogger.info('Farm deleted successfully');
      return true;
    } catch (e) {
      _setError(e.toString());
      AppLogger.error('Failed to delete farm: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get a specific farm
  Future<Farm?> getFarm(int farmId) async {
    try {
      final farm = await _apiService.getFarm(farmId);
      
      // Update the farm in the list if it exists
      final index = _farms.indexWhere((f) => f.id == farmId);
      if (index != -1) {
        _farms[index] = farm;
        notifyListeners();
      }
      
      return farm;
    } catch (e) {
      AppLogger.error('Failed to get farm: $e');
      return null;
    }
  }

  // Select a farm
  void selectFarm(Farm farm) {
    _selectedFarm = farm;
    notifyListeners();
    AppLogger.debug('Selected farm: ${farm.name}');
  }

  // Clear selected farm
  void clearSelectedFarm() {
    _selectedFarm = null;
    notifyListeners();
  }

  // Get farm by ID
  Farm? getFarmById(int farmId) {
    try {
      return _farms.firstWhere((farm) => farm.id == farmId);
    } catch (e) {
      return null;
    }
  }

  // Search farms
  List<Farm> searchFarms(String query) {
    if (query.isEmpty) return _farms;
    
    final lowercaseQuery = query.toLowerCase();
    return _farms.where((farm) {
      return farm.name.toLowerCase().contains(lowercaseQuery) ||
             (farm.description?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             (farm.cropType?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  // Filter farms by crop type
  List<Farm> filterFarmsByCropType(String cropType) {
    return _farms.where((farm) => farm.cropType == cropType).toList();
  }

  // Get farms within a certain area range
  List<Farm> getFarmsByAreaRange(double minArea, double maxArea) {
    return _farms.where((farm) {
      if (farm.area == null) return false;
      return farm.area! >= minArea && farm.area! <= maxArea;
    }).toList();
  }

  // Get total area of all farms
  double get totalFarmArea {
    return _farms.fold(0.0, (sum, farm) => sum + (farm.area ?? 0.0));
  }

  // Get unique crop types
  List<String> get uniqueCropTypes {
    final cropTypes = _farms
        .where((farm) => farm.cropType != null)
        .map((farm) => farm.cropType!)
        .toSet()
        .toList();
    cropTypes.sort();
    return cropTypes;
  }

  // Refresh farms
  Future<void> refresh() async {
    await loadFarms();
  }

  // Private methods
  void _setState(FarmState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _setState(FarmState.error);
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Validation methods
  static String? validateFarmName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Farm name is required';
    }
    if (name.length > AppConstants.maxFarmNameLength) {
      return 'Farm name must be less than ${AppConstants.maxFarmNameLength} characters';
    }
    return null;
  }

  static String? validateDescription(String? description) {
    if (description != null && description.length > AppConstants.maxDescriptionLength) {
      return 'Description must be less than ${AppConstants.maxDescriptionLength} characters';
    }
    return null;
  }

  static String? validateLatitude(String? latitude) {
    if (latitude == null || latitude.isEmpty) {
      return 'Latitude is required';
    }
    
    final lat = double.tryParse(latitude);
    if (lat == null) {
      return 'Please enter a valid latitude';
    }
    
    if (lat < AppConstants.minLatitude || lat > AppConstants.maxLatitude) {
      return 'Latitude must be between ${AppConstants.minLatitude} and ${AppConstants.maxLatitude}';
    }
    
    // Check if within Sub-Saharan Africa bounds
    if (lat < AppConstants.subSaharanMinLatitude || lat > AppConstants.subSaharanMaxLatitude) {
      return 'Location must be within Sub-Saharan Africa';
    }
    
    return null;
  }

  static String? validateLongitude(String? longitude) {
    if (longitude == null || longitude.isEmpty) {
      return 'Longitude is required';
    }
    
    final lng = double.tryParse(longitude);
    if (lng == null) {
      return 'Please enter a valid longitude';
    }
    
    if (lng < AppConstants.minLongitude || lng > AppConstants.maxLongitude) {
      return 'Longitude must be between ${AppConstants.minLongitude} and ${AppConstants.maxLongitude}';
    }
    
    // Check if within Sub-Saharan Africa bounds
    if (lng < AppConstants.subSaharanMinLongitude || lng > AppConstants.subSaharanMaxLongitude) {
      return 'Location must be within Sub-Saharan Africa';
    }
    
    return null;
  }

  static String? validateArea(String? area) {
    if (area == null || area.isEmpty) {
      return null; // Area is optional
    }
    
    final areaValue = double.tryParse(area);
    if (areaValue == null) {
      return 'Please enter a valid area';
    }
    
    if (areaValue <= 0) {
      return 'Area must be greater than 0';
    }
    
    if (areaValue > 10000) {
      return 'Area seems too large. Please check your input';
    }
    
    return null;
  }

  static bool isValidCoordinates(double latitude, double longitude) {
    return latitude >= AppConstants.subSaharanMinLatitude &&
           latitude <= AppConstants.subSaharanMaxLatitude &&
           longitude >= AppConstants.subSaharanMinLongitude &&
           longitude <= AppConstants.subSaharanMaxLongitude;
  }
}

