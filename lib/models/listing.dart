const listingCategories = [
  'Textbooks',
  'Electronics',
  'Dorm items',
  'Clothing',
];
const listingConditions = ['New', 'Like new', 'Good', 'Fair'];

class Listing {
  Listing({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.condition,
    required this.seller,
    required this.isMine,
    required this.photos,
    this.isSold = false,
    DateTime? postedAt,
  }) : postedAt = postedAt ?? DateTime.now();

  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String condition;
  final String seller;
  final bool isMine;
  final List<String> photos;
  final DateTime postedAt;
  bool isSold;

  String get priceLabel {
    final digits = price == price.truncateToDouble() ? 0 : 2;
    return 'TRY ${price.toStringAsFixed(digits)}';
  }
}

List<Listing> sampleListings() {
  final postedAt = DateTime(2026, 10, 31);
  return [
    Listing(
      id: 1,
      postedAt: postedAt,
      title: 'Calculus textbook',
      price: 450,
      description:
          'Clean pages with a few pencil notes. We can meet on campus after class.',
      category: 'Textbooks',
      condition: 'Good',
      seller: 'Student A',
      isMine: false,
      photos: ['assets/images/textbook-photo.jpg'],
    ),
    Listing(
      id: 2,
      postedAt: postedAt,
      title: 'Wireless headphones',
      price: 900,
      description: 'Includes the case and charging cable. Campus pickup.',
      category: 'Electronics',
      condition: 'Like new',
      seller: 'Student B',
      isMine: false,
      photos: [
        'assets/images/headphones-photo.jpg',
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=700&fit=crop',
      ],
    ),
    Listing(
      id: 3,
      postedAt: postedAt,
      title: 'Desk lamp',
      price: 300,
      description:
          'Adjustable desk lamp in good condition. Available for a campus meetup.',
      category: 'Dorm items',
      condition: 'Good',
      seller: 'You',
      isMine: true,
      photos: ['assets/images/desk-lamp-photo.jpg'],
    ),
    Listing(
      id: 4,
      postedAt: postedAt,
      title: 'Dorm chair',
      price: 650,
      description: 'Compact chair for a dorm room.',
      category: 'Dorm items',
      condition: 'Good',
      seller: 'You',
      isMine: true,
      photos: ['assets/images/dorm-chair-photo.jpg'],
      isSold: true,
    ),
  ];
}
