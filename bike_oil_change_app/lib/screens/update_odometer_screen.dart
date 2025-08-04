import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/odometer_reading.dart';
import '../services/database_service.dart';

class UpdateOdometerScreen extends StatefulWidget {
  final User currentUser;

  const UpdateOdometerScreen({
    Key? key,
    required this.currentUser,
  }) : super(key: key);

  @override
  _UpdateOdometerScreenState createState() => _UpdateOdometerScreenState();
}

class _UpdateOdometerScreenState extends State<UpdateOdometerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _odometerController = TextEditingController();
  final _databaseService = DatabaseService();
  bool _isLoading = false;
  int? _lastReading;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadLastReading();
  }

  Future<void> _loadLastReading() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reading = await _databaseService.getLatestReading(widget.currentUser.bikeNumber);
      
      if (reading != null) {
        setState(() {
          _lastReading = reading.readingKm;
        });
      } else if (widget.currentUser.lastOilChangeKm != null) {
        setState(() {
          _lastReading = widget.currentUser.lastOilChangeKm;
        });
      }
    } catch (e) {
      print('Error loading last reading: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _isInitialized = true;
      });
    }
  }

  Future<void> _saveOdometerReading() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentReading = int.parse(_odometerController.text.trim());
      
      // Create a new reading
      final newReading = OdometerReading(
        id: 0, // Will be assigned by the database
        bikeNumber: widget.currentUser.bikeNumber,
        readingKm: currentReading,
        date: DateTime.now(),
      );
      
      // Insert into database
      await _databaseService.insertOdometerReading(newReading);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Odometer reading saved successfully')),
      );
      
      // Return to previous screen with refresh signal
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _odometerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Odometer'),
      ),
      body: _isLoading && !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Enter Current Odometer Reading',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_lastReading != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Text(
                                  'Last recorded reading: $_lastReading km',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            TextFormField(
                              controller: _odometerController,
                              decoration: const InputDecoration(
                                labelText: 'Current Odometer (km)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.speed),
                                helperText: 'Enter the current value shown on your bike\'s odometer',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the current odometer reading';
                                }
                                
                                final currentReading = int.tryParse(value);
                                if (currentReading == null) {
                                  return 'Please enter a valid number';
                                }
                                
                                if (_lastReading != null && currentReading < _lastReading!) {
                                  return 'New reading cannot be less than the previous reading';
                                }
                                
                                if (_lastReading != null && (currentReading - _lastReading!) > 1000) {
                                  return 'Are you sure? This is more than 1000 km since last reading';
                                }
                                
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Note: Please enter the exact reading from your odometer. This helps calculate accurate maintenance schedules.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveOdometerReading,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text('Save Reading'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
