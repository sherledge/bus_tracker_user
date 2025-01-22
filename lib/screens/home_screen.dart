import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../providers/recently_selected_buses_provider.dart';
import 'stop_selection_screen.dart';
import 'bus_list_screen.dart';
import 'live_bus_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  String _fromLocation = 'Current bus stop';
  String _toLocation = 'Destination';
  bool _locationPermissionGranted = false;
  bool _isPermissionPermanentlyDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLocationPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocationPermission();
    }
  }

  Future<void> _checkLocationPermission() async {
    PermissionStatus status = await Permission.locationWhenInUse.status;
    if (status.isGranted) {
      setState(() {
        _locationPermissionGranted = true;
        _isPermissionPermanentlyDenied = false;
      });
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _isPermissionPermanentlyDenied = true;
      });
    } else {
      _locationPermissionGranted = false;
    }
  }

  Future<void> _requestLocationPermission() async {
    PermissionStatus status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      setState(() {
        _locationPermissionGranted = true;
      });
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _isPermissionPermanentlyDenied = true;
      });
    }
  }

  void _openAppSettings() {
    openAppSettings();
  }

  void _selectFromLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StopSelectionScreen()),
    );
    if (result != null) {
      setState(() {
        _fromLocation = result;
      });
    }
  }

  void _selectToLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StopSelectionScreen()),
    );
    if (result != null) {
      setState(() {
        _toLocation = result;
      });
    }
  }

  void _searchForBuses() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusListScreen(from: _fromLocation, to: _toLocation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDFAFA),
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: [
            Text('Bus Tracker', style: TextStyle(fontFamily: 'Coda')),
            SizedBox(height: 8.0),
            Divider(
              color: Colors.black.withOpacity(.2),
              thickness: 1.0,
              indent: 50,
              endIndent: 50,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: Offset(0, 2),
                  ),
                ],
                color: Color(0xFF77E5A4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onTap: _selectFromLocation,
                      child: Row(
                        children: [
                          Text(
                            'From:          ',
                            style: TextStyle(
                              fontFamily: 'Coda',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Opacity(
                            opacity: 0.5,
                            child: Text(
                              _fromLocation,
                              style: TextStyle(
                                fontFamily: 'Coda',
                                fontSize: 18,
                                color: Color(0xFF3C3C43),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 6),
                  Divider(
                    color: Colors.black.withOpacity(.2),
                    thickness: 1.0,
                    indent: 10,
                    endIndent: 10,
                  ),
                  SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onTap: _selectToLocation,
                      child: Row(
                        children: [
                          Text(
                            'To:                 ',
                            style: TextStyle(
                              fontFamily: 'Coda',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Opacity(
                            opacity: 0.5,
                            child: Text(
                              _toLocation,
                              style: TextStyle(
                                fontFamily: 'Coda',
                                fontSize: 18,
                                color: Color(0xFF3C3C43),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _searchForBuses,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Search for Bus', style: TextStyle(fontFamily: 'Coda')),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Consumer<RecentlySelectedBusesProvider>(
              builder: (context, provider, child) {
                final recentlySelectedBuses = provider.recentlySelectedBuses;
                if (recentlySelectedBuses.isEmpty) return SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recently Selected Buses',
                      style: TextStyle(
                       fontFamily: 'Coda',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    Column(
                      children: recentlySelectedBuses.entries.map((entry) {
                        final busId = entry.key;
                        final estimatedTime = entry.value;

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LiveTrackingScreen(busId: busId),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.directions_bus,
                                  color: Theme.of(context).primaryColor,
                                  size: 32,
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    busId,
                                    style: TextStyle(
                                                             fontFamily: 'Coda',

                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Arriving in $estimatedTime min',
                                  style: TextStyle(
                                                           fontFamily: 'Coda',

                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
            if (!_locationPermissionGranted)
              Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      _isPermissionPermanentlyDenied
                          ? 'Location Permission Required'
                          : 'Enable Location for Better Experience',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _isPermissionPermanentlyDenied
                          ? _openAppSettings
                          : _requestLocationPermission,
                      icon: Icon(Icons.settings, color: Colors.white),
                      label: Text(
                        _isPermissionPermanentlyDenied
                            ? 'Open Settings'
                            : 'Enable Location',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
