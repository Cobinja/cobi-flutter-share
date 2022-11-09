// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShareTarget _$ShareTargetFromJson(Map json) => ShareTarget(
      id: json['id'] as String,
      categories: (json['categories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      shortLabel: json['shortLabel'] as String?,
      longLabel: json['longLabel'] as String?,
      imageBytes:
          (json['imageBytes'] as List<dynamic>?)?.map((e) => e as int).toList(),
      imageByAssetName: json['imageByAssetName'] as String?,
      imageByFilename: json['imageByFilename'] as String?,
    );

Map<String, dynamic> _$ShareTargetToJson(ShareTarget instance) {
  final val = <String, dynamic>{
    'id': instance.id,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('shortLabel', instance.shortLabel);
  writeNotNull('longLabel', instance.longLabel);
  val['categories'] = instance.categories;
  writeNotNull('imageBytes', instance.imageBytes);
  writeNotNull('imageByAssetName', instance.imageByAssetName);
  writeNotNull('imageByFilename', instance.imageByFilename);
  return val;
}

ShareItemChunk _$ShareItemChunkFromJson(Map json) => ShareItemChunk(
      json['index'] as int,
      const _Uint8ListConverter().fromJson(json['chunk'] as List<int>),
    );

Map<String, dynamic> _$ShareItemChunkToJson(ShareItemChunk instance) {
  final val = <String, dynamic>{
    'index': instance.index,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('chunk', const _Uint8ListConverter().toJson(instance.chunk));
  return val;
}

ShareItem _$ShareItemFromJson(Map json) => ShareItem(
      data: json['data'] as String,
      type: $enumDecode(_$ShareItemTypeEnumMap, json['type']),
      mimeType: json['mimeType'] as String,
    )..basename = json['basename'] as String?;

Map<String, dynamic> _$ShareItemToJson(ShareItem instance) {
  final val = <String, dynamic>{
    'data': instance.data,
    'type': _$ShareItemTypeEnumMap[instance.type]!,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('basename', instance.basename);
  val['mimeType'] = instance.mimeType;
  return val;
}

const _$ShareItemTypeEnumMap = {
  ShareItemType.FILE: 'FILE',
  ShareItemType.TEXT: 'TEXT',
};

ShareData _$ShareDataFromJson(Map json) => ShareData(
      id: json['id'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((e) => ShareItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$ShareDataToJson(ShareData instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  val['items'] = instance.items;
  return val;
}
