import 'package:json_annotation/json_annotation.dart';
import 'dart:developer';

part 'soil_analysis_model.g.dart';

@JsonSerializable()
class SoilAnalysis {
  final int id;
  final int farmId;
  final double latitude;
  final double longitude;
  final DateTime analysisDate;
  final SoilProperties properties;
  final SoilHealthScore healthScore;
  final List<Recommendation> recommendations;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SoilAnalysis({
    required this.id,
    required this.farmId,
    required this.latitude,
    required this.longitude,
    required this.analysisDate,
    required this.properties,
    required this.healthScore,
    required this.recommendations,
    required this.createdAt,
    required this.updatedAt,
  });

static double parseDouble(dynamic value, {double defaultValue = 0.0}) {
  if (value is num) {
    return value.toDouble();
  }
  // You could also log a warning here if you receive an unexpected type.
  return defaultValue;
}

// A safe parser for integers. Returns 0 if the value is null or not a number.
static int parseInt(dynamic value, {int defaultValue = 0}) {
  if (value is num) {
    return value.toInt();
  }
  return defaultValue;
}

factory SoilAnalysis.fromJson(Map<String, dynamic> json) {
  
  Map<String, dynamic> data;
  
  // Check if we are parsing the response from the CREATE endpoint...
  if (json.containsKey('analysis') && json['analysis'] is Map<String, dynamic>) {
    data = json['analysis']; // Use the nested object
  } 
  // ...or if we are parsing an object directly from the LIST endpoint.
  else {
    data = json; // Use the root object itself
  }
  // Safely access nested objects.

  final propertiesData = data['soil_properties'];
  if (propertiesData == null || propertiesData is! Map<String, dynamic>) {
    throw FormatException('The "analysis" object is missing "soil_properties".');
  }

  // Health score could be optional in case of a partial failure.
  // We use a nullable variable and check.
   final healthScoreData = json['health_score'] as Map<String, dynamic>? ?? data['health_score'] as Map<String, dynamic>?;

  // Recommendations could be optional. Default to an empty list if null.
  final recommendationsData = json['recommendations'] as List<dynamic>? ?? [];

  // Manual mapping for RecommendationPriority from an integer
  RecommendationPriority priorityFromInt(int priority) {
    switch (priority) {
      case 1:
        return RecommendationPriority.high;
      case 2:
        return RecommendationPriority.medium;
      case 3:
        return RecommendationPriority.low;
      default:
        log('Unknown recommendation priority: $priority. Defaulting to low.');
        return RecommendationPriority.low;
    }
  }

   return SoilAnalysis(
    id: parseInt(data['id']),
    farmId: parseInt(data['farm_id']),
    latitude: parseDouble(data['latitude']),
    longitude: parseDouble(data['longitude']),
    analysisDate: DateTime.parse(data['analyzed_at']),
    createdAt: DateTime.parse(data['created_at']),
    updatedAt: DateTime.parse(data['created_at']),

    properties: SoilProperties(
      ph: parseDouble(propertiesData['ph'][0]['value']['value']),
      organicCarbon: parseDouble(propertiesData['carbon_organic'][0]['value']['value']),
      nitrogen: parseDouble(propertiesData['nitrogen_total'][0]['value']['value']),
      phosphorus: parseDouble(propertiesData['phosphorous_extractable'][0]['value']['value']),
      potassium: parseDouble(propertiesData['potassium_extractable'][0]['value']['value']),
    ),

    healthScore: healthScoreData != null
        ? SoilHealthScore(
            overall: parseDouble(healthScoreData['overall_score']),
            ph: parseDouble(healthScoreData['property_scores']?['ph']?.toDouble(), defaultValue: 0.0),
          )
        : SoilHealthScore(overall: 0, ph: 0), // Default score if object is missing

    recommendations: recommendationsData.map((rec) {
      final recommendation = rec as Map<String, dynamic>;
      return Recommendation(
        id: parseInt(recommendation['id']),
        title: recommendation['title'],
        description: recommendation['description'],
        type: RecommendationType.values.byName(recommendation['type']),
        priority: priorityFromInt(parseInt(recommendation['priority'], defaultValue: 3)), // Default to low priority
        createdAt: DateTime.parse(recommendation['created_at']),
      );
    }).toList(),
  );
}

  Map<String, dynamic> toJson() => _$SoilAnalysisToJson(this);

  String get formattedCoordinates =>
      '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(analysisDate);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
  }

  List<Recommendation> get highPriorityRecommendations =>
      recommendations.where((r) => r.priority == RecommendationPriority.high).toList();

  List<Recommendation> get mediumPriorityRecommendations =>
      recommendations.where((r) => r.priority == RecommendationPriority.medium).toList();

  List<Recommendation> get lowPriorityRecommendations =>
      recommendations.where((r) => r.priority == RecommendationPriority.low).toList();
}

@JsonSerializable()
class SoilProperties {
  final double ph;
  final double organicCarbon;
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double? calcium;
  final double? magnesium;
  final double? sulfur;
  final double? zinc;
  final double? iron;
  final double? manganese;
  final double? copper;
  final double? boron;
  final double? clay;
  final double? sand;
  final double? silt;

  const SoilProperties({
    required this.ph,
    required this.organicCarbon,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    this.calcium,
    this.magnesium,
    this.sulfur,
    this.zinc,
    this.iron,
    this.manganese,
    this.copper,
    this.boron,
    this.clay,
    this.sand,
    this.silt,
  });

  factory SoilProperties.fromJson(Map<String, dynamic> json) =>
      _$SoilPropertiesFromJson(json);

  Map<String, dynamic> toJson() => _$SoilPropertiesToJson(this);

  // Soil property assessments
  SoilPropertyStatus get phStatus {
    if (ph < 5.5) return SoilPropertyStatus.low;
    if (ph > 7.5) return SoilPropertyStatus.high;
    return SoilPropertyStatus.optimal;
  }

  SoilPropertyStatus get organicCarbonStatus {
    if (organicCarbon < 1.0) return SoilPropertyStatus.low;
    if (organicCarbon > 3.0) return SoilPropertyStatus.high;
    return SoilPropertyStatus.optimal;
  }

  SoilPropertyStatus get nitrogenStatus {
    if (nitrogen < 0.1) return SoilPropertyStatus.low;
    if (nitrogen > 0.3) return SoilPropertyStatus.high;
    return SoilPropertyStatus.optimal;
  }

  SoilPropertyStatus get phosphorusStatus {
    if (phosphorus < 10) return SoilPropertyStatus.low;
    if (phosphorus > 50) return SoilPropertyStatus.high;
    return SoilPropertyStatus.optimal;
  }

  SoilPropertyStatus get potassiumStatus {
    if (potassium < 100) return SoilPropertyStatus.low;
    if (potassium > 300) return SoilPropertyStatus.high;
    return SoilPropertyStatus.optimal;
  }

  String get textureClass {
    if (clay != null && clay! > 40) return 'Clay';
    if (sand != null && sand! > 85) return 'Sand';
    if (silt != null && silt! > 80) return 'Silt';
    if (clay != null && sand != null && clay! > 27 && sand! < 45) return 'Clay Loam';
    if (clay != null && sand != null && clay! > 20 && sand! > 45) return 'Sandy Clay Loam';
    if (clay != null && sand != null && clay! < 20 && sand! > 52) return 'Sandy Loam';
    if (silt != null && clay != null && silt! > 50 && clay! < 27) return 'Silt Loam';
    return 'Loam';
  }
}

@JsonSerializable()
class SoilHealthScore {
  final double overall;
  final double? fertility;
  final double? structure;
  final double? organic;
  final double ph;

  const SoilHealthScore({
    required this.overall,
    this.fertility,
    this.structure,
    this.organic,
    required this.ph,
  });

  factory SoilHealthScore.fromJson(Map<String, dynamic> json) =>
      _$SoilHealthScoreFromJson(json);

  Map<String, dynamic> toJson() => _$SoilHealthScoreToJson(this);

  String get overallRating {
    if (overall >= 80) return 'Excellent';
    if (overall >= 60) return 'Good';
    if (overall >= 40) return 'Fair';
    if (overall >= 20) return 'Poor';
    return 'Very Poor';
  }

  SoilHealthLevel get healthLevel {
    if (overall >= 80) return SoilHealthLevel.excellent;
    if (overall >= 60) return SoilHealthLevel.good;
    if (overall >= 40) return SoilHealthLevel.fair;
    if (overall >= 20) return SoilHealthLevel.poor;
    return SoilHealthLevel.veryPoor;
  }
}

@JsonSerializable()
class Recommendation {
  final int id;
  final String title;
  final String description;
  final RecommendationType type;
  final RecommendationPriority priority;
  final String? actionSteps;
  final String? expectedOutcome;
  final int? timeframeWeeks;
  final double? estimatedCost;
  final DateTime createdAt;

  const Recommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    this.actionSteps,
    this.expectedOutcome,
    this.timeframeWeeks,
    this.estimatedCost,
    required this.createdAt,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) =>
      _$RecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$RecommendationToJson(this);

  String get priorityText {
    switch (priority) {
      case RecommendationPriority.high:
        return 'High Priority';
      case RecommendationPriority.medium:
        return 'Medium Priority';
      case RecommendationPriority.low:
        return 'Low Priority';
    }
  }

  String get typeText {
    switch (type) {
      case RecommendationType.fertilizer:
        return 'Fertilizer';
      case RecommendationType.liming:
        return 'Liming';
      case RecommendationType.organic:
        return 'Organic Matter';
      case RecommendationType.irrigation:
        return 'Irrigation';
      case RecommendationType.cultivation:
        return 'Cultivation';
      case RecommendationType.crop:
        return 'Crop Selection';
    }
  }

  String? get timeframeText {
    if (timeframeWeeks == null) return null;
    if (timeframeWeeks! < 4) {
      return '$timeframeWeeks week${timeframeWeeks! > 1 ? 's' : ''}';
    } else {
      final months = (timeframeWeeks! / 4).round();
      return '$months month${months > 1 ? 's' : ''}';
    }
  }

  String? get costText {
    if (estimatedCost == null) return null;
    return '\$${estimatedCost!.toStringAsFixed(0)}';
  }
}

// Request/Response models
@JsonSerializable()
class SoilAnalysisRequest {
  final int farmId;
  final double latitude;
  final double longitude;

  const SoilAnalysisRequest({
    required this.farmId,
    required this.latitude,
    required this.longitude,
  });

  factory SoilAnalysisRequest.fromJson(Map<String, dynamic> json) =>
      _$SoilAnalysisRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SoilAnalysisRequestToJson(this);
}

@JsonSerializable()
class SoilAnalysisResponse {
  final bool success;
  final String message;
  final SoilAnalysis analysis;

  const SoilAnalysisResponse({
    required this.success,
    required this.message,
    required this.analysis,
  });

  factory SoilAnalysisResponse.fromJson(Map<String, dynamic> json) =>
      _$SoilAnalysisResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SoilAnalysisResponseToJson(this);
}

@JsonSerializable()
class SoilAnalysisListResponse {
  final bool success;
  final String message;
  final List<SoilAnalysis> analyses;
  final int total;

  const SoilAnalysisListResponse({
    required this.success,
    required this.message,
    required this.analyses,
    required this.total,
  });

  factory SoilAnalysisListResponse.fromJson(Map<String, dynamic> json) =>
      _$SoilAnalysisListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SoilAnalysisListResponseToJson(this);
}

// Enums
enum SoilPropertyStatus {
  @JsonValue('low')
  low,
  @JsonValue('optimal')
  optimal,
  @JsonValue('high')
  high,
}

enum SoilHealthLevel {
  @JsonValue('very_poor')
  veryPoor,
  @JsonValue('poor')
  poor,
  @JsonValue('fair')
  fair,
  @JsonValue('good')
  good,
  @JsonValue('excellent')
  excellent,
}

enum RecommendationType {
  @JsonValue('fertilizer')
  fertilizer,
  @JsonValue('liming')
  liming,
  @JsonValue('organic')
  organic,
  @JsonValue('irrigation')
  irrigation,
  @JsonValue('cultivation')
  cultivation,
  @JsonValue('crop')
  crop,
}

enum RecommendationPriority {
  @JsonValue('high')
  high,
  @JsonValue('medium')
  medium,
  @JsonValue('low')
  low,
}

