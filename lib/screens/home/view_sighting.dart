import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sighttrack/models/Sighting.dart';

class ViewSightingScreen extends StatefulWidget {
  final Sighting sighting;

  const ViewSightingScreen({super.key, required this.sighting});

  @override
  State<ViewSightingScreen> createState() => _ViewSightingScreenState();

  static Future<String> loadSightingPhoto(String path) async {
    final result =
        await Amplify.Storage.getUrl(
          path: StoragePath.fromString(path),
          options: const StorageGetUrlOptions(
            pluginOptions: S3GetUrlPluginOptions(
              validateObjectExistence: true,
              expiresIn: Duration(hours: 10),
            ),
          ),
        ).result;
    return result.url.toString();
  }
}

class _ViewSightingScreenState extends State<ViewSightingScreen> {
  bool _isLocationExpanded = false;
  bool _isTechnicalExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sighting Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.sighting.description != null &&
                widget.sighting.description!.isNotEmpty)
              _buildSection('Description', widget.sighting.description!),

            if (widget.sighting.user != null)
              _buildSection('User', widget.sighting.user!.display_username),

            FutureBuilder<String>(
              future: ViewSightingScreen.loadSightingPhoto(
                widget.sighting.photo,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show placeholder while loading
                  return Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: const Center(
                      child: Icon(Icons.image, size: 80, color: Colors.grey),
                    ),
                  );
                } else if (snapshot.hasError || snapshot.data == null) {
                  // Show placeholder if there's an error or no data
                  return Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: const Center(
                      child: Icon(Icons.image, size: 80, color: Colors.grey),
                    ),
                  );
                } else {
                  // Show actual image when loaded
                  return GestureDetector(
                    onTap: () {
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Sighting Photo'),
                            content: Image.network(snapshot.data!),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Close'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        snapshot.data!,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 20),
            _buildSection('Species', widget.sighting.species),
            _buildSection(
              'Timestamp',
              DateFormat(
                'MMMM dd, yyyy HH:mm',
              ).format(widget.sighting.timestamp.getDateTimeInUtc().toLocal()),
            ),

            Divider(),

            ExpansionTile(
              title: const Text(
                'Location Details',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              initiallyExpanded: _isLocationExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  _isLocationExpanded = expanded;
                });
              },
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        'Latitude',
                        '${widget.sighting.latitude}',
                      ),
                      _buildDetailRow(
                        'Longitude',
                        '${widget.sighting.longitude}',
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ),

            ExpansionTile(
              title: const Text(
                'Technical Details',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              initiallyExpanded: _isTechnicalExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  _isTechnicalExpanded = expanded;
                });
              },
              children: [
                Align(
                  // Wrap the Column in an Align widget
                  alignment: Alignment.topLeft, // Align to the top-left
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTechnicalDetailRow(
                          'Sighting ID',
                          widget.sighting.id,
                        ),
                        if (widget.sighting.user != null)
                          _buildTechnicalDetailRow(
                            'User ID',
                            widget.sighting.user!.id,
                          ),
                        _buildTechnicalDetailRow(
                          'Photo URL',
                          widget.sighting.photo,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          content,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(value, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
