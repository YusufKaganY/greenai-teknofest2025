import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  Future<void> loginUser(String username, String password) async {
    final url = Uri.parse("http://192.168.206.1:5000/login");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      int kullaniciId = responseData['kullanici_id'];
      int puan = responseData['puan'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('kullaniciId', kullaniciId);
      await prefs.setInt('puan', puan);
      await prefs.setString('username', username);

      Navigator.pushReplacementNamed(context, '/main');
    } else {
      final responseData = jsonDecode(response.body);
      final errorMessage = responseData['error'] ?? "Giriş başarısız.";
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Hata"),
          content: Text(errorMessage),
          actions: [
            TextButton(
              child: const Text("Tamam"),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Icon(Icons.eco, size: 80, color: Colors.green),
                const SizedBox(height: 20),
                const Text(
                  "Giriş Yap",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "E-mail",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.email, color: Colors.green),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Şifre",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.lock, color: Colors.green),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.green,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    final username = emailController.text.trim();
                    final password = passwordController.text.trim();
                    if (username.isNotEmpty && password.isNotEmpty) {
                      loginUser(username, password);
                    } else {
                      showDialog(
                        context: context,
                        builder: (_) => const AlertDialog(
                          title: Text("Hata"),
                          content: Text("Lütfen tüm alanları doldurun."),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child:
                      const Text("Giriş Yap", style: TextStyle(fontSize: 16)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text("Hesabınız yok mu? Kayıt olun",
                      style: TextStyle(color: Colors.green)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
