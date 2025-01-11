import "package:flutter/material.dart";
import "package:sighttrack_app/design.dart";
import "package:sighttrack_app/services/data_service.dart";
import "package:sighttrack_app/components/lists.dart";
import "package:sighttrack_app/logging.dart";
import "package:fl_chart/fl_chart.dart";

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  Map<String, dynamic>? analysisData;
  bool isLoading = true;
  String? errorMessage;

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
      logger.e("Failed to fetch analysis data: $e $stack");
      if (!mounted) return;
      setState(() {
        errorMessage = "Failed to load data";
        isLoading = false;
      });
    }
  }

  String getMonthName(int month) {
    const List<String> months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[month - 1];
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String currentMonth = getMonthName(now.month);

    final Color accentColor = Colors.teal.shade200;
    const Color textColor = Colors.black87;

    return Scaffold(
      body: Padding(
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
                        const SizedBox(height: 55),
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.data_exploration,
                                size: 200,
                                color: Colors.teal,
                              ),
                              Text(
                                "An overview of our trends",
                                style: Looks.captionStyle,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text("Basic statistics", style: Looks.headerStyle),
                        const SizedBox(height: 10),
                        Column(
                          children: [
                            ListTileAndIcon(
                              title: "Uploads This $currentMonth",
                              value: "${analysisData!['currentMonthUploads']}",
                              icon: Icons.upload,
                              color: Colors.red,
                            ),
                            ListTileAndIcon(
                              title: "Uploads Last Month",
                              value: "${analysisData!['previousMonthUploads']}",
                              icon: Icons.upload,
                              color: Colors.green,
                            ),
                            ListTileAndIcon(
                              title: "Total Uploads",
                              value: "${analysisData!['totalUploads']}",
                              icon: Icons.upload,
                              color: Colors.orange,
                            ),
                            Divider(
                              color: Colors.black,
                              thickness: 2,
                            ),
                            ListTileAndIcon(
                              title: "Total Users",
                              value: "${analysisData!['totalUsers']}",
                              icon: Icons.person,
                              color: Colors.blue,
                            ),
                            ListTileAndIcon(
                              title: "Time Between Uploads",
                              value: _formatTimeDuration(
                                (analysisData!["timeBetweenUploads"] as num)
                                    .toInt(),
                              ),
                              icon: Icons.timer,
                              color: Colors.cyan,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Uploads/month",
                              style: TextStyle(fontSize: 20),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(25, 15, 25, 10),
                              child: _buildMonthlyTrendsChart(
                                analysisData!["monthlyTrends"],
                                Colors.lightGreen,
                              ),
                            ),
                          ],
                        ),
                        Text("Species Statistics", style: Looks.headerStyle),
                        const SizedBox(height: 10),
                        Text("Common Species", style: Looks.subHeadStyle),
                        _buildCommonSpeciesList(
                          analysisData!["commonSpecies"],
                          textColor,
                        ),
                        const SizedBox(height: 30),
                        Text("User Leaderboard", style: Looks.headerStyle),
                        const SizedBox(height: 10),
                        _buildTopUsersList(
                          analysisData!["topUsers"],
                          Looks.subHeadStyle,
                          accentColor,
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildCommonSpeciesList(List<dynamic> commonSpecies, Color textColor) {
    if (commonSpecies.isEmpty) {
      return const Center(
        child: Text(
          "No species data available.",
          style: TextStyle(color: Colors.black87),
        ),
      );
    }

    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: commonSpecies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          var species = commonSpecies[index];
          return Chip(
            avatar: CircleAvatar(
              backgroundColor: Colors.teal.shade700,
              child: Text(
                "${index + 1}",
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
            label: Text(
              "${species['label']} (${species['count']})",
              style: TextStyle(color: textColor),
            ),
            backgroundColor: Colors.teal.shade100,
          );
        },
      ),
    );
  }

  Widget _buildMonthlyTrendsChart(
    Map<String, dynamic> monthlyData,
    Color primaryColor,
  ) {
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
    List<dynamic> topUsers,
    TextStyle textStyle,
    Color dividerColor,
  ) {
    if (topUsers.isEmpty) {
      return const Center(
        child: Text(
          "No user data available.",
          style: TextStyle(color: Colors.black87),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: topUsers.asMap().entries.map((entry) {
        int index = entry.key;
        var user = entry.value;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Ranking badge
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.teal.shade800,
                        ),
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // User ID
                      Text(
                        user["userId"].toString(),
                        style: textStyle,
                      ),
                    ],
                  ),
                  // Count
                  Text(
                    "${user['count']} points",
                    style: textStyle,
                  ),
                ],
              ),
            ),
            if (index < topUsers.length - 1)
              Divider(
                color: dividerColor,
                thickness: 1,
                height: 0, // Aligns tightly with rows
              ),
          ],
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
