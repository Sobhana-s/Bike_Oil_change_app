class User {
  final String bikeNumber;
  final String chassisNumber;
  String? phoneNumber;
  int? lastOilChangeKm;
  int? currentKm;

  User({
    required this.bikeNumber,
    required this.chassisNumber,
    this.phoneNumber,
    this.lastOilChangeKm,
    this.currentKm,
  });

  // Create a User from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      bikeNumber: json['bikeNumber'],
      chassisNumber: json['chassisNumber'],
      phoneNumber: json['phoneNumber'],
      lastOilChangeKm: json['lastOilChangeKm'],
      currentKm: json['currentKm'],
    );
  }

  // Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'bikeNumber': bikeNumber,
      'chassisNumber': chassisNumber,
      'phoneNumber': phoneNumber,
      'lastOilChangeKm': lastOilChangeKm,
      'currentKm': currentKm,
    };
  }
}
