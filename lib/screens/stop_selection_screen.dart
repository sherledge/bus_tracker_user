import 'package:flutter/material.dart';

class StopSelectionScreen extends StatefulWidget {
  @override
  _StopSelectionScreenState createState() => _StopSelectionScreenState();
}

class _StopSelectionScreenState extends State<StopSelectionScreen> {
  // Placeholder list of stops
  final List<String> _allStops = ['Stop 1', 'Stop 2', 'Stop 3', 'Stop 4', 'Stop 5','Stop 6','Stop 7','Stop 8','Stop 9','Stop 10'];
  List<String> _filteredStops = [];

  @override
  void initState() {
    super.initState();
    _filteredStops = _allStops; // Initialize with all stops
  }

  void _filterStops(String query) {
    setState(() {
      _filteredStops = _allStops.where((stop) {
        return stop.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Stop'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterStops,
              decoration: InputDecoration(
                hintText: 'Search stops...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _filteredStops.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_filteredStops[index]),
            onTap: () {
              Navigator.pop(context, _filteredStops[index]);
            },
          );
        },
      ),
    );
  }
}
