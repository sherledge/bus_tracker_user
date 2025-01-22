import 'package:bus_tracker_user/providers/recently_selected_buses_provider.dart';
import 'package:bus_tracker_user/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class LiveTrackingScreen extends StatelessWidget {
  final String busId;
  final LocationService _locationService =
      LocationService(); // Create instance of location service
final int estimatedTime;
  LiveTrackingScreen({required this.busId, this.estimatedTime=0});

  @override
  Widget build(BuildContext context) {
        final provider = Provider.of<RecentlySelectedBusesProvider>(context);
    final estimatedTime = provider.getEstimatedTime(busId);
    return Scaffold(
      appBar: AppBar(
          title: Text(
        '$busId',
        style: TextStyle(fontFamily: 'Coda', fontSize: 30),
      )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('buses')
              .doc(busId)
              .snapshots(),
          builder: (context, busSnapshot) {
            if (!busSnapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            var busData = busSnapshot.data!.data() as Map<String, dynamic>?;
            if (busData == null || busData['currentStop'] == null) {
              return Center(child: Text('Bus stop information not available'));
            }

            // Extract current stop name from the bus document
            final currentStopName = busData['currentStop'] as String;

            // Define a list of stop names and locations for demonstration
            final stops = [
              {'name': 'Stop 1', 'latitude': 12.934533, 'longitude': 77.610116},
              {'name': 'Stop 2', 'latitude': 12.953847, 'longitude': 77.621540},
              {'name': 'Stop 3', 'latitude': 12.976883, 'longitude': 77.601801},
              {'name': 'Stop 4', 'latitude': 12.999290, 'longitude': 77.592673},
              {'name': 'Stop 5', 'latitude': 12.985517, 'longitude': 77.555612},
              {'name': 'Stop 6', 'latitude': 13.002649, 'longitude': 77.579985},
              {'name': 'Stop 7', 'latitude': 12.943698, 'longitude': 77.590983},
              {'name': 'Stop 8', 'latitude': 12.975574, 'longitude': 77.533768},
              {
                'name': 'Stop 9',
                'latitude': 10.4018104,
                'longitude': 76.3664748
              },
              {
                'name': 'Stop 10',
                'latitude': 13.020393,
                'longitude': 77.642643
              },
            ];

            return ListView.builder(
              itemCount: stops.length,
              itemBuilder: (context, index) {
                final stop = stops[index];
                final stopName = stop['name'];
                final isCurrentStop = currentStopName == stopName;

                return FutureBuilder<Position>(
                  future: _locationService
                      .getCurrentLocation(), // Fetch user location
                  builder: (context, locationSnapshot) {
                    if (!locationSnapshot.hasData) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(width: 4, height: 70, color: Colors.black),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 35,
                                height: 5,
                                color:
                                    isCurrentStop ? Colors.green : Colors.black,
                              ),
                              SizedBox(width: 10),
                              Text(
                                stopName as String,
                                style: TextStyle(
                                  fontFamily: 'Coda',
                                  fontWeight: isCurrentStop
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isCurrentStop
                                      ? Colors.green
                                      : Colors.black,
                                ),
                              ),
                              if (isCurrentStop)
                                Icon(
                                  Icons.directions_bus,
                                  color: Colors.green,
                                ),
                            ],
                          ),
                        ],
                      );
                    }

                    // Check if the user is near the stop
                    bool isUserNear = _locationService.isUserNearStop(
                      locationSnapshot.data!.latitude,
                      locationSnapshot.data!.longitude,
                      stop['latitude'] as double,
                      stop['longitude'] as double,
                      50.0, // Proximity radius of 50 meters
                    );

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 4, height: 70, color: Colors.black),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 35,
                              height: 5,
                              color:
                                  isCurrentStop ? Colors.green : Colors.black,
                            ),
                            SizedBox(width: 10),
                            Text(
                              stopName as String,
                              style: TextStyle(
                                fontFamily: 'Coda',
                                fontWeight: isCurrentStop
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color:
                                    isCurrentStop ? Colors.green : Colors.black,
                              ),
                            ),
                            if (isCurrentStop)
                              Icon(
                                Icons.directions_bus,
                                color: Colors.green,
                              ),
                            if (isUserNear)
                              Icon(
                                Icons.person_pin_circle,
                                color: Colors.blue, // User icon
                              ),
                              
                               if (isCurrentStop)
                              Text(estimatedTime==0 ? '': 'Arriving in $estimatedTime Minutes [Est]')
                          ],
                          
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
