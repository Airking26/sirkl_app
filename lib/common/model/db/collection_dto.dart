import 'package:hive/hive.dart';
part 'collection_dto.g.dart';

@HiveType(typeId: 1)
class ListOfCollectionDbDto{
  ListOfCollectionDbDto({required this.listOfCollections});

  @HiveField(0)
  List<CollectionDbDto> listOfCollections;

}


@HiveType(typeId: 2)
class CollectionDbDto{
  CollectionDbDto({required this.collectionName, required this.collectionImages});

  @HiveField(0)
  String collectionName;

  @HiveField(1)
  List<String> collectionImages;
}