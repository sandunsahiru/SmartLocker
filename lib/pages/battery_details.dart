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
    // Initialize the Firebase Realtime Database with the provided URL
    final FirebaseDatabase database = FirebaseDatabase(
      databaseURL: "https://smartlockerintellilock-default-rtdb.asia-southeast1.firebasedatabase.app",
    );
    final DatabaseReference databaseReference = database.ref();

    return Card(
      color: Theme.of(context).colorScheme.background,
      elevation: 4.0,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: FutureBuilder<DataSnapshot>(
          // Use the database reference to directly get the data for the deviceId
          future: databaseReference.child(deviceId).get(),
          builder: (BuildContext context, AsyncSnapshot<DataSnapshot> snapshot) {
            // Print statements for debugging
            debugPrint('Connection state: ${snapshot.connectionState}');
            if (snapshot.hasData) {
              debugPrint('Data received: ${snapshot.data!.value}');
            }
            if (snapshot.hasError) {
              debugPrint('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData && snapshot.data!.value != null) {
              // Assuming the data is in the expected format and the node exists
              final data = Map<String, dynamic>.from(snapshot.data!.value as Map);
              final batteryLevel = data['battery']?.toString() ?? 'N/A';
              final temperature = data['temp']?.toString() ?? 'N/A';
              final humidity = data['humidity']?.toString() ?? 'N/A';
              final motion = data['motion'] == true ? 'Motion Detected' : 'Normal';

              // Use the retrieved values to build the UI
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
              debugPrint('Snapshot has no data or an unexpected null.');
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
