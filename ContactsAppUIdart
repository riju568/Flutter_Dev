import 'package:flutter/material.dart';

void main() {
  runApp(const MultiTabContactApp());
}

class MultiTabContactApp extends StatelessWidget {
  const MultiTabContactApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi-Tab Contacts',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ContactHomePage(),
    );
  }
}

class Contact {
  final String name;
  final String phone;
  final String email;
  final String category;

  Contact({
    required this.name,
    required this.phone,
    required this.email,
    required this.category,
  });
}

class ContactHomePage extends StatefulWidget {
  const ContactHomePage({super.key});

  @override
  State<ContactHomePage> createState() => _ContactHomePageState();
}

class _ContactHomePageState extends State<ContactHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Contact> _allContacts = [
    Contact(
      name: 'Alice Smith',
      phone: '+1 234-567-8901',
      email: 'alice@example.com',
      category: 'Family',
    ),
    Contact(
      name: 'Bob Johnson',
      phone: '+1 234-567-8902',
      email: 'bob@example.com',
      category: 'Work',
    ),
    Contact(
      name: 'Charlie Brown',
      phone: '+1 234-567-8903',
      email: 'charlie@example.com',
      category: 'Friends',
    ),
    Contact(
      name: 'Diana Prince',
      phone: '+1 234-567-8904',
      email: 'diana@example.com',
      category: 'Work',
    ),
    Contact(
      name: 'Eve Adams',
      phone: '+1 234-567-8905',
      email: 'eve@example.com',
      category: 'Family',
    ),
    Contact(
      name: 'Frank Castle',
      phone: '+1 234-567-8906',
      email: 'frank@example.com',
      category: 'Friends',
    ),
    Contact(
      name: 'Grace Hopper',
      phone: '+1 234-567-8907',
      email: 'grace@example.com',
      category: 'Work',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Contact> _getContactsByCategory(String category) {
    if (category == 'All') return _allContacts;
    return _allContacts.where((c) => c.category == category).toList();
  }

  Widget _buildContactList(String category) {
    final contacts = _getContactsByCategory(category);

    if (contacts.isEmpty) {
      return Center(
        child: Text(
          'No contacts found in $category',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 80,
      ), // bottom padding for FAB
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                contact.name[0].toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            title: Text(
              contact.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contact.phone),
                  Text(contact.email, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.message, color: Colors.blueGrey),
                  onPressed: () {
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.call, color: Colors.green),
                  onPressed: () {
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contacts',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: 'All', icon: Icon(Icons.contacts)),
            Tab(text: 'Family', icon: Icon(Icons.family_restroom)),
            Tab(text: 'Friends', icon: Icon(Icons.group)),
            Tab(text: 'Work', icon: Icon(Icons.work)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildContactList('All'),
          _buildContactList('Family'),
          _buildContactList('Friends'),
          _buildContactList('Work'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Add Contact clicked!')));
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add Contact'),
      ),
    );
  }
}
