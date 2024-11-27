import 'package:expensetracker/details_entry_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON encoding and decoding

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  Map<String, List<Map<String, String>>> groupedDetails = {};
  double totalAmount = 0.0;
  String? selectedDate;
  Map<String, String>? selectedDetail;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? detailsList = prefs.getStringList('details');
    if (detailsList != null) {
      List<Map<String, String>> details = detailsList.map((item) => Map<String, String>.from(jsonDecode(item))).toList();
      setState(() {
        groupedDetails = _groupByDate(details);
        _calculateTotalAmount();
      });
    }
  }

  Map<String, List<Map<String, String>>> _groupByDate(List<Map<String, String>> details) {
    Map<String, List<Map<String, String>>> grouped = {};
    for (var detail in details) {
      String date = detail['date'] ?? DateFormat('dd-MM-yyyy').format(DateTime.now());
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]?.add(detail);
    }
    return grouped;
  }

  void _calculateTotalAmount() {
    double total = 0.0;
    groupedDetails.forEach((date, details) {
      for (var detail in details) {
        total += double.tryParse(detail['amount'] ?? '0') ?? 0;
      }
    });
    setState(() {
      totalAmount = total;
    });
  }

  Future<void> _deleteDetail() async {
    if (selectedDate != null && selectedDetail != null) {
      setState(() {
        groupedDetails[selectedDate!]?.remove(selectedDetail);
        if (groupedDetails[selectedDate!]?.isEmpty ?? false) {
          groupedDetails.remove(selectedDate);
        }
        _calculateTotalAmount();
        selectedDate = null;
        selectedDetail = null;
      });

      // Persist the changes to SharedPreferences
      List<Map<String, String>> allDetails = [];
      groupedDetails.forEach((date, details) {
        allDetails.addAll(details);
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> detailsList = allDetails.map((detail) => jsonEncode(detail)).toList();
      prefs.setStringList('details', detailsList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your details"),
        automaticallyImplyLeading: false,
        actions: selectedDetail != null
            ? [
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: _deleteDetail,
                ),
              ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: groupedDetails.keys.length,
                itemBuilder: (context, index) {
                  String date = groupedDetails.keys.elementAt(index);
                  List<Map<String, String>> details = groupedDetails[date]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(date, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Column(
                        children: details.map((detail) {
                          bool isSelected = selectedDetail == detail && selectedDate == date;
                          return GestureDetector(
                            onLongPress: () {
                              setState(() {
                                selectedDate = date;
                                selectedDetail = detail;
                              });
                            },
                            child: Container(
                              color: isSelected ? Colors.orange.withOpacity(0.3) : Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(detail['item'] ?? ""),
                                  Text(detail['amount'] ?? ""),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      Divider(),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("Total Amount: ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(totalAmount.toStringAsFixed(2), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 30),
            Center(
              child: Container(
                height: 50,
                width: 160,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DetailsEntryScreen()),
                    ).then((_) => _loadDetails());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text("Add", style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}