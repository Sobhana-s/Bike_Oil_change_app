import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/odometer_reading.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import 'login_screen.dart';
import 'update_odometer_screen.dart';
import 'profile_screen.dart';
import 'ride_log_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  
  User? _currentUser;
  int _distanceSinceLastOilChange = 0;
  Map<String, int> _weeklyStats = {'totalDistance': 0, 'avgDailyDistance': 0};
  Map<String, int> _monthlyStats = {'totalDistance': 0, 'avgDailyDistance': 0};
  bool _isLoading = true;
  List<OdometerReading> _recentReadings = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _notificationService.initialize();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.getCurrentUser();
      
      if (user == null) {
        // Not logged in, navigate to login screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        return;
      }

      _currentUser = user;
      
      // Get distance since last oil change
      _distanceSinceLastOilChange = await _databaseService.getDistanceSinceLastOilChange(user.bikeNumber);
      
      // Get weekly and monthly stats
      _weeklyStats = await _databaseService.getWeeklyStats(user.bikeNumber);
      _monthlyStats = await _databaseService.getMonthlyStats(user.bikeNumber);
      
      // Get recent odometer readings
      _recentReadings = await _databaseService.getOdometerReadings(user.bikeNumber);
      
      // Check if oil change notification should be shown
      await _notificationService.checkAndNotifyOilChange(
        user.bikeNumber,
        user.phoneNumber,
        _distanceSinceLastOilChange,
      );
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _navigateToUpdateOdometer() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UpdateOdometerScreen(
          currentUser: _currentUser!,
        ),
      ),
    );

    if (result == true) {
      // Refresh data if odometer was updated
      _loadData();
    }
  }

  void _navigateToProfile() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          currentUser: _currentUser!,
        ),
      ),
    );

    if (result == true) {
      // Refresh data if profile was updated
      _loadData();
    }
  }

  void _navigateToRideLog() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RideLogScreen(),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Calculate oil change status
    final oilChangeNeeded = _distanceSinceLastOilChange >= 2000;
    final distanceRemaining = 2000 - _distanceSinceLastOilChange;
    final oilChangeStatusColor = oilChangeNeeded ? Colors.red : Colors.green;
    final oilChangeStatusText = oilChangeNeeded
        ? 'Oil Change Needed'
        : '$distanceRemaining km remaining';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bike Maintenance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _navigateToProfile,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
          IconButton(
            icon: const Icon(Icons.directions_bike),
            tooltip: 'Log a Ride',
            onPressed: _navigateToRideLog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${_currentUser?.bikeNumber}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Keep track of your bike\'s maintenance needs',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Oil change status section
              Card(
                color: oilChangeNeeded ? Colors.red.shade50 : Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            oilChangeNeeded ? Icons.warning : Icons.check_circle,
                            color: oilChangeStatusColor,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  oilChangeNeeded
                                      ? 'Your engine is waiting for a new drink!'
                                      : 'Oil Status',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: oilChangeStatusColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  oilChangeStatusText,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: oilChangeStatusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: _distanceSinceLastOilChange / 2000,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          oilChangeNeeded ? Colors.red : Colors.green,
                        ),
                        minHeight: 10,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_distanceSinceLastOilChange km since last oil change',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (oilChangeNeeded)
                        ElevatedButton(
                          onPressed: () async {
                            // Record oil change
                            final latestReading = await _databaseService.getLatestReading(_currentUser!.bikeNumber);
                            if (latestReading != null) {
                              await _databaseService.recordOilChange(
                                _currentUser!.bikeNumber,
                                latestReading.readingKm,
                              );
                              _loadData(); // Refresh data
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Oil change recorded successfully')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Record Oil Change'),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Stats section
              const Text(
                'Usage Statistics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      'Weekly',
                      '${_weeklyStats['totalDistance']} km',
                      Icons.trending_up,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoCard(
                      'Monthly',
                      '${_monthlyStats['totalDistance']} km',
                      Icons.calendar_today,
                      Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoCard(
                      'Daily Avg',
                      '${_weeklyStats['avgDailyDistance']} km',
                      Icons.speed,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Recent readings section
              const Text(
                'Recent Odometer Readings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _recentReadings.isEmpty
                  ? const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'No readings recorded yet. Tap the button below to add your first reading.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _recentReadings.length > 5 ? 5 : _recentReadings.length,
                      itemBuilder: (context, index) {
                        final reading = _recentReadings[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.speed, color: Colors.blue),
                            title: Text('${reading.readingKm} km'),
                            subtitle: Text(
                              'Recorded on ${reading.date.day}/${reading.date.month}/${reading.date.year}',
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToUpdateOdometer,
        tooltip: 'Update Odometer',
        child: const Icon(Icons.add),
      ),
    );
  }
}
