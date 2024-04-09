import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class BatteryDetails extends StatelessWidget {
  final String deviceId;

  const BatteryDetails({
    Key? key,
    required this.deviceId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseDatabase database = FirebaseDatabase(
      databaseURL: "https://smartlockerintellilock-default-rtdb.asia-southeast1.firebasedatabase.app",
    );
    final DatabaseReference databaseReference = database.ref();

    return Card(
      color: Theme.of(context).colorScheme.background,
      elevation: 4.0,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: StreamBuilder<DatabaseEvent>(
          stream: databaseReference.child(deviceId).onValue,
          builder: (BuildContext context, AsyncSnapshot<DatabaseEvent> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
              final data = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
              final batteryLevel = data['battery']?.toString() ?? 'N/A';
              final temperature = data['temp']?.toString() ?? 'N/A';
              final humidity = data['humidity']?.toString() ?? 'N/A';
              final motion = data['motion'] == true ? 'Motion Detected' : 'Normal';

              return Column(
                children: <Widget>[
                  _buildInfoRow(context, 'Device ID:', deviceId),
                  SizedBox(height: 10),
                  _buildInfoRow(context, 'Battery Level:', '$batteryLevel%'),
                  SizedBox(height: 10),
                  _buildInfoRow(context, 'Temperature:', '$temperature°C'),
                  SizedBox(height: 10),
                  _buildInfoRow(context, 'Humidity:', '$humidity%'),
                  SizedBox(height: 10),
                  _buildInfoRow(context, 'Motion Sensor:', motion),
                ],
              );
            } else {
              return Center(child: Text('No data available'));
            }
          },
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
