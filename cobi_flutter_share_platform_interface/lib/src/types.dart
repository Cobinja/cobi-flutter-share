import 'package:json_annotation/json_annotation.dart';

/// NOTE: if you change anything in here make sure to run generate_json_serializable in this project's root folder

part 'types.g.dart';

/// This enum holds values for share types, whether it's a file or just text
enum ShareItemType {
  FILE,
  TEXT
}

/// This class defines share targets.
/// Only one of the image properties will be used, even if multiple are given.
/// The other ones are ignored.
/// The order in which they are used:
/// 1. [imageByAssetName]
/// 2. [imageByFilename]
/// 3. [imageBytes]
@JsonSerializable()
class DirectShareTarget {
  /// A uniwue identifier.
  /// If you want to update an existing share target, re-add it with the same id.
  String id;
  String? shortLabel;
  String? longLabel;
  /// The categories have to correspond to the categories defined in your shortcuts.xml file on Android.
  List<String> categories;
  /// image used in the share sheet, this is usually loaded from a file or web resource, e.g. the unprocessed content of a .jpg file.
  List<int>? imageBytes;
  /// image for the share sheet defined as a flutter asset.
  String? imageByAssetName;
  /// image for the share sheet as filename on disk.
  String? imageByFilename;
  
  DirectShareTarget({
    required this.id,
    required this.categories,
    this.shortLabel,
    this.longLabel,
    this.imageBytes,
    this.imageByAssetName,
    this.imageByFilename
  });
  
  factory DirectShareTarget.fromJson(Map<String, dynamic> json) => _$DirectShareTargetFromJson(json);
  Map<String, dynamic> toJson() => _$DirectShareTargetToJson(this);
}

/// This defines shared items which will be given inside a [ShareData] object
@JsonSerializable()
class ShareItem {
  /// The actual content
  String data;
  /// This property tells you what the data contains, wether it's just text or a file. If it's a file on Android, this is usually a content uri
  ShareItemType type;
  /// The content mime type.
  /// Note: By this, you cannot differ between just text and a plain text file on Android. Both get the mimetype "text/plain".
  /// To differ between these two, use the [type] property.
  String mimeType;
  
  ShareItem({required this.data, required this.type, required this.mimeType});
  
  factory ShareItem.fromJson(Map<String, dynamic> json) => _$ShareItemFromJson(json);
  
  Map<String, dynamic> toJson() => _$ShareItemToJson(this);
  
  String toString() {
    return toJson().toString();
  }
}

@JsonSerializable()
class ShareData {
  /// The share target id, as used in [DirectShareTarget].
  /// If no id is present, the items were shared via the general share item for your app, not a direct share target.
  String? id;
  /// A list of shared items.
  List<ShareItem> items;
  
  ShareData({this.id, required this.items});
  
  factory ShareData.fromJson(Map<String, dynamic> json) => _$ShareDataFromJson(json);
  
  Map<String, dynamic> toJson() => _$ShareDataToJson(this);
}
