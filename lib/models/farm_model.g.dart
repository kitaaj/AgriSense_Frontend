// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'farm_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Farm _$FarmFromJson(Map<String, dynamic> json) => Farm(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      area: (json['area'] as num?)?.toDouble(),
      cropType: json['crop_type'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$FarmToJson(Farm instance) => <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'description': instance.description,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'area': instance.area,
      'crop_type': instance.cropType,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

CreateFarmRequest _$CreateFarmRequestFromJson(Map<String, dynamic> json) =>
    CreateFarmRequest(
      name: json['name'] as String,
      description: json['description'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      area: (json['area'] as num?)?.toDouble(),
      cropType: json['crop_type'] as String?,
    );

Map<String, dynamic> _$CreateFarmRequestToJson(CreateFarmRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'area': instance.area,
      'crop_type': instance.cropType,
    };

UpdateFarmRequest _$UpdateFarmRequestFromJson(Map<String, dynamic> json) =>
    UpdateFarmRequest(
      name: json['name'] as String?,
      description: json['description'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      area: (json['area'] as num?)?.toDouble(),
      cropType: json['crop_type'] as String?,
    );

Map<String, dynamic> _$UpdateFarmRequestToJson(UpdateFarmRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'area': instance.area,
      'crop_type': instance.cropType,
    };

FarmResponse _$FarmResponseFromJson(Map<String, dynamic> json) => FarmResponse(
      message: json['message'] as String,
      farm: Farm.fromJson(json['farm'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FarmResponseToJson(FarmResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'farm': instance.farm,
    };

FarmsListResponse _$FarmsListResponseFromJson(Map<String, dynamic> json) =>
    FarmsListResponse(
      farms: (json['farms'] as List<dynamic>)
          .map((e) => Farm.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$FarmsListResponseToJson(FarmsListResponse instance) =>
    <String, dynamic>{
      'farms': instance.farms,
      'total': instance.total,
    };

FarmStats _$FarmStatsFromJson(Map<String, dynamic> json) => FarmStats(
      farmId: (json['farm_id'] as num).toInt(),
      soilAnalysesCount: (json['soil_analyses_count'] as num).toInt(),
      latestAnalysisDate: json['latest_analysis_date'] == null
          ? null
          : DateTime.parse(json['latest_analysis_date'] as String),
      farmArea: (json['farm_area'] as num?)?.toDouble(),
      cropType: json['crop_type'] as String?,
    );

Map<String, dynamic> _$FarmStatsToJson(FarmStats instance) => <String, dynamic>{
      'farm_id': instance.farmId,
      'soil_analyses_count': instance.soilAnalysesCount,
      'latest_analysis_date': instance.latestAnalysisDate?.toIso8601String(),
      'farm_area': instance.farmArea,
      'crop_type': instance.cropType,
    };

FarmStatsResponse _$FarmStatsResponseFromJson(Map<String, dynamic> json) =>
    FarmStatsResponse(
      stats: FarmStats.fromJson(json['stats'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FarmStatsResponseToJson(FarmStatsResponse instance) =>
    <String, dynamic>{
      'stats': instance.stats,
    };
