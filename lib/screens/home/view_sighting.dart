import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sighttrack/logging.dart';
import 'package:sighttrack/models/Sighting.dart';
import 'package:sighttrack/util.dart';

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
  late Future<String> _photoUrlFuture; // Cache the future
  bool? isAdminUser;

  Future<void> _checkAdminStatus() async {
    try {
      final isAdmin = await Util.isAdmin();
      setState(() {
        isAdminUser = isAdmin;
      });
    } catch (e) {
      Log.e('Error checking admin status: $e');
      setState(() {
        isAdminUser = false;
      });
    }
  }

  Future<void> _deleteSighting() async {
    try {
      await Amplify.DataStore.delete(widget.sighting);
      Log.i('Sighting deleted: ${widget.sighting.id}');
      if (mounted) {
        Navigator.pop(context); // Go back after deletion
      }
    } catch (e) {
      Log.e('Error deleting sighting: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete sighting: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _photoUrlFuture = ViewSightingScreen.loadSightingPhoto(
      widget.sighting.photo,
    );
    _checkAdminStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sighting Details'),
        actions: [
          if (isAdminUser == true) // Show delete button only for admins
            IconButton(
              icon: const Icon(Icons.delete, size: 26, color: Colors.red),
              tooltip: 'Delete Sighting',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: const Text(
                        'Delete Sighting',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: const Text(
                        'Are you sure you want to delete this sighting? This action cannot be undone.',
                        style: TextStyle(fontSize: 16),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontSize: 15, color: Colors.grey),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop(); // Close dialog
                            await _deleteSighting();
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
        ],
      ),
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
              future: _photoUrlFuture,
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
                  // Show actual image with GestureDetector
                  return GestureDetector(
                    onTap: () {
                      showDialog<void>(
                        context: context,
                        barrierDismissible:
                            true, // Allows closing by tapping outside
                        builder: (BuildContext context) {
                          return Dialog(
                            backgroundColor:
                                Colors.transparent, // Removes white border
                            elevation: 0, // Removes shadow
                            insetPadding: const EdgeInsets.all(
                              16,
                            ), // Padding from edges
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.9,
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.9,
                              ),
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Image.network(
                                    snapshot.data!,
                                    fit: BoxFit.contain,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.black54,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        image: DecorationImage(
                          image: NetworkImage(snapshot.data!),
                          fit: BoxFit.cover,
                        ),
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
                  alignment: Alignment.topLeft,
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
