import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

@HiveType(typeId: 0) // Make sure this is unique among all your registered adapters.
class HiveImageInfo {
  @HiveField(0)
  final Uint8List image;

  @HiveField(1)
  final String prompt;

  HiveImageInfo(this.image, this.prompt);
}

class HiveImageInfoAdapter extends TypeAdapter<HiveImageInfo> {
  @override
  final typeId = 0; // Make sure this is unique among all your registered adapters.

  @override
  HiveImageInfo read(BinaryReader reader) {
    return HiveImageInfo(reader.readByteList(), reader.readString());
  }

  @override
  void write(BinaryWriter writer, HiveImageInfo obj) {
    writer.writeByteList(obj.image);
    writer.writeString(obj.prompt);
  }
}


