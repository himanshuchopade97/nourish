import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class VitalsPage extends StatefulWidget {
  @override
  _VitalsPageState createState() => _VitalsPageState();
}

class _VitalsPageState extends State<VitalsPage> {
  double bloodSugar = 90.0;
  double weight = 85.0;
  String? token;



  @override
  void initState() {
    super.initState();
    _sendVitals();
  }

  Future<void> _sendVitals() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // Retrieve token
    print(token);
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in first.')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
            'https://nourish-backend-enzv.onrender.com/api/vitals/add'), // Replace with your backend URL
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'sugarReading': bloodSugar,
          'weightReading': weight,
        }),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
        //Handle response data, like updating local user details, if necessary
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to send vitals. Status: ${response.statusCode}')),
        );
      }
    } catch (error) {
      print('Error sending vitals: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  void updateVital(String vital, bool increase) {
    setState(() {
      if (vital == "Blood Sugar") {
        bloodSugar += increase ? 2 : -2;
      } else if (vital == "Weight") {
        weight += increase ? 1 : -1;
      }
    });
  }

  Widget buildVitalCard(String title, String unit, double value) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade700, width: 1),
          color: Colors.grey.shade900,
        ),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  title == "Blood Sugar"
                      ? Icons.bloodtype
                      : Icons.monitor_weight,
                  color: Colors.redAccent,
                ),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    "$title ($unit)",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.remove_circle, color: Colors.green),
                  onPressed: () => updateVital(title, false),
                ),
                Container(
                  width: 50,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.black,
                  ),
                  child: Text(
                    value.toStringAsFixed(1),
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () => updateVital(title, true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoContainer(String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade800,
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Track Vitals",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Row(
              children: [
                buildVitalCard("Blood Sugar", "mg/dL", bloodSugar),
                SizedBox(width: 10),
                buildVitalCard("Weight", "kg", weight),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "Recommended to track sugar after a specific meal",
              style: TextStyle(color: Colors.white60, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            buildInfoContainer("Before meal - 70-100 mg/dL"),
            SizedBox(height: 20),
            buildInfoContainer("After meal - Less than 140 mg/dL"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendVitals,
              child: Text(
                "Send Vitals",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.grey.shade900,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Text(
                        "Doctor Details",
                        style: TextStyle(color: Colors.white),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Icon(Icons.person, color: Colors.green),
                            title: Text("Dr. Shivam Raje",
                                style: TextStyle(color: Colors.white)),
                            subtitle: Text("MBBS, MD - Internal Medicine",
                                style: TextStyle(color: Colors.white60)),
                          ),
                          Divider(color: Colors.grey),
                          ListTile(
                            leading: Icon(Icons.phone, color: Colors.green),
                            title: Text("+91 98765 43210",
                                style: TextStyle(color: Colors.white)),
                            onTap: () async {
                              // Implement call functionality
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.email, color: Colors.green),
                            title: Text("drshivamraje@gmail.com",
                                style: TextStyle(color: Colors.white)),
                            onTap: () {
                              // Implement email functionality
                            },
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Close",
                              style: TextStyle(color: Colors.green)),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text(
                "Need Help? Contact a doctor",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
