import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

// Future<bool> saveDataToFirestore() async {
//   // Read JSON file
//   print("entered");
//   try {
//     print("loading");
//     String jsonString = await rootBundle.loadString('assets/input.json');
//     print("done");
//     List<dynamic> jsonData = json.decode(jsonString);

//     // Initialize Firestore
//     FirebaseFirestore firestore = FirebaseFirestore.instance;

//     // Initialize batch for batched writes
//     WriteBatch batch = firestore.batch();

//     // Initialize variables to calculate aggregate data
//     Map<String, dynamic> aggregateData = {};

//     // Loop through each instance in the JSON data and save it to Firestore
//     for (var data in jsonData) {
//       // Prepare data for Firestore
//       Map<String, dynamic> firestoreData = {
//         'workYear': data['work_year'],
//         'jobTitle': data['job_title'],
//         'salaryUSD': int.parse(data['salary_in_usd']),
//       };
//       print(firestoreData);

//       // Add data to batched write
//       DocumentReference docRef = firestore
//           .collection('salary')
//           .doc(data['work_year'])
//           .collection('data')
//           .doc();
//       batch.set(docRef, firestoreData);

//       // Update aggregate data
//       aggregateData[data['work_year']] ??= {'totalJobs': 0, 'totalSalary': 0};
//       aggregateData[data['work_year']]['totalJobs']++;
//       aggregateData[data['work_year']]['totalSalary'] +=
//           int.parse(data['salary_in_usd']);
//     }

//     // Commit the batched write
//     await batch.commit();

//     // Calculate average salary for each year and save aggregate data to Firestore using another batch
//     WriteBatch aggregateBatch = firestore.batch();
//     aggregateData.forEach((year, data) {
//       double avgSalary = data['totalSalary'] / data['totalJobs'];
//       DocumentReference docRef = firestore.collection('salary').doc(year);
//       aggregateBatch.set(docRef, {
//         'year': year,
//         'averageSalaryUSD': avgSalary,
//         'totalJobs': data['totalJobs'],
//       });
//     });

//     // Commit the aggregate batched write
//     await aggregateBatch.commit();
//     print('Data saved to Firestore');
//     return true;
//   } catch (e) {
//     print("error");
//     print(e.toString());
//     return false;
//   }
// }

Future<bool> saveDataToFirestore() async {
  try {
    // Read JSON file
    print("entered");
    String jsonString = await rootBundle.loadString('assets/input.json');
    print("loading");
    List<dynamic> jsonData = json.decode(jsonString);
    print("done");

    // Initialize Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Initialize batch for batched writes
    WriteBatch batch = firestore.batch();

    // Initialize variables to calculate aggregate data
    Map<String, Map<String, dynamic>> yearAggregateData = {};

    // Loop through each instance in the JSON data and save it to Firestore
    for (var data in jsonData) {
      // Prepare data for Firestore
      String workYear = data['work_year'];
      String jobTitle = data['job_title'];
      int salaryUSD = int.parse(data['salary_in_usd']);

      // Add data to batched write for individual job
      DocumentReference jobDocRef = firestore
          .collection('salary')
          .doc(workYear)
          .collection('data')
          .doc(jobTitle);
      batch.set(
        jobDocRef,
        {
          'totalJobs': FieldValue.increment(1),
          'totalSalaryUSD': FieldValue.increment(salaryUSD),
        },
        SetOptions(merge: true), // Merge data if doc exists
      );

      // Update aggregate data for the year and job title
      yearAggregateData[workYear] ??= {};
      yearAggregateData[workYear]![jobTitle] ??= {
        'totalJobs': 0,
        'totalSalaryUSD': 0,
      };
      yearAggregateData[workYear]![jobTitle]['totalJobs']++;
      yearAggregateData[workYear]![jobTitle]['totalSalaryUSD'] += salaryUSD;
    }

    // Commit the batched write for individual jobs
    await batch.commit();

    // Calculate average salary for each year and save aggregate data to Firestore using another batch
    WriteBatch aggregateBatch = firestore.batch();
    yearAggregateData.forEach((year, jobData) {
      // Calculate aggregate data for the year
      int totalJobs = jobData.values.fold<int>(
        0,
        (previousValue, data) => previousValue + data['totalJobs'] as int,
      );
      int totalSalaryUSD = jobData.values.fold<int>(
        0,
        (previousValue, data) => previousValue + data['totalSalaryUSD'] as int,
      );
      double avgSalaryUSD = totalJobs != 0 ? totalSalaryUSD / totalJobs : 0;

      // Update aggregate data for the year
      DocumentReference yearDocRef = firestore.collection('salary').doc(year);
      aggregateBatch.set(
        yearDocRef,
        {
          'totalJobs': totalJobs,
          'averageSalaryUSD': avgSalaryUSD,
        },
        SetOptions(merge: true), // Merge data if doc exists
      );
    });

    // Commit the aggregate batched write
    await aggregateBatch.commit();
    print('Data saved to Firestore');
    return true;
  } catch (e) {
    print("error");
    print(e.toString());
    return false;
  }
}

// Future<List<Map<String, dynamic>>> getDataFromJson() async {
//   try {
//     // Read JSON file
//     String jsonString = await rootBundle.loadString('assets/output.json');
//     List<dynamic> jsonData = json.decode(jsonString);

//     // Initialize aggregate data list
//     List<Map<String, dynamic>> aggregateData = [];

//     // Initialize a map to store aggregate data for each year
//     Map<String, Map<String, dynamic>> yearAggregateMap = {};

//     // Iterate through JSON data and calculate aggregate data
//     for (var data in jsonData) {
//       String year = data['work_year'].toString();

//       // Check if the year already exists in the map
//       if (yearAggregateMap.containsKey(year)) {
//         // Update aggregate data for the existing year
//         yearAggregateMap[year]!['totalJobs']++;
//         yearAggregateMap[year]!['totalSalaryUSD'] += data['salary_in_usd'];

//         // Update the job title count
//         List<Map<String, dynamic>> temp = yearAggregateMap[year]!['jobs'];
//         var jobEntry = temp.firstWhere(
//             (element) => element['title'] == data['job_title'],
//             orElse: () => {'title': data['job_title'], 'totalJobs': 0});

//         if (jobEntry['totalJobs'] == 0) {
//           temp.add(jobEntry); // Add new job entry if it didn't exist
//         } else {
//           temp.remove(jobEntry); // Remove existing entry to update it
//         }

//         jobEntry['totalJobs']++;
//         temp.add(jobEntry);

//         yearAggregateMap[year]!['jobs'] = temp;
//       } else {
//         // Add a new entry for the year in the map
//         yearAggregateMap[year] = {
//           'year': year,
//           'totalJobs': 1,
//           'totalSalaryUSD': data['salary_in_usd'],
//           'jobs': [
//             {'title': data['job_title'], 'totalJobs': 1}
//           ],
//         };
//       }
//     }

//     // Convert the map values to a list
//     aggregateData = yearAggregateMap.values.toList();

//     // Calculate average salary for each year
//     aggregateData.forEach((yearData) {
//       yearData['averageSalaryUSD'] =
//           yearData['totalSalaryUSD'] ~/ yearData['totalJobs'];
//     });

//     // Sort the list by year
//     aggregateData.sort((a, b) => a['year'].compareTo(b['year']));

//     return aggregateData;
//   } catch (e) {
//     // Handle any errors that occur during the process
//     print("Error: $e");
//     return []; // Return an empty list in case of an error
//   }
// }

//ORIGINAL_ONE
// Future<List<Map<String, dynamic>>> getDataFromJson() async {
//   try {
//     // Read JSON file
//     String jsonString = await rootBundle.loadString('assets/output.json');
//     List<dynamic> jsonData = json.decode(jsonString);

//     // Initialize aggregate data list
//     List<Map<String, dynamic>> aggregateData = [];

//     // Initialize a map to store aggregate data for each year
//     Map<String, Map<String, dynamic>> yearAggregateMap = {};

//     // Iterate through JSON data and calculate aggregate data
//     for (var data in jsonData) {
//       String year = data['work_year'];

//       // Check if the year already exists in the map
//       if (yearAggregateMap.containsKey(year)) {
//         // Update aggregate data for the existing year
//         yearAggregateMap[year]!['totalJobs']++;
//         yearAggregateMap[year]!['totalSalaryUSD'] +=
//             int.parse(data['salary_in_usd']);
//       } else {
//         // Add a new entry for the year in the map
//         yearAggregateMap[year] = {
//           'year': year,
//           'totalJobs': 1,
//           'totalSalaryUSD': int.parse(data['salary_in_usd']),
//         };
//       }
//     }

//     // Convert the map values to a list
//     aggregateData = yearAggregateMap.values.toList();

//     // Calculate average salary for each year
//     aggregateData.forEach((yearData) {
//       yearData['averageSalaryUSD'] =
//           yearData['totalSalaryUSD'] ~/ yearData['totalJobs'];
//     });

//     // Sort the list by year
//     aggregateData.sort((a, b) => a['year'].compareTo(b['year']));

//     return aggregateData;
//   } catch (e) {
//     // Handle any errors that occur during the process
//     print("Error: $e");
//     return []; // Return an empty list in case of an error
//   }
// }

Future<List<Map<String, dynamic>>> getDataFromJson() async {
  try {
    // Read JSON file
    String jsonString = await rootBundle.loadString('assets/output.json');
    List<dynamic> jsonData = json.decode(jsonString);

    // Initialize aggregate data list
    List<Map<String, dynamic>> aggregateData = [];

    // Initialize a map to store aggregate data for each year
    Map<String, Map<String, dynamic>> yearAggregateMap = {};

    // Iterate through JSON data and calculate aggregate data
    for (var data in jsonData) {
      String year = data['work_year'];
      String jobTitle = data['job_title'];

      // Check if the year already exists in the map
      if (yearAggregateMap.containsKey(year)) {
        // Update aggregate data for the existing year
        yearAggregateMap[year]!['totalJobs']++;
        yearAggregateMap[year]!['totalSalaryUSD'] +=
            int.parse(data['salary_in_usd']);

        // Update job title data for the existing year
        bool jobExists = false;
        for (var job in yearAggregateMap[year]!['jobs']) {
          if (job['title'] == jobTitle) {
            job['totalJobs']++;
            jobExists = true;
            break;
          }
        }
        if (!jobExists) {
          yearAggregateMap[year]!['jobs'].add({
            'title': jobTitle,
            'totalJobs': 1,
            'color': _generateRandomColor(), // Assign random color
          });
        }
      } else {
        // Add a new entry for the year in the map
        yearAggregateMap[year] = {
          'year': year,
          'totalJobs': 1,
          'totalSalaryUSD': int.parse(data['salary_in_usd']),
          'jobs': [
            {
              'title': jobTitle,
              'totalJobs': 1,
              'color': _generateRandomColor(), // Assign random color
            },
          ],
        };
      }
    }

    // Convert the map values to a list
    aggregateData = yearAggregateMap.values.toList();

    // Calculate average salary for each year
    aggregateData.forEach((yearData) {
      yearData['averageSalaryUSD'] = yearData['totalJobs'] != 0
          ? (yearData['totalSalaryUSD'] / yearData['totalJobs']).toDouble()
          : 0.0;

      // Round the average salary to two decimal places
      yearData['averageSalaryUSD'] =
          double.parse(yearData['averageSalaryUSD'].toStringAsFixed(2));
    });

    // Sort the list by year
    aggregateData.sort((a, b) => a['year'].compareTo(b['year']));

    return aggregateData;
  } catch (e) {
    // Handle any errors that occur during the process
    print("Error: $e");
    return []; // Return an empty list in case of an error
  }
}

// Function to generate a random color
Color _generateRandomColor() {
  Random random = Random();
  return Color.fromRGBO(
    random.nextInt(256),
    random.nextInt(256),
    random.nextInt(256),
    1,
  );
}

// Future<List<Map<String, dynamic>>> getDataFromFirestore() async {
//   try {
//     // Initialize Firestore
//     FirebaseFirestore firestore = FirebaseFirestore.instance;

//     // Initialize a query to retrieve data from Firestore
//     QuerySnapshot<Map<String, dynamic>> querySnapshot =
//         await firestore.collection('salary').get(GetOptions(source: Source.serverAndCache));

//     // Initialize aggregate data list
//     List<Map<String, dynamic>> aggregateData = [];

//     // Iterate through Firestore documents and calculate aggregate data
//     for (QueryDocumentSnapshot<Map<String, dynamic>> document
//         in querySnapshot.docs) {
//       String year = document.id;

//       // Extract data from the document
//       int totalJobs = 0;
//       int totalSalaryUSD = 0;
//       List<dynamic> jobs = [];

//       // Get data collection for the year
//       QuerySnapshot<Map<String, dynamic>> dataQuerySnapshot = await firestore
//           .collection('salary')
//           .doc(year)
//           .collection('data')
//           .get(GetOptions(source: Source.serverAndCache));

//       // Iterate through data collection documents and calculate aggregate data
//       for (QueryDocumentSnapshot<Map<String, dynamic>> dataDocument
//           in dataQuerySnapshot.docs) {
//         // Extract data from the document
//         String jobTitle = dataDocument.data()['jobTitle'];
//         int salaryUSD = dataDocument.data()['salaryUSD'];

//         // Update aggregate data
//         totalJobs++;
//         totalSalaryUSD += salaryUSD;
//         jobs.add({'title': jobTitle, 'salaryUSD': salaryUSD});
//       }

//       // Calculate average salary for the year
//       double averageSalaryUSD = totalJobs != 0 ? totalSalaryUSD / totalJobs : 0;

//       // Construct year data
//       Map<String, dynamic> yearData = {
//         'year': year,
//         'totalJobs': totalJobs,
//         'totalSalaryUSD': totalSalaryUSD,
//         'averageSalaryUSD': averageSalaryUSD,
//         'jobs': jobs,
//       };

//       // Add year data to the aggregate data list
//       aggregateData.add(yearData);
//     }

//     return aggregateData;
//   } catch (e) {
//     // Handle any errors that occur during the process
//     print("Error: $e");
//     return []; // Return an empty list in case of an error
//   }
// }

Future<List<Map<String, dynamic>>> getDataFromFirestore() async {
  try {
    // Initialize Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Initialize aggregate data list
    List<Map<String, dynamic>> aggregateData = [];

    // Retrieve all years
    QuerySnapshot<Map<String, dynamic>> yearSnapshot = await firestore
        .collection('salary')
        .get(GetOptions(source: Source.serverAndCache));

    // Process each year
    for (QueryDocumentSnapshot<Map<String, dynamic>> yearDoc
        in yearSnapshot.docs) {
      String year = yearDoc.id;
      final avgSalUSD = yearDoc['averageSalaryUSD'];
      final totalJs = yearDoc['totalJobs'];

      // Get data collection for the year
      QuerySnapshot<Map<String, dynamic>> dataQuerySnapshot = await firestore
          .collection('salary')
          .doc(year)
          .collection('data')
          .get(GetOptions(source: Source.serverAndCache));

      // Extract job details
      List<Map<String, dynamic>> jobs = [];

      // Random color generator
      final random = Random();

      // Process each job data document
      for (QueryDocumentSnapshot<Map<String, dynamic>> dataDoc
          in dataQuerySnapshot.docs) {
        String jobTitle = dataDoc.id;

        // Generate a random color for the job title
        Color randomColor = Color.fromRGBO(
          random.nextInt(256),
          random.nextInt(256),
          random.nextInt(256),
          1,
        );

        // Add job details to the list with the random color
        jobs.add({
          'title': jobTitle,
          'totalJobs': dataDoc.data()['totalJobs'],
          'totalSalaryUSD': dataDoc.data()['totalSalaryUSD'],
          'color': randomColor, // Assign the random color to the job title
        });
      }

      // Construct year data
      Map<String, dynamic> yearData = {
        'year': year,
        'totalJobs': totalJs,
        'averageSalaryUSD': double.parse(avgSalUSD.toStringAsFixed(2)),
        'jobs': jobs,
      };

      // Add year data to the aggregate data list
      aggregateData.add(yearData);
    }

    return aggregateData;
  } catch (e) {
    // Handle any errors that occur during the process
    print("Error: $e");
    return []; // Return an empty list in case of an error
  }
}
