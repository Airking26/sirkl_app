
class ListOfCollectionDbDto{
  ListOfCollectionDbDto({required this.listOfCollections});
  List<CollectionDbDto> listOfCollections;

}


class CollectionDbDto{
  CollectionDbDto({required this.collectionName, required this.collectionImages});

  String collectionName;
  List<String> collectionImages;
}