// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShareTarget _$ShareTargetFromJson(Map<String, dynamic> json) => ShareTarget(
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

ShareItem _$ShareItemFromJson(Map<String, dynamic> json) => ShareItem(
      data: json['data'] as String,
      type: $enumDecode(_$ShareItemTypeEnumMap, json['type']),
      mimeType: json['mimeType'] as String,
    );

Map<String, dynamic> _$ShareItemToJson(ShareItem instance) => <String, dynamic>{
      'data': instance.data,
      'type': _$ShareItemTypeEnumMap[instance.type]!,
      'mimeType': instance.mimeType,
    };

const _$ShareItemTypeEnumMap = {
  ShareItemType.FILE: 'FILE',
  ShareItemType.TEXT: 'TEXT',
};

ShareData _$ShareDataFromJson(Map<String, dynamic> json) => ShareData(
      id: json['id'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((e) => ShareItem.fromJson(e as Map<String, dynamic>))
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
