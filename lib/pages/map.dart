import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartlocker/pages/home.dart';
import 'package:smartlocker/pages/settings.dart';

class MapPage extends StatefulWidget {
  final String deviceId;

  const MapPage({Key? key, required this.deviceId}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final FirebaseDatabase database;
  GoogleMapController? _googleMapController;
  LatLng _currentPosition = LatLng(6.821934686130015, 80.04154817409899); // Initial position
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    database = FirebaseDatabase(databaseURL: "https://smartlockerintellilock-default-rtdb.asia-southeast1.firebasedatabase.app");
    _fetchLocation();
  }

  void _fetchLocation() {
    DatabaseReference ref = database.ref('${widget.deviceId}/location');
    ref.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        final latitude = data['latitude'] as double?;
        final longitude = data['longitude'] as double?;
        if (latitude != null && longitude != null) {
          setState(() {
            _currentPosition = LatLng(latitude, longitude);
            _isLoading = false;
          });
          _googleMapController?.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: _currentPosition, zoom: 15),
          ));
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
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _googleMapController = controller;
    if (!_isLoading) {
      controller.animateCamera(CameraUpdate.newLatLng(_currentPosition));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Location'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SizedBox(
        height: 300, // Specify the height you want
        width: double.infinity, // Use double.infinity to match the parent's width
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
            ? Center(child: Text(_errorMessage))
            : GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(target: _currentPosition, zoom: 15),
          markers: {
            if (_currentPosition != null)
              Marker(
                markerId: MarkerId('deviceLocation'),
                position: _currentPosition,
              ),
          },
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: 0,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
              break;
            case 1:
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => SettingsPage()));
              break;
          }
        },
      ),
    );
  }
}
