import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:show_app/config/api_config.dart';
import 'package:show_app/screens/add_show_page.dart';
import 'package:show_app/screens/profile_page.dart';
import 'package:show_app/models/show.dart';
import 'package:show_app/screens/update_show_page.dart';
import 'package:show_app/services/show_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ShowService _showService = ShowService();
  int _selectedIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _showService.fetchShows();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Show"),
        content: const Text("Are you sure you want to delete this show?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showService.deleteShow(id);
            },
            child: const Text("Yes, Delete"),
          ),
        ],
      ),
    );
  }

  Widget _getBody(List<dynamic> shows) {
    switch (_selectedIndex) {
      case 0:
        return ShowList(shows: shows.where((show) => show['category'] == 'movie').toList(), onDelete: confirmDelete);
      case 1:
        return ShowList(shows: shows.where((show) => show['category'] == 'anime').toList(), onDelete: confirmDelete);
      case 2:
        return ShowList(shows: shows.where((show) => show['category'] == 'serie').toList(), onDelete: confirmDelete);
      default:
        return const Center(child: Text("Unknown Page"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Show App"), backgroundColor: Colors.blueAccent),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Text("Menu", style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage())),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text("Add Show"),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddShowPage())).then((_) {
                _showService.fetchShows(); // Refresh list after adding a show
              }),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<dynamic>>(
        stream: _showService.showsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Shows Available"));
          }
          return _getBody(snapshot.data!);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: "Movies"),
          BottomNavigationBarItem(icon: Icon(Icons.animation), label: "Anime"),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: "Series"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ShowList extends StatelessWidget {
  final List<dynamic> shows;
  final Function(int) onDelete;

  const ShowList({super.key, required this.shows, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (shows.isEmpty) {
      return const Center(child: Text("No Shows Available"));
    }

    return ListView.builder(
      itemCount: shows.length,
      itemBuilder: (context, index) {
        final show = shows[index];
        return Dismissible(
          key: Key(show['id'].toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerRight,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) => onDelete(show['id']),
          confirmDismiss: (direction) => onDelete(show['id']),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: Image.network(
                ApiConfig.baseUrl + show['image'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
              ),
              title: Text(show['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(show['description']),
              trailing: PopupMenuButton<String>(
                onSelected: (String value) {
                  if (value == 'update') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateShowPage(
                          show: Show(
                            id: show['id'],
                            title: show['title'],
                            description: show['description'],
                            category: show['category'],
                            imageUrl: show['image'],
                          ),
                        ),
                      ),
                    ).then((_) {
                      final homePageState = context.findAncestorStateOfType<_HomePageState>();
                      homePageState?._showService.fetchShows(); // Refresh list after updating a show
                    });
                  } else if (value == 'delete') {
                    onDelete(show['id']);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return {'Update', 'Delete'}.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice.toLowerCase(),
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        );
      },
    );
  }
}