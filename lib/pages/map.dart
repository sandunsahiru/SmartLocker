import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartlocker/pages/home.dart';
import 'package:smartlocker/pages/settings.dart';

class MapPage extends StatefulWidget {
  final String deviceId;

  const MapPage({Key? key, required this.deviceId}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _controller;
  final FirebaseDatabase database = FirebaseDatabase(
      databaseURL:
          "https://smartlockerintellilock-default-rtdb.asia-southeast1.firebasedatabase.app");
  GoogleMapController? mapController;

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Location'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder(
        stream: database.ref('${widget.deviceId}/location').onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = (snapshot.data! as DatabaseEvent).snapshot.value
                as Map<dynamic, dynamic>;
            final position =
                LatLng(data['latitude'] as double, data['longitude'] as double);
            _controller?.animateCamera(CameraUpdate.newLatLng(position));
            return GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: position,
                zoom: 10.0,
              ),
              markers: Set.from([
                Marker(
                  markerId: const MarkerId("deviceLocation"),
                  position: position,
                ),
              ]),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: 0,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context)
                .pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
          } else if (index == 1) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => SettingsPage()));
          }
        },
      ),
    );
  }
}
