
import 'package:expensetracker/details_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For JSON encoding and decoding

class DetailsEntryScreen extends StatefulWidget {
  const DetailsEntryScreen({super.key});

  @override
  State<DetailsEntryScreen> createState() => _DetailsEntryScreenState();
}

class _DetailsEntryScreenState extends State<DetailsEntryScreen> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enter your details"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: SingleChildScrollView(
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Item", style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                TextFormField(
                  controller: _titleController,
                   validator: (value) {
                        if (value == null || value.isEmpty) {
                            return 'Please enter item';
                        }
                            return null;
                        },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.black12),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Text("Amount", style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                TextFormField(
                  controller: _amountController,
                   validator: (value) {
                        if (value == null || value.isEmpty) {
                            return 'Please enter amount';
                        }
                            return null;
                        },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.black12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 30),
                Text('Date', style: TextStyle(fontSize: 16),),
                SizedBox(height: 10,),
                InkWell(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context, 
                      firstDate: DateTime(2000), 
                      lastDate: DateTime(2101)
                      );
                      if(pickedDate != null && pickedDate != selectedDate){
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(6)
                     ),
                     child: Text(
                      DateFormat('dd-MM-yyyy').format(selectedDate),
                      style: TextStyle(fontSize: 16),
                     ),
                  ),
                ),
                SizedBox(height: 30,),
                Center(
                  child: Container(
                    height: 50,
                    width: 160,
                    child: ElevatedButton(
                      onPressed: 
                      (){
                        if(_formkey.currentState!.validate()){
                        _saveDetails();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text("Submit", style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? detailsList = prefs.getStringList('details');
    detailsList ??= [];
    String formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    
    Map<String, String> newDetail = {
      'date': formattedDate,
      'item': _titleController.text,
      'amount': _amountController.text,
    };

    detailsList.add(jsonEncode(newDetail));
    await prefs.setStringList('details', detailsList);


    Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsScreen()));
  }
}
