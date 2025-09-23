import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Career Advisor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const LoginPage(),
    );
  }
}

// ===================== LOGIN PAGE =====================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Fill all fields")));
      return;
    }

    // Here you can validate with Firebase or Firestore if needed
    // For now, we directly go to quiz page
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const QuizPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: login, child: const Text("Login")),
          ],
        ),
      ),
    );
  }
}

// ===================== QUIZ PAGE =====================
class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final Map<String, dynamic> answers = {};
  String? grade;
  double? lat, lng;
  final TextEditingController cityController = TextEditingController();
  final TextEditingController marks10 = TextEditingController();
  final TextEditingController marks12 = TextEditingController();

  Future<void> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    Position pos = await Geolocator.getCurrentPosition();
    setState(() {
      lat = pos.latitude;
      lng = pos.longitude;
      answers["location"] = {"lat": lat, "lng": lng};
    });
  }

  Future<void> handleSubmit() async {
    answers["grade"] = grade;
    answers["marks_10"] = marks10.text;
    if (grade == "12") {
      answers["marks_12"] = marks12.text;
    }
    answers["city"] = cityController.text;

    String studentId = "Smitha1662006"; // you can generate dynamically

    // 1️⃣ Save quiz answers into Firestore
    await FirebaseFirestore.instance
        .collection("student")
        .doc(newMethod(studentId))
        .set(answers, SetOptions(merge: true));

    // 2️⃣ Call Flask API to analyze results
    final url = Uri.parse("http://10.31.10.85:5500/analyze");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"student_id": studentId}),
    );

    String message;
    if (response.statusCode == 200) {
      final aiResult = jsonDecode(response.body);
      message = const JsonEncoder.withIndent("  ").convert(aiResult);
    } else {
      message = "Error: ${response.body}";
    }

    // 3️⃣ Show AI result in dialog
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("AI Career Suggestion"),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  String newMethod(String studentId) => studentId;

  Widget buildQuestion(String id, String question, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          children: options.map((opt) {
            return ChoiceChip(
              label: Text(opt),
              selected: answers[id] == opt,
              onSelected: (_) {
                setState(() => answers[id] = opt);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Career Guidance Quiz")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildQuestion(
              "Q1",
              "If a train runs at 60 km/h, how long for 180 km?",
              ["2 hrs", "3 hrs", "4 hrs", "5 hrs"],
            ),
            buildQuestion("Q2", "Next number: 2, 6, 12, 20, ?", [
              "26",
              "28",
              "30",
              "32",
            ]),
            buildQuestion("Q3", "Clock shows 3:15. Angle between hands?", [
              "0°",
              "30°",
              "45°",
              "90°",
            ]),

            const Divider(),
            buildQuestion("Q4", "Which subject do you enjoy most?", [
              "Math/Physics",
              "Biology",
              "Commerce",
              "Arts",
            ]),
            buildQuestion("Q5", "Which career excites you?", [
              "Engineer",
              "Doctor",
              "Banker",
              "Teacher",
            ]),

            const Divider(),
            buildQuestion("Q6", "In group project, your role:", [
              "Problem solver",
              "Helper",
              "Leader",
              "Creative",
            ]),
            buildQuestion("Q7", "What motivates you most?", [
              "Solving problems",
              "Helping people",
              "Earning money",
              "Creativity",
            ]),

            const Divider(),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Are you in 10th or 12th?",
              ),
              items: ["10", "12"]
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (val) => setState(() => grade = val),
            ),
            TextField(
              controller: marks10,
              decoration: const InputDecoration(labelText: "Enter 10th %"),
              keyboardType: TextInputType.number,
            ),
            if (grade == "12")
              TextField(
                controller: marks12,
                decoration: const InputDecoration(labelText: "Enter 12th %"),
                keyboardType: TextInputType.number,
              ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Family Annual Income",
              ),
              items: [
                "<1 LPA",
                "1-3 LPA",
                "3-6 LPA",
                ">6 LPA",
              ].map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
              onChanged: (val) => answers["income"] = val,
            ),

            const Divider(),
            Row(
              children: [
                ElevatedButton(
                  onPressed: getLocation,
                  child: const Text("Use My Location"),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: cityController,
                    decoration: const InputDecoration(
                      labelText: "Or enter city",
                    ),
                  ),
                ),
              ],
            ),
            if (lat != null)
              Text(
                "Lat: ${lat!.toStringAsFixed(3)}, Lng: ${lng!.toStringAsFixed(3)}",
              ),

            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: handleSubmit,
                child: const Text("Submit Quiz"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
