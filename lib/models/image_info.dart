import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

@HiveType(typeId: 0) // Make sure this is unique among all your registered adapters.
class HiveImageInfo {
  @HiveField(0)
  final Uint8List image;

  @HiveField(1)
  final String prompt;
  @HiveField(2)
  final DateTime timestamp;

  HiveImageInfo(this.image, this.prompt, this.timestamp);
}
class HiveImageInfoAdapter extends TypeAdapter<HiveImageInfo> {
  @override
  final typeId = 0;

  @override
  HiveImageInfo read(BinaryReader reader) {
    final image = reader.readByteList();
    final prompt = reader.readString();
    
    DateTime timestamp;
    try {
      // Try to read the timestamp as an integer
      final timestampMilliseconds = reader.readInt();
      timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMilliseconds);
    } catch (_) {
      // If timestamp field is not present or cannot be read, use default timestamp
      timestamp = DateTime.now(); // Provide a default timestamp
    }

    return HiveImageInfo(image, prompt, timestamp);
  }

  @override
  void write(BinaryWriter writer, HiveImageInfo obj) {
    writer.writeByteList(obj.image);
    writer.writeString(obj.prompt);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
  }
}



