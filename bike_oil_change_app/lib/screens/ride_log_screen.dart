import 'package:flutter/material.dart';
import '../models/ride_log.dart';

class RideLogScreen extends StatefulWidget {
  @override
  _RideLogScreenState createState() => _RideLogScreenState();
}

class _RideLogScreenState extends State<RideLogScreen> {
  final _formKey = GlobalKey<FormState>();
  double? _distance;
  String? _weather;
  String? _ridingStyle;
  DateTime _date = DateTime.now();

  final List<String> _weatherOptions = ['Sunny', 'Rainy', 'Cloudy', 'Windy'];
  final List<String> _ridingStyles = ['Aggressive', 'Normal', 'Calm'];

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      RideLog log = RideLog(
        date: _date,
        distance: _distance!,
        weather: _weather!,
        ridingStyle: _ridingStyle!,
      );
      // TODO: Save log to database or state
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ride log saved!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Log a Ride')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Distance (km)'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Enter distance' : null,
                onSaved: (value) => _distance = double.tryParse(value ?? ''),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Weather'),
                items: _weatherOptions.map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
                validator: (value) => value == null ? 'Select weather' : null,
                onChanged: (value) => setState(() => _weather = value),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Riding Style'),
                items: _ridingStyles.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                validator: (value) => value == null ? 'Select style' : null,
                onChanged: (value) => setState(() => _ridingStyle = value),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Save Ride Log'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
