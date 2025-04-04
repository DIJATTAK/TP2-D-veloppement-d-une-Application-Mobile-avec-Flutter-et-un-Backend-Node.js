import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:show_app/config/api_config.dart';
import 'package:show_app/models/show.dart';

class UpdateShowPage extends StatefulWidget {
  final Show show;

  UpdateShowPage({required this.show});

  @override
  _UpdateShowPageState createState() => _UpdateShowPageState();
}

class _UpdateShowPageState extends State<UpdateShowPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _imageController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.show.title);
    _descriptionController = TextEditingController(text: widget.show.description);
    _categoryController = TextEditingController(text: widget.show.category);
    _imageController = TextEditingController(text: widget.show.imageUrl);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _updateShow() async {
    final url = '${ApiConfig.baseUrl}/shows/${widget.show.id}';
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': _categoryController.text,
        'imageUrl': _imageController.text,
      }),
    );

    if (response.statusCode == 200) {
      // Mise à jour réussie
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Show updated successfully!')));
    } else {
      // Erreur lors de la mise à jour
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update show.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Show'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: _imageController,
              decoration: InputDecoration(labelText: 'Image URL'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateShow,
              child: Text('Update Show'),
            ),
          ],
        ),
      ),
    );
  }
}

