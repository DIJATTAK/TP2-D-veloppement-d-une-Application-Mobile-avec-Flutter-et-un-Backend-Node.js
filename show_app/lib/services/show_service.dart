import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ShowService {
  final StreamController<List<dynamic>> _showsController = StreamController<List<dynamic>>.broadcast();
  Stream<List<dynamic>> get showsStream => _showsController.stream;

  Future<void> fetchShows() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/shows'));

    if (response.statusCode == 200) {
      List<dynamic> allShows = jsonDecode(response.body);
      _showsController.add(allShows);
    } else {
      throw Exception('Failed to load shows');
    }
  }

  Future<void> addShow(Map<String, dynamic> show) async {
    var request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}/shows'));
    request.fields['title'] = show['title'];
    request.fields['description'] = show['description'];
    request.fields['category'] = show['category'];
    request.files.add(await http.MultipartFile.fromPath('image', show['imagePath']));

    var response = await request.send();

    if (response.statusCode == 201) {
      fetchShows(); // Refresh list after addition
    } else {
      throw Exception('Failed to add show');
    }
  }

  Future<void> updateShow(int id, Map<String, dynamic> show) async {
    var request = http.MultipartRequest('PUT', Uri.parse('${ApiConfig.baseUrl}/shows/$id'));
    request.fields['title'] = show['title'];
    request.fields['description'] = show['description'];
    request.fields['category'] = show['category'];
    if (show['imagePath'] != null) {
      request.files.add(await http.MultipartFile.fromPath('image', show['imagePath']));
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      fetchShows(); // Refresh list after update
    } else {
      throw Exception('Failed to update show');
    }
  }

  Future<void> deleteShow(int id) async {
    final response = await http.delete(Uri.parse('${ApiConfig.baseUrl}/shows/$id'));

    if (response.statusCode == 200) {
      fetchShows(); // Refresh list after deletion
    } else {
      throw Exception('Failed to delete show');
    }
  }
}