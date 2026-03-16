import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  Map<String, dynamic>? _user;
  String? _error;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get user => _user;
  String? get error => _error;
  List<String> get roles => (_user?['roles'] as List<dynamic>?)?.cast<String>() ?? [];
  bool get isLandlord => roles.contains('LANDLORD');
  bool get isTenant => roles.contains('TENANT');

  Future<void> checkAuth() async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await ApiService.getToken();
      if (token != null) {
        _user = await ApiService.get('/users/me');
        _isLoggedIn = true;
      }
    } catch (_) {
      await ApiService.clearTokens();
      _isLoggedIn = false;
      _user = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.post('/auth/login', body: {
        'email': email,
        'password': password,
      });
      await ApiService.saveTokens(res['accessToken'], res['refreshToken']);
      _user = {
        'id': res['userId'],
        'email': res['email'],
        'firstName': res['firstName'],
        'lastName': res['lastName'],
        'roles': res['roles'],
      };
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String firstName,
      String lastName, String role, {String? inviteCode}) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      final body = {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
      };
      if (inviteCode != null) body['inviteCode'] = inviteCode;
      final res = await ApiService.post('/auth/register', body: body);
      await ApiService.saveTokens(res['accessToken'], res['refreshToken']);
      _user = {
        'id': res['userId'],
        'email': res['email'],
        'firstName': res['firstName'],
        'lastName': res['lastName'],
        'roles': res['roles'],
      };
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await ApiService.clearTokens();
    _isLoggedIn = false;
    _user = null;
    notifyListeners();
  }
}
