import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../models/soil_analysis_model.dart';
import '../services/api_service.dart';
import '../utils/logger.dart';

enum SoilAnalysisState {
  initial,
  loading,
  loaded,
  analyzing,
  error,
}

class SoilAnalysisProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  SoilAnalysisState _state = SoilAnalysisState.initial;
  List<SoilAnalysis> _analyses = [];
  SoilAnalysis? _currentAnalysis;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isAnalyzing = false;

  // Getters
  SoilAnalysisState get state => _state;
  List<SoilAnalysis> get analyses => _analyses;
  SoilAnalysis? get currentAnalysis => _currentAnalysis;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAnalyzing => _isAnalyzing;
  bool get hasAnalyses => _analyses.isNotEmpty;

  // Initialize soil analyses
  Future<void> initialize() async {
    await loadAnalyses();
  }

  // Load all soil analyses
  Future<void> loadAnalyses() async {
    _setLoading(true);
    _clearError();

    try {
      final response =
          await _apiService.getAllUserSoilAnalyses(); // Get all analyses

      final analysesList = response['analyses'] as List?;

    _analyses = analysesList
        ?.map((json) => SoilAnalysis.fromJson(json))
        .toList() ?? [];
      _setState(SoilAnalysisState.loaded);

      AppLogger.info('Loaded ${_analyses.length} total soil analyses for the user');
    } catch (e) {
      _setError(e.toString());
      AppLogger.error('Failed to load soil analyses: $e, stack: ${StackTrace.current}');
    } finally {
      _setLoading(false);
    }
  }

  // Load analyses for a specific farm
  Future<void> loadAnalysesForFarm(int farmId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.getFarmSoilAnalyses(farmId);
      _analyses = (response['analyses'] as List?)
              ?.map((json) => SoilAnalysis.fromJson(json))
              .toList() ??
          [];
      _setState(SoilAnalysisState.loaded);

      AppLogger.info(
          'Loaded ${_analyses.length} soil analyses for farm $farmId');
    } catch (e) {
      _setError(e.toString());
      AppLogger.error('Failed to load soil analyses for farm $farmId: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Perform soil analysis
  Future<bool> performSoilAnalysis({
    required int farmId,
    required double latitude,
    required double longitude,
  }) async {
    _setAnalyzing(true);
    _clearError();

    try {
      final request = {
        'farmId': farmId,
        'latitude': latitude,
        'longitude': longitude,
        'depth': '0-20',
      };

      final response = await _apiService.analyzeSoil(farmId, request);

        AppLogger.debug('API Response for new analysis: $response');

      // Add the new analysis to the list
      final analysis = SoilAnalysis.fromJson(response);
      _analyses.insert(0, analysis);
      _currentAnalysis = analysis;
      _setState(SoilAnalysisState.loaded);

      AppLogger.info('Soil analysis completed for farm $farmId');
      return true;
    } catch (e) {
      _setError(e.toString());
      AppLogger.error('Failed to perform soil analysis: $e');
      return false;
    } finally {
      _setAnalyzing(false);
    }
  }

  // Get a specific soil analysis
  Future<SoilAnalysis?> getSoilAnalysis(int analysisId) async {
    try {
      final response = await _apiService.getSoilAnalysis(analysisId);
      final analysis = SoilAnalysis.fromJson(response);

      // Update the analysis in the list if it exists
      final index = _analyses.indexWhere((a) => a.id == analysisId);
      if (index != -1) {
        _analyses[index] = analysis;
        notifyListeners();
      }

      return analysis;
    } catch (e) {
      AppLogger.error('Failed to get soil analysis: $e');
      return null;
    }
  }

  // Select a soil analysis
  void selectAnalysis(SoilAnalysis analysis) {
    _currentAnalysis = analysis;
    notifyListeners();
    AppLogger.debug('Selected soil analysis: ${analysis.id}');
  }

  // Clear selected analysis
  void clearSelectedAnalysis() {
    _currentAnalysis = null;
    notifyListeners();
  }

  // Get analysis by ID
  SoilAnalysis? getAnalysisById(int analysisId) {
    try {
      return _analyses.firstWhere((analysis) => analysis.id == analysisId);
    } catch (e) {
      return null;
    }
  }

  // Get analyses for a specific farm
  List<SoilAnalysis> getAnalysesForFarm(int farmId) {
    return _analyses.where((analysis) => analysis.farmId == farmId).toList();
  }

  // Get latest analysis for a farm
  SoilAnalysis? getLatestAnalysisForFarm(int farmId) {
    final farmAnalyses = getAnalysesForFarm(farmId);
    if (farmAnalyses.isEmpty) return null;

    farmAnalyses.sort((a, b) => b.analysisDate.compareTo(a.analysisDate));
    return farmAnalyses.first;
  }

  // Search analyses
  List<SoilAnalysis> searchAnalyses(String query) {
    if (query.isEmpty) return _analyses;

    final lowercaseQuery = query.toLowerCase();
    return _analyses.where((analysis) {
      return analysis.healthScore.overallRating
              .toLowerCase()
              .contains(lowercaseQuery) ||
          analysis.formattedCoordinates.contains(lowercaseQuery) ||
          analysis.recommendations.any((rec) =>
              rec.title.toLowerCase().contains(lowercaseQuery) ||
              rec.description.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  // Filter analyses by health level
  List<SoilAnalysis> filterAnalysesByHealthLevel(SoilHealthLevel healthLevel) {
    return _analyses
        .where((analysis) => analysis.healthScore.healthLevel == healthLevel)
        .toList();
  }

  // Filter analyses by date range
  List<SoilAnalysis> filterAnalysesByDateRange(
      DateTime startDate, DateTime endDate) {
    return _analyses.where((analysis) {
      return analysis.analysisDate.isAfter(startDate) &&
          analysis.analysisDate.isBefore(endDate);
    }).toList();
  }

  // Get analyses with high priority recommendations
  List<SoilAnalysis> getAnalysesWithHighPriorityRecommendations() {
    return _analyses
        .where((analysis) => analysis.highPriorityRecommendations.isNotEmpty)
        .toList();
  }

  // Get soil health statistics
  Map<String, dynamic> getSoilHealthStatistics() {
    if (_analyses.isEmpty) {
      return {
        'averageHealth': 0.0,
        'excellentCount': 0,
        'goodCount': 0,
        'fairCount': 0,
        'poorCount': 0,
        'veryPoorCount': 0,
        'totalAnalyses': 0,
      };
    }

    final totalHealth = _analyses.fold(
        0.0, (sum, analysis) => sum + analysis.healthScore.overall);
    final averageHealth = totalHealth / _analyses.length;

    final healthCounts = <SoilHealthLevel, int>{};
    for (final level in SoilHealthLevel.values) {
      healthCounts[level] = _analyses
          .where((analysis) => analysis.healthScore.healthLevel == level)
          .length;
    }

    return {
      'averageHealth': averageHealth,
      'excellentCount': healthCounts[SoilHealthLevel.excellent] ?? 0,
      'goodCount': healthCounts[SoilHealthLevel.good] ?? 0,
      'fairCount': healthCounts[SoilHealthLevel.fair] ?? 0,
      'poorCount': healthCounts[SoilHealthLevel.poor] ?? 0,
      'veryPoorCount': healthCounts[SoilHealthLevel.veryPoor] ?? 0,
      'totalAnalyses': _analyses.length,
    };
  }

  // Get recommendation statistics
  Map<String, dynamic> getRecommendationStatistics() {
    if (_analyses.isEmpty) {
      return {
        'totalRecommendations': 0,
        'highPriorityCount': 0,
        'mediumPriorityCount': 0,
        'lowPriorityCount': 0,
        'typeDistribution': <String, int>{},
      };
    }

    final allRecommendations =
        _analyses.expand((analysis) => analysis.recommendations).toList();

    final priorityCounts = <RecommendationPriority, int>{};
    final typeCounts = <RecommendationType, int>{};

    for (final rec in allRecommendations) {
      priorityCounts[rec.priority] = (priorityCounts[rec.priority] ?? 0) + 1;
      typeCounts[rec.type] = (typeCounts[rec.type] ?? 0) + 1;
    }

    return {
      'totalRecommendations': allRecommendations.length,
      'highPriorityCount': priorityCounts[RecommendationPriority.high] ?? 0,
      'mediumPriorityCount': priorityCounts[RecommendationPriority.medium] ?? 0,
      'lowPriorityCount': priorityCounts[RecommendationPriority.low] ?? 0,
      'typeDistribution': typeCounts
          .map((key, value) => MapEntry(key.toString().split('.').last, value)),
    };
  }

  // Get recent analyses (last 30 days)
  List<SoilAnalysis> getRecentAnalyses() {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return _analyses
        .where((analysis) => analysis.analysisDate.isAfter(thirtyDaysAgo))
        .toList();
  }

  // Refresh analyses
  Future<void> refresh() async {
    await loadAnalyses();
  }

  // Private methods
  void _setState(SoilAnalysisState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setAnalyzing(bool analyzing) {
    _isAnalyzing = analyzing;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _setState(SoilAnalysisState.error);
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Validation methods
  static String? validateCoordinates(double latitude, double longitude) {
    if (latitude < AppConstants.subSaharanMinLatitude ||
        latitude > AppConstants.subSaharanMaxLatitude) {
      return 'Latitude must be within Sub-Saharan Africa bounds';
    }

    if (longitude < AppConstants.subSaharanMinLongitude ||
        longitude > AppConstants.subSaharanMaxLongitude) {
      return 'Longitude must be within Sub-Saharan Africa bounds';
    }

    return null;
  }

  static bool isValidLocation(double latitude, double longitude) {
    return latitude >= AppConstants.subSaharanMinLatitude &&
        latitude <= AppConstants.subSaharanMaxLatitude &&
        longitude >= AppConstants.subSaharanMinLongitude &&
        longitude <= AppConstants.subSaharanMaxLongitude;
  }

  // Helper methods for UI
  String getHealthLevelDescription(SoilHealthLevel level) {
    switch (level) {
      case SoilHealthLevel.excellent:
        return 'Soil is in excellent condition with optimal nutrient levels and structure.';
      case SoilHealthLevel.good:
        return 'Soil is in good condition with minor improvements needed.';
      case SoilHealthLevel.fair:
        return 'Soil condition is fair and would benefit from targeted improvements.';
      case SoilHealthLevel.poor:
        return 'Soil condition is poor and requires significant improvements.';
      case SoilHealthLevel.veryPoor:
        return 'Soil condition is very poor and needs immediate attention.';
    }
  }

  String getPropertyStatusDescription(
      SoilPropertyStatus status, String property) {
    switch (status) {
      case SoilPropertyStatus.low:
        return '$property levels are below optimal range.';
      case SoilPropertyStatus.optimal:
        return '$property levels are within optimal range.';
      case SoilPropertyStatus.high:
        return '$property levels are above optimal range.';
    }
  }
}
