// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_dto.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ListOfCollectionDbDtoAdapter extends TypeAdapter<ListOfCollectionDbDto> {
  @override
  final int typeId = 1;

  @override
  ListOfCollectionDbDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ListOfCollectionDbDto(
      listOfCollections: (fields[0] as List).cast<CollectionDbDto>(),
    );
  }

  @override
  void write(BinaryWriter writer, ListOfCollectionDbDto obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.listOfCollections);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListOfCollectionDbDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CollectionDbDtoAdapter extends TypeAdapter<CollectionDbDto> {
  @override
  final int typeId = 2;

  @override
  CollectionDbDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CollectionDbDto(
      collectionName: fields[0] as String,
      collectionImages: (fields[1] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, CollectionDbDto obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.collectionName)
      ..writeByte(1)
      ..write(obj.collectionImages);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectionDbDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
