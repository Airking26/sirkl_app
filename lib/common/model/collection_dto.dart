
class ListOfCollectionDbDto{
  ListOfCollectionDbDto({required this.listOfCollections});
  List<CollectionDbDto> listOfCollections;
}


class CollectionDbDto{
  CollectionDbDto({required this.collectionName, required this.contractAddress, required this.collectionImages});

  String collectionName;
  String contractAddress;
  List<String> collectionImages;
}