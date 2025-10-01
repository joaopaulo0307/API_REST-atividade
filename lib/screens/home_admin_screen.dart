import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../utils/secure_storage.dart';
import 'login_screen.dart';
import 'course_screen.dart';

class HomeAdminScreen extends StatefulWidget {
  final User user;

  const HomeAdminScreen({super.key, required this.user});

  @override
  State<HomeAdminScreen> createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> {
  List<dynamic> _users = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await SecureStorage.getToken();
      if (token != null) {
        final users = await ApiService.getUsers(token);
        setState(() {
          _users = users;
        });
      }
    } catch (e) {
      _showError('Erro ao carregar usuários: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _navigateToCourses() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CourseScreen(user: widget.user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Administrativo'),
        actions: [
          IconButton(
            onPressed: _navigateToCourses,
            icon: const Icon(Icons.school),
            tooltip: 'Cursos',
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem-vindo, ${widget.user.name}!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  'E-mail: ${widget.user.email}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Função: ${widget.user.role}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lista de Usuários',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: _loadUsers,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? const Center(child: Text('Nenhum usuário encontrado'))
                    : ListView.builder(
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(user['name'][0]),
                              ),
                              title: Text(user['name']),
                              subtitle: Text(user['email']),
                              trailing: Chip(
                                label: Text(
                                  user['role'],
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: user['role'] == 'ADMIN'
                                    ? Colors.red
                                    : Colors.blue,
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}