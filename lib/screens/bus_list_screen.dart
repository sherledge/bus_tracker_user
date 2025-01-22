import 'package:bus_tracker_user/providers/recently_selected_buses_provider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'live_bus_screen.dart';

// Predefined travel times in minutes between each pair of stops
final Map<String, int> travelTimes = {
  'stop1to2': 2,
  'stop2to3': 3,
  'stop3to4': 4,
  'stop4to5': 2,
  'stop5to6': 3,
  'stop6to7': 4,
  'stop7to8': 2,
  'stop8to9': 3,
  'stop9to10': 4,
};

class BusListScreen extends StatelessWidget {
  final String from;
  final String to;

  BusListScreen({required this.from, required this.to});

  @override
  Widget build(BuildContext context) {
    final recentlySelectedBusesProvider =
        Provider.of<RecentlySelectedBusesProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Buses from $from to $to',
        style: TextStyle(fontFamily: 'Coda'),),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('buses').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No buses available.'));
          }

          var filteredBuses = _filterBuses(snapshot.data!.docs, from, to);

          if (filteredBuses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset('assets/images/bus.png'),
                  Text(
                    'No buses found for the selected route.',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black.withOpacity(0.6),
                        fontFamily: 'Coda'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Divider(
                color: Colors.black.withOpacity(.2),
                thickness: 1.0,
                indent: 50,
                endIndent: 50,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredBuses.length,
                  itemBuilder: (context, index) {
                    var bus = filteredBuses[index];

                    // Calculate estimated time
                    int estimatedTime = calculateEstimatedTime(
                        from, // User's 'From' stop
                        bus['currentStop'], // Bus's current stop
                        from.compareTo(to) >
                            0, // userMovingBackwards based on from > to
                        bus['is_returning'] ??
                            false // isReturning flag from bus data
                        );

                    return Card(
                      
                      color: Color(0xFF77E5A4),
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1,
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display current location (bus stop) or 'Unknown' if the status is not 'active'
                            Row(
                              children: [
                                Text(
                                  'Current Location   ',
                                  style: TextStyle(
                                    fontFamily: 'Coda',
                                    fontSize: 14,
                                    color: Colors.black.withOpacity(
                                        0.5), // Light color for current location
                                  ),
                                ),
                                Text(
                                  bus['status'] == 'active'
                                      ? '${bus['currentStop']}'
                                      : 'Unknown',
                                  style: TextStyle(
                                      fontSize: 15, fontFamily: 'Coda'),
                                ),
                              ],
                            ),
                            SizedBox(
                                height:
                                    4), // Space between the current location and bus ID
                            Text(
                              bus['busId'], // Bus ID displayed below current location
                              style: TextStyle(
                                fontFamily: 'Coda',
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          bus['status'] == 'active'
                              ? 'Arriving in $estimatedTime minutes [Est]'
                              : 'Status: ${bus['status']}',
                          style: TextStyle(
                            fontFamily: 'Coda',
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                        trailing: bus['status'] == 'active'
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(
                                        color: Colors.black, width: 1),
                                  ),
                                ),
                                onPressed: () {
// Inside _searchForBuses method
recentlySelectedBusesProvider.addBus(bus.id, estimatedTime);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          LiveTrackingScreen(busId: bus.id,estimatedTime:estimatedTime),
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Live'),
                                    SizedBox(
                                        width:
                                            8), // Adds some space between the text and icon
                                    Icon(Icons.arrow_right_alt), // Arrow icon
                                  ],
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<QueryDocumentSnapshot> _filterBuses(
      List<QueryDocumentSnapshot> buses, String from, String to) {
    return buses.where((bus) {
      List<String> stops = List.from(bus['route']);
      int fromIndex = stops.indexOf(from);
      int toIndex = stops.indexOf(to);
      int busStopIndex = stops.indexOf(bus['currentStop']);
      bool isReturning = bus['is_returning'] ?? false;

      bool userMovingBackwards = fromIndex > toIndex;

      // Forward or backward journey filtering
      if (userMovingBackwards) {
        return isReturning && busStopIndex > fromIndex;
      } else {
        return !isReturning && busStopIndex < fromIndex;
      }
    }).toList();
  }

  int calculateEstimatedTime(String userStop, String busStop,
      bool userMovingBackwards, bool isReturning) {
    List<String> stops = [
      'Stop 1',
      'Stop 2',
      'Stop 3',
      'Stop 4',
      'Stop 5',
      'Stop 6',
      'Stop 7',
      'Stop 8',
      'Stop 9',
      'Stop 10'
    ];

    int totalTime = 0;
    int userIndex = stops.indexOf(userStop);
    int busIndex = stops.indexOf(busStop);

    if (userIndex == -1 || busIndex == -1) {
      throw ArgumentError('Invalid stop names');
    }

    // Forward journey (bus behind user)
    if (!userMovingBackwards && !isReturning && busIndex < userIndex) {
      for (int i = busIndex; i < userIndex; i++) {
        totalTime += travelTimes['stop${i + 1}to${i + 2}'] ?? 0;
      }
    }
    // Backward journey (bus ahead of user)
    else if (userMovingBackwards && isReturning && busIndex > userIndex) {
      for (int i = busIndex; i > userIndex; i--) {
        totalTime += travelTimes['stop${i}to${i - 1}'] ?? 0;
      }
    }

    return totalTime;
  }
}
