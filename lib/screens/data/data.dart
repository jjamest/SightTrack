import 'package:flutter/material.dart';
import 'package:sighttrack_app/aws/dynamo.dart';
import 'package:sighttrack_app/logging.dart';
import 'package:fl_chart/fl_chart.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  Map<String, dynamic>? analysisData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      var d = await getDataAnalysis();
      if (!mounted) return;
      setState(() {
        analysisData = d;
        isLoading = false;
      });
    } catch (e, stack) {
      // Concatenate error and stack trace into a single string
      logger.e('Failed to fetch analysis data: $e $stack');
      if (!mounted) return;
      setState(() {
        errorMessage = 'Failed to load data';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Using a teal/green color scheme
    final Color primaryColor = Colors.teal.shade700;
    final Color accentColor = Colors.teal.shade200;
    final Color backgroundColor = Colors.teal.shade50;
    const Color textColor = Colors.black87;

    const headerStyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: textColor,
    );

    const cardTitleStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: textColor,
    );

    const cardValueStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );

    const captionStyle = TextStyle(
      fontSize: 12,
      color: Colors.black54,
    );

    const subHeadStyle = TextStyle(
      fontSize: 14,
      color: textColor,
      fontWeight: FontWeight.w400,
    );

    return Scaffold(
      body: Container(
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 20, 26, 26),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? Center(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),
                          Text("Overview", style: headerStyle),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            children: [
                              _buildInfoCard(
                                title: "Total Uploads",
                                value:
                                    "${analysisData!['totalUploadsSinceOldest']}",
                                titleStyle: cardTitleStyle,
                                valueStyle: cardValueStyle,
                                captionStyle: captionStyle,
                                cardColor: accentColor,
                              ),
                              _buildInfoCard(
                                title: "Current Month",
                                value:
                                    "${analysisData!['currentMonthUploads']}",
                                subtitle:
                                    "Prev: ${analysisData!['previousMonthUploads']}",
                                titleStyle: cardTitleStyle,
                                valueStyle: cardValueStyle,
                                captionStyle: captionStyle,
                                cardColor: accentColor,
                              ),
                              // Convert the averageTimeBetweenUploadsSeconds to int if needed
                              _buildInfoCard(
                                title: "Avg Time Between Uploads",
                                value: _formatTimeDuration(
                                  (analysisData![
                                              'averageTimeBetweenUploadsSeconds']
                                          as num)
                                      .toInt(),
                                ),
                                titleStyle: cardTitleStyle,
                                valueStyle: cardValueStyle,
                                captionStyle: captionStyle,
                                cardColor: accentColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Text("Monthly Upload Trends", style: headerStyle),
                          const SizedBox(height: 10),
                          _buildMonthlyTrendsChart(
                            analysisData!['monthlyTrends'],
                            primaryColor,
                          ),
                          const SizedBox(height: 30),
                          Text("Top Contributing Users", style: headerStyle),
                          const SizedBox(height: 10),
                          _buildTopUsersList(analysisData!['topUsers'],
                              subHeadStyle, accentColor),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    String? subtitle,
    required TextStyle titleStyle,
    required TextStyle valueStyle,
    required TextStyle captionStyle,
    required Color cardColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: titleStyle),
          const SizedBox(height: 4),
          Text(value, style: valueStyle),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(subtitle, style: captionStyle),
            ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTrendsChart(
      Map<String, dynamic> monthlyData, Color primaryColor) {
    var entries = monthlyData.entries.toList();
    entries.sort((a, b) => a.key.compareTo(b.key));

    List<BarChartGroupData> barGroups = [];
    int x = 0;
    for (var entry in entries) {
      double yValue = double.tryParse(entry.value.toString()) ?? 0.0;
      barGroups.add(
        BarChartGroupData(
          x: x,
          barRods: [
            BarChartRodData(
              toY: yValue,
              width: 16,
              color: primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
      x++;
    }

    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                // Use a double interval
                interval: 5.0,
                getTitlesWidget: (value, meta) {
                  return Text(
                    "${value.toInt()}",
                    style: const TextStyle(fontSize: 10, color: Colors.black87),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index < 0 || index >= entries.length) {
                    return const SizedBox.shrink();
                  }
                  String ym = entries[index].key; // 'YYYY-MM'
                  return Text(
                    ym,
                    style: const TextStyle(fontSize: 9, color: Colors.black87),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(),
            topTitles: AxisTitles(),
          ),
          gridData: FlGridData(show: false),
        ),
      ),
    );
  }

  Widget _buildTopUsersList(
      List<dynamic> topUsers, TextStyle subheadStyle, Color cardColor) {
    if (topUsers.isEmpty) {
      return const Text("No user data available.",
          style: TextStyle(color: Colors.black87));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: topUsers.map((u) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(u['userId'].toString(), style: subheadStyle),
              Text("${u['count']} uploads", style: subheadStyle),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatTimeDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    if (duration.inDays >= 1) {
      return "${duration.inDays} day${duration.inDays > 1 ? 's' : ''}";
    } else if (duration.inHours >= 1) {
      return "${duration.inHours} hour${duration.inHours > 1 ? 's' : ''}";
    } else if (duration.inMinutes >= 1) {
      return "${duration.inMinutes} minute${duration.inMinutes > 1 ? 's' : ''}";
    } else {
      return "$seconds seconds";
    }
  }
}
