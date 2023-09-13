import 'dart:typed_data';

import 'package:cobi_flutter_share_platform_interface/cobi_flutter_share_platform_interface.dart';
import 'package:json_annotation/json_annotation.dart';

/// NOTE: if you change anything in here make sure to run generate_json_serializable in this project's root folder

part 'types.g.dart';

class _Uint8ListConverter implements JsonConverter<Uint8List, List<int>> {
  const _Uint8ListConverter();

  @override
  Uint8List fromJson(List<int> json) => Uint8List.fromList(json);

  @override
  List<int> toJson(Uint8List object) => object.toList();
}

/// This enum holds values for share types, whether it's a file or just text
enum ShareItemType {
  FILE,
  TEXT,
  FOLDER
}

/// This class defines share targets.
/// Only one of the image properties will be used, even if multiple are given.
/// The other ones are ignored.
/// The order in which they are used:
/// 1. [imageByAssetName]
/// 2. [imageByFilename]
/// 3. [imageBytes]
@JsonSerializable()
class ShareTarget {
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
  
  ShareTarget({
    required this.id,
    required this.categories,
    this.shortLabel,
    this.longLabel,
    this.imageBytes,
    this.imageByAssetName,
    this.imageByFilename
  });
  
  factory ShareTarget.fromJson(Map<String, dynamic> json) => _$ShareTargetFromJson(json);
  Map<String, dynamic> toJson() => _$ShareTargetToJson(this);
}

@JsonSerializable()
class ShareItemChunk {
  int index;
  @_Uint8ListConverter()
  Uint8List chunk;
  
  ShareItemChunk(this.index, this.chunk);
  
  factory ShareItemChunk.fromJson(Map<String, dynamic> json) => _$ShareItemChunkFromJson(json);
  
  Map<String, dynamic> toJson() => _$ShareItemChunkToJson(this);
}

/// This defines shared items which will be given inside a [ShareData] object
@JsonSerializable()
class ShareItem {
  /// The actual content
  String data;
  /// This property tells you what the data contains, whether it's just text or a file. If it's a file on Android, the property [data] usually contains a content uri
  ShareItemType type;
  /// The actual name of the file
  String? basename;
  /// The absolute path on the filesystem, including the basename at the end
  String? absoluteFilename;
  /// The content mime type.
  /// Note: By this, you cannot differ between just text and a plain text file on Android. Both get the mimetype "text/plain".
  /// To differ between these two, use the [type] property.
  /// If the shared item is a folder, this is null, refer to [type].
  String? mimeType;
  
  ShareItem({required this.data, required this.type, required this.mimeType});
  
  factory ShareItem.fromJson(Map<String, dynamic> json) => _$ShareItemFromJson(json);
  
  Map<String, dynamic> toJson() => _$ShareItemToJson(this);
  
  String toString() {
    return toJson().toString();
  }
  
  /// Fetch the contents of the shared file
  /// 
  /// for {[chunkSize]}:
  /// chunk size in bytes
  /// if set to a value <= 0: the actually used chunk size will be automatically determined based on filesize and free memory heap
  /// if set to a value > 0: this value will be used
  /// if not set: a chunk size of 10 MiB will be used
  Stream<ShareItemChunk>? getContents([int? chunkSize]) {
    if (this.type == ShareItemType.TEXT) {
      return null;
    }
    
    return CobiFlutterSharePlatform.instance.fetchContents(this.data, chunkSize);
  }
  
  void pauseFetch() {
    CobiFlutterSharePlatform.instance.pauseFetch(data);
  }
  
  void continueFetch() {
    CobiFlutterSharePlatform.instance.continueFetch(data);
  }
  
  void abortFetch() {
    CobiFlutterSharePlatform.instance.abortFetch(data);
  }
}

@JsonSerializable()
class ShareData {
  /// The share target id, as used in [ShareTarget].
  /// If no id is present, the items were shared via the general share item for your app, not a specific share target.
  String? id;
  /// A list of shared items.
  List<ShareItem> items;
  
  ShareData({this.id, required this.items});
  
  factory ShareData.fromJson(Map<String, dynamic> json) => _$ShareDataFromJson(json);
  
  Map<String, dynamic> toJson() => _$ShareDataToJson(this);
}
