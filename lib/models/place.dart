class Place {
  final String name, address, description;
  final double latitude, longitude;
  final int id;
  double distance;
  bool isFavorite;

  Place({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.description,
    this.distance = 0.0,
    this.isFavorite = false,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      description: json['description'],
    );
  }
}