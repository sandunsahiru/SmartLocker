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
  late final FirebaseDatabase database;
  GoogleMapController? mapController;
  LatLng _currentPosition = LatLng(6.821934686130015, 80.04154817409899);
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Initialize Firebase Database with the specified URL.
    database = FirebaseDatabase(databaseURL: "https://smartlockerintellilock-default-rtdb.asia-southeast1.firebasedatabase.app");
    print('Initializing MapPage with deviceId: ${widget.deviceId}'); // Print the device ID for debugging
    _listenToLocationChanges();
  }

  void _listenToLocationChanges() {
    print('Setting up location listener...'); // Indicates listener setup started
    DatabaseReference ref = database.ref('${widget.deviceId}/location');
    ref.onValue.listen((DatabaseEvent event) {
      print('Location data stream received: ${event.snapshot.value}'); // Indicates data received
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        final latitude = data['latitude'] as double?;
        final longitude = data['longitude'] as double?;
        print('Fetched Latitude: $latitude, Fetched Longitude: $longitude'); // Print the fetched coordinates

        if (latitude != null && longitude != null) {
          setState(() {
            _currentPosition = LatLng(latitude, longitude);
            _isLoading = false;
          });
          _updateMapLocation(_currentPosition);
        } else {
          setState(() {
            _errorMessage = 'Invalid location data';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'No location data available';
          _isLoading = false;
        });
      }
    }, onError: (error) {
      print('Error fetching location data: $error'); // Indicates an error occurred
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    });
  }

  void _updateMapLocation(LatLng position) {
    if (mapController != null) {
      mapController!.animateCamera(CameraUpdate.newLatLng(position));
    } else {
      print('Map controller not yet initialized');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
    if (!_isLoading) {
      _updateMapLocation(_currentPosition);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building MapPage...'); // Indicates the build method is running
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Location'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _currentPosition,
          zoom: 10.0,
        ),
        markers: Set.from([
          Marker(
            markerId: MarkerId("deviceLocation"),
            position: _currentPosition,
          ),
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: 0,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
          } else if (index == 1) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => SettingsPage()));
          }
        },
      ),
    );
  }
}
