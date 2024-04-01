import 'package:flutter/material.dart';

class BatteryDetails extends StatelessWidget {
  final String deviceId;

  const BatteryDetails({
    Key? key,
    required this.deviceId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // In the future, you would fetch the battery details for the given deviceId
    // from your database and then use a FutureBuilder or StreamBuilder to build
    // the UI dynamically based on the fetched data.

    return Card(
      color: Theme.of(context).colorScheme.background,
      elevation: 4.0,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _buildInfoRow(context, 'Device ID:', deviceId), // Displaying the passed deviceId
            SizedBox(height: 10),
            _buildInfoRow(context, 'Battery Level:', '75%'), // Placeholder value
            SizedBox(height: 10),
            _buildInfoRow(context, 'Temperature:', '23°C'), // Placeholder value
            SizedBox(height: 10),
            _buildInfoRow(context, 'Motion Sensor:', 'Motion Detected'), // Placeholder value
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
