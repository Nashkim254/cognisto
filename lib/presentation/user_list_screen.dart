import 'package:cognisto/providers/user_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomerListScreen extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();

  CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserListProvider()..fetchInitialUsers(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Customers')),
        body: Consumer<UserListProvider>(
          builder: (context, provider, _) {
            _scrollController.addListener(() {
              if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
                provider.fetchUsers();
              }
            });

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: provider.searchUsers,
                    decoration: const InputDecoration(
                      hintText: 'Search by name',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                if (provider.isLoading && provider.users.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else if (provider.users.isEmpty)
                  const Center(child: Text('No users found'))
                else
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: provider.users.length + (provider.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < provider.users.length) {
                          final user = provider.users[index];
                          return ListTile(
                            leading: CircleAvatar(backgroundImage: NetworkImage(user.image)),
                            title: Text('${user.firstName} ${user.lastName}'),
                            subtitle: Text(user.email),
                          );
                        } else {
                          return const Center(child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ));
                        }
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
