import 'dart:async';
import 'dart:convert';

import 'package:cognisto/models/contact_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserListProvider with ChangeNotifier {
  List<User> users = [];
  bool isLoading = false;
  bool hasMore = true;
  int skip = 0;
  final int limit = 10;
  Timer? _debounce;

  Future<void> fetchInitialUsers() async {
    skip = 0;
    users.clear();
    await fetchUsers();
  }

  Future<void> fetchUsers() async {
    if (isLoading || !hasMore) return;

    isLoading = true;
    notifyListeners();

    final res = await http.get(Uri.parse('https://dummyjson.com/users?limit=$limit&skip=$skip'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final List fetched = data['users'];
      hasMore = fetched.length == limit;
      skip += limit;
      users.addAll(fetched.map((e) => User.fromJson(e)).toList());
    }
    isLoading = false;
    notifyListeners();
  }

  void searchUsers(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        await fetchInitialUsers();
      } else {
        isLoading = true;
        notifyListeners();

        final res = await http.get(Uri.parse('https://dummyjson.com/users/search?q=$query'));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          users = (data['users'] as List).map((e) => User.fromJson(e)).toList();
        }

        isLoading = false;
        notifyListeners();
      }
    });
  }
}
