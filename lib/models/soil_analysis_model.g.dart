// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'soil_analysis_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SoilAnalysis _$SoilAnalysisFromJson(Map<String, dynamic> json) => SoilAnalysis(
      id: (json['id'] as num).toInt(),
      farmId: (json['farmId'] as num).toInt(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      analysisDate: DateTime.parse(json['analysisDate'] as String),
      properties:
          SoilProperties.fromJson(json['properties'] as Map<String, dynamic>),
      healthScore:
          SoilHealthScore.fromJson(json['healthScore'] as Map<String, dynamic>),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => Recommendation.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SoilAnalysisToJson(SoilAnalysis instance) =>
    <String, dynamic>{
      'id': instance.id,
      'farmId': instance.farmId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'analysisDate': instance.analysisDate.toIso8601String(),
      'properties': instance.properties,
      'healthScore': instance.healthScore,
      'recommendations': instance.recommendations,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

SoilProperties _$SoilPropertiesFromJson(Map<String, dynamic> json) =>
    SoilProperties(
      ph: (json['ph'] as num).toDouble(),
      organicCarbon: (json['organicCarbon'] as num).toDouble(),
      nitrogen: (json['nitrogen'] as num).toDouble(),
      phosphorus: (json['phosphorus'] as num).toDouble(),
      potassium: (json['potassium'] as num).toDouble(),
      calcium: (json['calcium'] as num?)?.toDouble(),
      magnesium: (json['magnesium'] as num?)?.toDouble(),
      sulfur: (json['sulfur'] as num?)?.toDouble(),
      zinc: (json['zinc'] as num?)?.toDouble(),
      iron: (json['iron'] as num?)?.toDouble(),
      manganese: (json['manganese'] as num?)?.toDouble(),
      copper: (json['copper'] as num?)?.toDouble(),
      boron: (json['boron'] as num?)?.toDouble(),
      clay: (json['clay'] as num?)?.toDouble(),
      sand: (json['sand'] as num?)?.toDouble(),
      silt: (json['silt'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$SoilPropertiesToJson(SoilProperties instance) =>
    <String, dynamic>{
      'ph': instance.ph,
      'organicCarbon': instance.organicCarbon,
      'nitrogen': instance.nitrogen,
      'phosphorus': instance.phosphorus,
      'potassium': instance.potassium,
      'calcium': instance.calcium,
      'magnesium': instance.magnesium,
      'sulfur': instance.sulfur,
      'zinc': instance.zinc,
      'iron': instance.iron,
      'manganese': instance.manganese,
      'copper': instance.copper,
      'boron': instance.boron,
      'clay': instance.clay,
      'sand': instance.sand,
      'silt': instance.silt,
    };

SoilHealthScore _$SoilHealthScoreFromJson(Map<String, dynamic> json) =>
    SoilHealthScore(
      overall: (json['overall'] as num).toDouble(),
      fertility: (json['fertility'] as num?)?.toDouble(),
      structure: (json['structure'] as num?)?.toDouble(),
      organic: (json['organic'] as num?)?.toDouble(),
      ph: (json['ph'] as num).toDouble(),
    );

Map<String, dynamic> _$SoilHealthScoreToJson(SoilHealthScore instance) =>
    <String, dynamic>{
      'overall': instance.overall,
      'fertility': instance.fertility,
      'structure': instance.structure,
      'organic': instance.organic,
      'ph': instance.ph,
    };

Recommendation _$RecommendationFromJson(Map<String, dynamic> json) =>
    Recommendation(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$RecommendationTypeEnumMap, json['type']),
      priority: $enumDecode(_$RecommendationPriorityEnumMap, json['priority']),
      actionSteps: json['actionSteps'] as String?,
      expectedOutcome: json['expectedOutcome'] as String?,
      timeframeWeeks: (json['timeframeWeeks'] as num?)?.toInt(),
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$RecommendationToJson(Recommendation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$RecommendationTypeEnumMap[instance.type]!,
      'priority': _$RecommendationPriorityEnumMap[instance.priority]!,
      'actionSteps': instance.actionSteps,
      'expectedOutcome': instance.expectedOutcome,
      'timeframeWeeks': instance.timeframeWeeks,
      'estimatedCost': instance.estimatedCost,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$RecommendationTypeEnumMap = {
  RecommendationType.fertilizer: 'fertilizer',
  RecommendationType.liming: 'liming',
  RecommendationType.organic: 'organic',
  RecommendationType.irrigation: 'irrigation',
  RecommendationType.cultivation: 'cultivation',
  RecommendationType.crop: 'crop',
};

const _$RecommendationPriorityEnumMap = {
  RecommendationPriority.high: 'high',
  RecommendationPriority.medium: 'medium',
  RecommendationPriority.low: 'low',
};

SoilAnalysisRequest _$SoilAnalysisRequestFromJson(Map<String, dynamic> json) =>
    SoilAnalysisRequest(
      farmId: (json['farmId'] as num).toInt(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$SoilAnalysisRequestToJson(
        SoilAnalysisRequest instance) =>
    <String, dynamic>{
      'farmId': instance.farmId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

SoilAnalysisResponse _$SoilAnalysisResponseFromJson(
        Map<String, dynamic> json) =>
    SoilAnalysisResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      analysis: SoilAnalysis.fromJson(json['analysis'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SoilAnalysisResponseToJson(
        SoilAnalysisResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'analysis': instance.analysis,
    };

SoilAnalysisListResponse _$SoilAnalysisListResponseFromJson(
        Map<String, dynamic> json) =>
    SoilAnalysisListResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      analyses: (json['analyses'] as List<dynamic>)
          .map((e) => SoilAnalysis.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$SoilAnalysisListResponseToJson(
        SoilAnalysisListResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'analyses': instance.analyses,
      'total': instance.total,
    };
