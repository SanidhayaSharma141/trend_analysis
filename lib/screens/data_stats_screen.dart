import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:trend_analysis/functions/functions.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:trend_analysis/widgets/custom_table.dart';

class trend_analysisScreen extends StatefulWidget {
  static String routeName = '/salary-statistics';
  final bool isLocal;

  const trend_analysisScreen({super.key, required this.isLocal});

  @override
  _trend_analysisScreenState createState() => _trend_analysisScreenState();
}

class _trend_analysisScreenState extends State<trend_analysisScreen> {
  String? selectedYear;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Salary Statistics'),
      ),
      body: FutureBuilder(
        future: widget.isLocal ? getDataFromJson() : getDataFromFirestore(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          print(snapshot.data![0]);
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Line chart for average salary
                SfCartesianChart(
                  tooltipBehavior: TooltipBehavior(enable: true),
                  primaryXAxis: CategoryAxis(),
                  title: ChartTitle(text: 'ML Engineer Salaries (2020-2024)'),
                  series: [
                    LineSeries<Map<String, dynamic>, String>(
                      dataSource: snapshot.data!,
                      xValueMapper: (data, _) => data['year'].toString(),
                      yValueMapper: (data, _) => data['averageSalaryUSD'],
                      name: 'Average Salary (USD)',
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                // Line chart for total jobs
                SfCartesianChart(
                  tooltipBehavior: TooltipBehavior(enable: true),
                  primaryXAxis: CategoryAxis(),
                  primaryYAxis: NumericAxis(),
                  title: ChartTitle(text: 'Total Jobs (2020-2024)'),
                  series: [
                    LineSeries<Map<String, dynamic>, String>(
                      dataSource: snapshot.data!,
                      xValueMapper: (data, _) => data['year'].toString(),
                      yValueMapper: (data, _) => data['totalJobs'],
                      name: 'Total Jobs',
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                // Pie chart for job title vs total jobs

                SizedBox(height: 16.0),
                // Main table
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.all(8.0),
                  child: CustomTable(
                    data: snapshot.data!,
                    onRowTap: (rowData) {
                      setState(() {
                        selectedYear = rowData['year'];
                      });
                    },
                  ),
                ),
                SizedBox(height: 16.0),
                if (selectedYear != null)
                  Column(
                    children: [
                      SizedBox(height: 16.0),
                      // Pie chart
                      Container(
                        child: SfCircularChart(
                          series: <CircularSeries>[
                            PieSeries<Map<String, dynamic>, String>(
                              dataSource: snapshot.data!
                                  .firstWhere((element) =>
                                      element['year'] == selectedYear)['jobs']
                                  .toList(),
                              selectionBehavior:
                                  SelectionBehavior(enable: true),
                              xValueMapper: (data, _) => data['title'],
                              yValueMapper: (data, _) => data['totalJobs'],
                              dataLabelSettings: DataLabelSettings(
                                isVisible: false,
                              ),
                              onPointTap: (pointInteractionDetails) {
                                String cat = snapshot.data!.firstWhere(
                                            (element) =>
                                                element['year'] ==
                                                selectedYear)['jobs']
                                        [pointInteractionDetails.pointIndex!]
                                    ['title'];
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text(cat)));
                              },
                              pointColorMapper: (data, _) => data[
                                  'color'], // Map color for each data point
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: snapshot.data!
                              .firstWhere((element) =>
                                  element['year'] == selectedYear)['jobs']
                              .map<Widget>((job) {
                            return Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: job[
                                      'color'], // Assuming you have 'color' property for job
                                ),
                                SizedBox(width: 4),
                                Text(
                                  job['title']
                                      .toString(), // Assuming 'title' is the job title
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(width: 8),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),

                if (selectedYear != null)
                  Divider(
                    color: Colors.grey,
                    thickness: 2.0,
                  ),
                if (selectedYear != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Detailed Job Information for $selectedYear',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (selectedYear != null)
                  Divider(
                    color: Colors.grey,
                    thickness: 2.0,
                  ),
                if (selectedYear != null)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: CustomJobTable(
                      fdata: snapshot.data!.firstWhere(
                          (element) => element['year'] == selectedYear),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
