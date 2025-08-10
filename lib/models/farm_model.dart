import 'package:json_annotation/json_annotation.dart';

part 'farm_model.g.dart';

@JsonSerializable()
class Farm {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final double? area;
  @JsonKey(name: 'crop_type')
  final String? cropType;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const Farm({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    this.area,
    this.cropType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Farm.fromJson(Map<String, dynamic> json) => _$FarmFromJson(json);
  Map<String, dynamic> toJson() => _$FarmToJson(this);

  Farm copyWith({
    int? id,
    int? userId,
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    double? area,
    String? cropType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Farm(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      area: area ?? this.area,
      cropType: cropType ?? this.cropType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedCoordinates {
    final latDir = latitude >= 0 ? 'N' : 'S';
    final lngDir = longitude >= 0 ? 'E' : 'W';
    return '${latitude.abs().toStringAsFixed(4)}°$latDir, ${longitude.abs().toStringAsFixed(4)}°$lngDir';
  }

  String get formattedArea {
    if (area == null) return 'Not specified';
    return '${area!.toStringAsFixed(1)} ha';
  }

  @override
  String toString() {
    return 'Farm(id: $id, userId: $userId, name: $name, description: $description, latitude: $latitude, longitude: $longitude, area: $area, cropType: $cropType, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Farm &&
        other.id == id &&
        other.userId == userId &&
        other.name == name &&
        other.description == description &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.area == area &&
        other.cropType == cropType &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        name.hashCode ^
        description.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        area.hashCode ^
        cropType.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}

@JsonSerializable()
class CreateFarmRequest {
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final double? area;
  @JsonKey(name: 'crop_type')
  final String? cropType;

  const CreateFarmRequest({
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    this.area,
    this.cropType,
  });

  factory CreateFarmRequest.fromJson(Map<String, dynamic> json) => _$CreateFarmRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateFarmRequestToJson(this);
}

@JsonSerializable()
class UpdateFarmRequest {
  final String? name;
  final String? description;
  final double? latitude;
  final double? longitude;
  final double? area;
  @JsonKey(name: 'crop_type')
  final String? cropType;

  const UpdateFarmRequest({
    this.name,
    this.description,
    this.latitude,
    this.longitude,
    this.area,
    this.cropType,
  });

  factory UpdateFarmRequest.fromJson(Map<String, dynamic> json) => _$UpdateFarmRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateFarmRequestToJson(this);
}

@JsonSerializable()
class FarmResponse {
  final String message;
  final Farm farm;

  const FarmResponse({
    required this.message,
    required this.farm,
  });

  factory FarmResponse.fromJson(Map<String, dynamic> json) => _$FarmResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FarmResponseToJson(this);
}

@JsonSerializable()
class FarmsListResponse {
  final List<Farm> farms;
  final int total;

  const FarmsListResponse({
    required this.farms,
    required this.total,
  });

  factory FarmsListResponse.fromJson(Map<String, dynamic> json) => _$FarmsListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FarmsListResponseToJson(this);
}

@JsonSerializable()
class FarmStats {
  @JsonKey(name: 'farm_id')
  final int farmId;
  @JsonKey(name: 'soil_analyses_count')
  final int soilAnalysesCount;
  @JsonKey(name: 'latest_analysis_date')
  final DateTime? latestAnalysisDate;
  @JsonKey(name: 'farm_area')
  final double? farmArea;
  @JsonKey(name: 'crop_type')
  final String? cropType;

  const FarmStats({
    required this.farmId,
    required this.soilAnalysesCount,
    this.latestAnalysisDate,
    this.farmArea,
    this.cropType,
  });

  factory FarmStats.fromJson(Map<String, dynamic> json) => _$FarmStatsFromJson(json);
  Map<String, dynamic> toJson() => _$FarmStatsToJson(this);
}

@JsonSerializable()
class FarmStatsResponse {
  final FarmStats stats;

  const FarmStatsResponse({
    required this.stats,
  });

  factory FarmStatsResponse.fromJson(Map<String, dynamic> json) => _$FarmStatsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FarmStatsResponseToJson(this);
}

