import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      darkTheme: ThemeData.dark(),
      home: PasswordChecker(),
    );
  }
}

class PasswordChecker extends StatefulWidget {
  @override
  _PasswordCheckerState createState() => _PasswordCheckerState();
}

class _PasswordCheckerState extends State<PasswordChecker> {
  bool isHidden = true;
  double strengthValue = 0;
  String suggestion = "";
  String result = "";
  Color resultColor = Colors.black;

  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose(); // ✅ CORRECT PLACE
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Password Strength Checker"),
        centerTitle: true,
      ),
      body: Center(
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Password input
                TextField(
                  controller: _passwordController,
                  obscureText: isHidden,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isHidden ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          isHidden = !isHidden;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    checkPassword(value);
                  },
                ),

                SizedBox(height: 8),
                Text(
                  "Password must be at least 8 characters and include numbers & symbols",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 12),

                // Strength bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: strengthValue,
                    minHeight: 12,
                    backgroundColor: Colors.grey[300],
                    color: resultColor,
                  ),
                ),

                SizedBox(height: 15),

                // Result text
                Text(
                  result,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: resultColor,
                  ),
                ),

                SizedBox(height: 10),

                // Suggestion text
                Text(
                  suggestion,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                ),

                SizedBox(height: 10),

                // Clear button
                TextButton(
                  onPressed: () {
                    setState(() {
                      _passwordController.clear();
                      strengthValue = 0;
                      result = "";
                      suggestion = "";
                    });
                  },
                  child: Text("Clear"),
                ),

                SizedBox(height: 6),

                // Footer
                Text(
                  "Educational Cyber Security Tool",
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void checkPassword(String password) {
    setState(() {
      bool hasNumber = password.contains(RegExp(r'[0-9]'));
      bool hasSymbol = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

      if (password.isEmpty) {
        result = "";
        suggestion = "";
        strengthValue = 0;
        return;
      }

      if (password.length < 8) {
        result = "Weak Password ❌";
        resultColor = Colors.red;
        strengthValue = 0.3;
        suggestion = "Use at least 8 characters";
      } else if (hasNumber && hasSymbol) {
        result = "Strong Password ✅";
        resultColor = Colors.green;
        strengthValue = 1.0;
        suggestion = "Great password!";
      } else {
        result = "Medium Password ⚠️";
        resultColor = Colors.orange;
        strengthValue = 0.6;
        suggestion = "Add numbers & special symbols";
      }
    });
  }
}