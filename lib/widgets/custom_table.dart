import 'package:flutter/material.dart';

class CustomTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final Function(Map<String, dynamic>)? onRowTap;

  CustomTable({required this.data, this.onRowTap});

  @override
  _CustomTableState createState() => _CustomTableState();
}

class _CustomTableState extends State<CustomTable> {
  int? _sortColumnIndex;
  bool _sortAscending = true;
  late List<Map<String, dynamic>> _sortedData;

  @override
  void initState() {
    super.initState();
    _sortedData = List.from(widget.data);
  }

  void _sort<T>(Comparable<T> Function(Map<String, dynamic> d) getField,
      int columnIndex, bool ascending) {
    _sortedData.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });

    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        columns: [
          DataColumn(
            label: Text('Year'),
            onSort: (columnIndex, ascending) {
              _sort<String>(
                  (d) => d['year'].toString(), columnIndex, ascending);
            },
          ),
          DataColumn(
            label: Text('Total Jobs'),
            numeric: true,
            onSort: (columnIndex, ascending) {
              _sort<num>((d) => d['totalJobs'], columnIndex, ascending);
            },
          ),
          DataColumn(
            label: Text('Average Salary (USD)'),
            numeric: true,
            onSort: (columnIndex, ascending) {
              _sort<num>((d) => d['averageSalaryUSD'], columnIndex, ascending);
            },
          ),
        ],
        rows: _sortedData.map((rowData) {
          return DataRow(
            onSelectChanged: (isSelected) {
              if (isSelected != null && isSelected && widget.onRowTap != null) {
                widget.onRowTap!(rowData);
              }
            },
            cells: [
              DataCell(Text(rowData['year'].toString())),
              DataCell(Text(rowData['totalJobs'].toString())),
              DataCell(Text(rowData['averageSalaryUSD'].toString())),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class CustomJobTable extends StatelessWidget {
  final Map<String, dynamic> fdata;

  CustomJobTable({required this.fdata});

  @override
  Widget build(BuildContext context) {
    // print(fdata);
    List<Map<String, dynamic>> data = fdata['jobs'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        sortColumnIndex: 0,
        sortAscending: true,
        columns: [
          DataColumn(label: Text('Job Title')),
          DataColumn(label: Text('Total Jobs')),
        ],
        rows: data.map((rowData) {
          return DataRow(
            cells: [
              DataCell(Text(rowData['title'].toString())),
              DataCell(Text(rowData['totalJobs'].toString())),
            ],
          );
        }).toList(),
      ),
    );
  }
}
