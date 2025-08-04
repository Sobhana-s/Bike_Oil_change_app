class OdometerReading {
  final int id;
  final String bikeNumber;
  final int readingKm;
  final DateTime date;

  OdometerReading({
    required this.id,
    required this.bikeNumber,
    required this.readingKm,
    required this.date,
  });

  // Create an OdometerReading from JSON data
  factory OdometerReading.fromJson(Map<String, dynamic> json) {
    return OdometerReading(
      id: json['id'],
      bikeNumber: json['bikeNumber'],
      readingKm: json['readingKm'],
      date: DateTime.parse(json['date']),
    );
  }

  // Convert OdometerReading to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bikeNumber': bikeNumber,
      'readingKm': readingKm,
      'date': date.toIso8601String(),
    };
  }

  // Create a copy with modified properties
  OdometerReading copyWith({
    int? id,
    String? bikeNumber,
    int? readingKm,
    DateTime? date,
  }) {
    return OdometerReading(
      id: id ?? this.id,
      bikeNumber: bikeNumber ?? this.bikeNumber,
      readingKm: readingKm ?? this.readingKm,
      date: date ?? this.date,
    );
  }
}
