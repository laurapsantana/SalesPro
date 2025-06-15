import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'http://10.0.2.2:3000/login';


  Future<bool> login(String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'senha': senha}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Login OK: $data');

        // Se depois você implementar JWT, aqui você pode salvar o token com SharedPreferences

        return true;
      } else {
        print('Erro ao fazer login: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exceção no login: $e');
      return false;
    }
  }
}
