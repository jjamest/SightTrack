import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sighttrack/models/Sighting.dart';
import 'package:sighttrack/screens/home/view_sighting.dart';

class AllSightingsScreen extends StatefulWidget {
  const AllSightingsScreen({super.key});

  @override
  State<AllSightingsScreen> createState() => _AllSightingsScreenState();
}

class _AllSightingsScreenState extends State<AllSightingsScreen> {
  late Future<List<Sighting>> _sightingsFuture;

  @override
  void initState() {
    super.initState();
    _sightingsFuture = _fetchAllSightings();
  }

  Future<List<Sighting>> _fetchAllSightings() async {
    try {
      final sightings = await Amplify.DataStore.query(Sighting.classType);
      // Sort by timestamp, most recent first
      sightings.sort(
        (a, b) => b.timestamp.getDateTimeInUtc().compareTo(
          a.timestamp.getDateTimeInUtc(),
        ),
      );
      return sightings;
    } catch (e) {
      print('Error fetching sightings: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Sightings',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20.0),
        ),
        elevation: 0,
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey[100], // Subtle light background
        child: FutureBuilder<List<Sighting>>(
          future: _sightingsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No sightings found',
                  style: TextStyle(fontSize: 16.0, color: Colors.grey),
                ),
              );
            }

            final sightings = snapshot.data!;

            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: sightings.length,
              itemBuilder: (context, index) {
                final sighting = sightings[index];
                return Material(
                  color: Colors.white,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  ViewSightingScreen(sighting: sighting),
                        ),
                      );
                    }, // Clickable but does nothing
                    splashColor: Colors.blueGrey.withOpacity(0.1),
                    highlightColor: Colors.grey.withOpacity(0.05),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1.0,
                          ),
                        ),
                        boxShadow: [
                          if (index == 0) // Subtle shadow on top item
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.05),
                              offset: const Offset(0, 1),
                              blurRadius: 2.0,
                            ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Species
                          Expanded(
                            flex: 2,
                            child: Text(
                              sighting.species,
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Details
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  sighting.user?.display_username ?? 'Unknown',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  DateFormat('MMM dd, HH:mm').format(
                                    sighting.timestamp
                                        .getDateTimeInUtc()
                                        .toLocal(),
                                  ),
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
