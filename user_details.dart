
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetailsPage extends StatefulWidget {
  final String uid;
  const UserDetailsPage({super.key, required this.uid});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final _marksController = TextEditingController();
  final _incomeController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

  void _submitDetails() async {
    await _firestore.collection("students").doc(widget.uid).set({
      "marks": int.parse(_marksController.text),
      "annual_income": int.parse(_incomeController.text),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("All details saved successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("User Details", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            TextField(controller: _marksController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "12th Marks %")),
            TextField(controller: _incomeController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Annual Income")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitDetails,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Save Details"),
            ),
          ],
        ),
      ),
    );
  }
}
