import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final User currentUser;

  const ProfileScreen({
    Key? key,
    required this.currentUser,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _phoneNumberController;
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneNumberController = TextEditingController(text: widget.currentUser.phoneNumber);
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Update user information
      final updatedUser = User(
        bikeNumber: widget.currentUser.bikeNumber,
        chassisNumber: widget.currentUser.chassisNumber,
        phoneNumber: _phoneNumberController.text.trim(),
        lastOilChangeKm: widget.currentUser.lastOilChangeKm,
        currentKm: widget.currentUser.currentKm,
      );

      await _authService.updateUser(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
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
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'User Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: const Text('Bike Number'),
                        subtitle: Text(widget.currentUser.bikeNumber),
                        leading: const Icon(Icons.directions_bike, color: Colors.blue),
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('Phone Number'),
                        subtitle: TextFormField(
                          controller: _phoneNumberController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            helperText: 'This number will receive maintenance alerts',
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            // Simple phone number validation
                            if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                        leading: const Icon(Icons.phone, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Security',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: const Text('Chassis Number (Password)'),
                        subtitle: const Text('••••••••••'),
                        leading: const Icon(Icons.vpn_key, color: Colors.orange),
                        trailing: TextButton(
                          onPressed: () {
                            // Show change password dialog (not implemented in this prototype)
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Change password feature will be available in future updates')),
                            );
                          },
                          child: const Text('Change'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
