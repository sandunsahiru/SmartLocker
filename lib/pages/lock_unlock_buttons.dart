import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:smartlocker/pages/battery_details.dart';
import 'package:smartlocker/pages/map.dart';

class LockUnlockButtons extends StatefulWidget {
  final List<String> deviceNicknames;
  final Map<String, String> deviceIdMap; // Maps nicknames to deviceIds
  final Function(String deviceId) onSelectedDeviceChanged;

  const LockUnlockButtons({
    Key? key,
    required this.deviceNicknames,
    required this.deviceIdMap,
    required this.onSelectedDeviceChanged,
  }) : super(key: key);

  @override
  _LockUnlockButtonsState createState() => _LockUnlockButtonsState();
}

class _LockUnlockButtonsState extends State<LockUnlockButtons> {
  String? _selectedDeviceNickname;
  bool? _isLocked;
  bool _showBatteryDetails = false; // State to manage visibility of BatteryDetails
  late final FirebaseDatabase database;

  @override
  void initState() {
    super.initState();
    database = FirebaseDatabase(databaseURL: 'https://smartlockerintellilock-default-rtdb.asia-southeast1.firebasedatabase.app'); // Initialize with your database URL
    if (widget.deviceNicknames.isNotEmpty) {
      _selectedDeviceNickname = widget.deviceNicknames.first;
      _fetchLockStatus(widget.deviceIdMap[_selectedDeviceNickname]!);
    }
  }

  Future<void> _fetchLockStatus(String deviceId) async {
    DatabaseReference ref = database.ref('$deviceId/status');
    DatabaseEvent event = await ref.once();
    if (event.snapshot.exists) {
      setState(() {
        _isLocked = event.snapshot.value == true;
      });
    }
  }

  Future<void> _setLockStatus(String deviceId, bool lock) async {
    DatabaseReference ref = database.ref('$deviceId/status');
    await ref.set(lock);
    _fetchLockStatus(deviceId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_selectedDeviceNickname != null) ...[
          DropdownButton<String>(
            value: _selectedDeviceNickname,
            items: widget.deviceNicknames.map<DropdownMenuItem<String>>((String nickname) {
              return DropdownMenuItem<String>(
                value: nickname,
                child: Text(nickname),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                String deviceId = widget.deviceIdMap[newValue]!;
                widget.onSelectedDeviceChanged(deviceId); // Invoke the callback with the new device ID
                _fetchLockStatus(deviceId);
                setState(() {
                  _selectedDeviceNickname = newValue;
                });
              }
            },
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLocked == true ? () => _setLockStatus(widget.deviceIdMap[_selectedDeviceNickname!]!, false) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLocked == true ? Theme.of(context).colorScheme.secondary : Colors.grey,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('UNLOCK'),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLocked == false ? () => _setLockStatus(widget.deviceIdMap[_selectedDeviceNickname!]!, true) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLocked == false ? Theme.of(context).colorScheme.primary : Colors.grey,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('LOCK'),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _selectedDeviceNickname != null ? () {
              final deviceId = widget.deviceIdMap[_selectedDeviceNickname!];
              if (deviceId != null) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MapPage(deviceId: deviceId),
                ));
              }
            } : null,
            child: Text('Locate Me'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                // Toggling visibility instead of navigating to a new page
                _showBatteryDetails = !_showBatteryDetails;
              });
            },
            child: Text(_showBatteryDetails ? 'Hide Details' : 'Show Details'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
          Visibility(
            visible: _showBatteryDetails,
            child: _selectedDeviceNickname != null ? BatteryDetails(deviceId: widget.deviceIdMap[_selectedDeviceNickname!]!) : Container(),
          ),
        ],
      ],
    );
  }
}
