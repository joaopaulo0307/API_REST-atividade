import '../models/user_model.dart';
import '../utils/secure_storage.dart';
import 'api_service.dart';

class AuthService {
  static Future<User?> login(String email, String password) async {
    try {
      final response = await ApiService.login(email, password);
      print('Login Response: $response');
      
      // Extrai o token da resposta
      String? token;
      Map<String, dynamic>? userData;

      // Tenta diferentes formatos de resposta
      if (response.containsKey('token')) {
        token = response['token'];
        userData = response['user'];
      } else if (response.containsKey('access_token')) {
        token = response['access_token'];
        userData = response['user'];
      } else {
        // Se a resposta for apenas o token string
        token = response['accessToken'] ?? response['authToken'] ?? response['jwt'];
        userData = response['user'] ?? response;
      }

      print('Token extracted: $token');
      print('User data extracted: $userData');

      if (token != null && token.isNotEmpty) {
        await SecureStorage.setToken(token);
        
        // Se não temos userData completo, busca o perfil
        if (userData == null || userData['email'] == null) {
          print('Fetching user profile...');
          userData = await ApiService.getUserProfile(token);
        }
        
        return User.fromJson(userData);
      } else {
        throw Exception('Token não recebido da API');
      }
    } catch (e) {
      print('Auth Service Error: $e');
      throw Exception('Erro no login: $e');
    }
  }

  static Future<User?> getCurrentUser() async {
    try {
      final token = await SecureStorage.getToken();
      if (token == null) {
        print('No token found');
        return null;
      }

      print('Token found, fetching user profile...');
      final userData = await ApiService.getUserProfile(token);
      return User.fromJson(userData);
    } catch (e) {
      print('Error getting current user: $e');
      await SecureStorage.deleteToken();
      return null;
    }
  }

  static Future<void> logout() async {
    await SecureStorage.deleteToken();
  }
}