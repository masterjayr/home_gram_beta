final List<CardViewModel> demoCards = [
  CardViewModel(
    address: 'NO, 222 Farin Gada Jos',
    pictureUrl: 'assets/notbestfriends.png',
    noOfRooms: 3,
    price: 30000
  ),

  CardViewModel(
    address: 'NO, 222 Farin Gada Jos',
    pictureUrl: 'assets/notbestfriends.png',
    noOfRooms: 3,
    price: 30000
  ),

  CardViewModel(
    address: 'NO, 222 Farin Gada Jos',
    pictureUrl: 'assets/notbestfriends.png',
    noOfRooms: 3,
    price: 30000
  ),
];

class CardViewModel {
  final String pictureUrl;
  final String address;
  final int price;
  final int noOfRooms;
  final Map<String, dynamic> document;

  CardViewModel({
    this.pictureUrl,
    this.address,
    this.price,
    this.noOfRooms,
    this.document
  });
}

