# Bike Oil Change Notification App

A mobile application that helps bike owners track their motorcycle maintenance by reminding them when an oil change is due (every 2000 kilometers).

## Features

- **User Authentication**: Log in with bike number and chassis number
- **Odometer Tracking**: Manually enter current odometer readings
- **Maintenance Tracking**: Track distance since last oil change
- **Smart Notifications**: Get alerts when your bike reaches 2000 km since the last oil change
- **Usage Statistics**: View weekly and monthly distance statistics
- **Profile Management**: Update contact information for alerts

## Getting Started

### Prerequisites

Make sure you have Flutter installed on your machine. For installation instructions, see the [official Flutter documentation](https://flutter.dev/docs/get-started/install).

### Installation

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/bike_oil_change_app.git
   ```

2. Navigate to the project directory:
   ```
   cd bike_oil_change_app
   ```

3. Get the dependencies:
   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

## Usage

1. **Registration**: Register with your bike number (as username), chassis number (as password), phone number, and initial odometer reading.

2. **Login**: Log in using your bike number and chassis number.

3. **Update Odometer**: Regularly update your current odometer reading by clicking the + button on the home screen.

4. **Monitor Maintenance**: The app tracks your usage and shows:
   - Current distance since last oil change
   - Estimated kilometers left before next oil change
   - Weekly and monthly usage statistics

5. **Receive Notifications**: When you reach 2000 km since your last oil change, you'll receive a notification on your phone.

6. **Record Oil Change**: After changing your oil, use the "Record Oil Change" button to reset the counter.

## Key Components

- **Authentication**: Simple local authentication system
- **Database**: Local storage for user data and odometer readings
- **Notifications**: Local notifications and SMS alerts
- **Statistics**: Weekly and monthly distance calculations

## Future Enhancements

- Cloud synchronization for data backup
- Multiple vehicle support
- Expanded maintenance tracking (air filter, brake pads, etc.)
- Maintenance history and reminders
- Integration with service centers
- Rich notifications with service center location suggestions

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Motorcycle enthusiasts who provided feedback
