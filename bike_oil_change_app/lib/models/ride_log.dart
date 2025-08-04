class RideLog {
  final DateTime date;
  final double distance; // in kilometers
  final String weather; // e.g., 'Sunny', 'Rainy', etc.
  final String ridingStyle; // e.g., 'Aggressive', 'Normal', 'Calm'

  RideLog({
    required this.date,
    required this.distance,
    required this.weather,
    required this.ridingStyle,
  });
}
