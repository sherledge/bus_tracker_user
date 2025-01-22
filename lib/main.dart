import 'package:bus_tracker_user/providers/recently_selected_buses_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  options: FirebaseOptions(
    apiKey: 'AIzaSyD-25ieHTC9YF20E1UkQ5bdxK5Vn_RPqqQ',
    appId: '1:1054402456638:android:91efb96b3aeb5e7df1f56f',
    messagingSenderId: '1054402456638',
    projectId: 'bus-tracker-a57b9',
    storageBucket: 'bus-tracker-a57b9.appspot.com',
  ),
);
 runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecentlySelectedBusesProvider()),
      ],
      child: MyApp(),
    )
 );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Tracker',
      home: HomeScreen(),
    );
  }
}
