import 'user_details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizPage extends StatefulWidget {
  final String uid;
  const QuizPage({super.key, required this.uid});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final _firestore = FirebaseFirestore.instance;
  Map<String, dynamic> answers = {};

  void _submitQuiz() async {
    await _firestore.collection("students").doc(widget.uid).set({
      "quiz_answers": answers,
    }, SetOptions(merge: true));

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => UserDetailsPage(uid: widget.uid)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Personality Section", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          RadioListTile(value: "Problem Solver", groupValue: answers["personality"], onChanged: (val) { setState(() { answers["personality"] = val; }); }, title: const Text("Problem Solver")),
          RadioListTile(value: "Creative", groupValue: answers["personality"], onChanged: (val) { setState(() { answers["personality"] = val; }); }, title: const Text("Creative")),

          const Divider(),
          const Text("Aptitude Section", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          RadioListTile(value: "Math Lover", groupValue: answers["aptitude"], onChanged: (val) { setState(() { answers["aptitude"] = val; }); }, title: const Text("Math Lover")),
          RadioListTile(value: "Biology Lover", groupValue: answers["aptitude"], onChanged: (val) { setState(() { answers["aptitude"] = val; }); }, title: const Text("Biology Lover")),

          const Divider(),
          const Text("Interests Section", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          RadioListTile(value: "Technology", groupValue: answers["interest"], onChanged: (val) { setState(() { answers["interest"] = val; }); }, title: const Text("Technology")),
          RadioListTile(value: "Business", groupValue: answers["interest"], onChanged: (val) { setState(() { answers["interest"] = val; }); }, title: const Text("Business")),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitQuiz,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Submit Quiz"),
          ),
        ],
      ),
    );
  }
}
