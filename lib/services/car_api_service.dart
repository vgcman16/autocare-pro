import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle.dart';

class CarApiService {
  static const String baseUrl = 'https://vpic.nhtsa.dot.gov/api/vehicles';

  // Fetch makes for a specific year
  Future<List<String>> getMakes({required int year}) async {
    final url = '$baseUrl/GetMakesForVehicleType/car?format=json';
    print('Fetching makes from URL: $url'); // Debug log

    final response = await http.get(
      Uri.parse(url),
    );

    print('Response status code: ${response.statusCode}'); // Debug log

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['Results'] as List;
      
      // Get all makes and sort them alphabetically
      final makes = results
          .map((make) => make['MakeName'] as String)
          .where((make) => make.isNotEmpty) // Filter out empty makes
          .toSet() // Remove duplicates
          .toList()
        ..sort(); // Sort alphabetically
      
      print('Found ${makes.length} makes'); // Debug log
      return makes;
    } else {
      throw Exception('Failed to load makes: Status ${response.statusCode}');
    }
  }

  // Fetch models for a specific make and year
  Future<List<String>> getModels({
    required String make,
    required int year,
  }) async {
    final url = '$baseUrl/GetModelsForMakeYear/make/$make/modelyear/$year?format=json';
    print('Fetching models from URL: $url'); // Debug log

    final response = await http.get(
      Uri.parse(url),
    );

    print('Response status code: ${response.statusCode}'); // Debug log

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['Results'] as List;
      final models = results
          .map((model) => model['Model_Name'] as String)
          .where((model) => model.isNotEmpty) // Filter out empty models
          .toSet() // Remove duplicates
          .toList()
        ..sort(); // Sort alphabetically
      
      print('Found ${models.length} models'); // Debug log
      return models;
    } else {
      throw Exception('Failed to load models: Status ${response.statusCode}');
    }
  }

  // Decode VIN to get vehicle information
  Future<Vehicle> decodeVin(String vin) async {
    final url = '$baseUrl/DecodeVin/$vin?format=json';
    print('Fetching VIN info from URL: $url'); // Debug log

    final response = await http.get(
      Uri.parse(url),
    );

    print('Response status code: ${response.statusCode}'); // Debug log

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['Results'] as List;
      
      // Convert the results into a more usable format
      Map<String, String> vehicleInfo = {};
      for (var result in results) {
        if (result['Value'] != null && result['Value'].toString().isNotEmpty) {
          vehicleInfo[result['Variable']] = result['Value'].toString();
        }
      }
      
      // Extract year, make, and model from the response
      int? year;
      String? make;
      String? model;
      
      for (var result in results) {
        final variable = result['Variable'] as String;
        final value = result['Value'];
        
        if (value != null && value.toString().isNotEmpty) {
          switch (variable) {
            case 'Model Year':
              year = int.tryParse(value.toString());
              break;
            case 'Make':
              make = value.toString();
              break;
            case 'Model':
              model = value.toString();
              break;
          }
        }
      }
      
      if (year == null || make == null || model == null) {
        throw Exception('Could not extract vehicle information from VIN');
      }
      
      return Vehicle(
        year: year,
        make: make,
        model: model,
        vin: vin,
        mileage: 0, // This needs to be entered by the user
      );
    } else {
      throw Exception('Failed to decode VIN: Status ${response.statusCode}');
    }
  }
}
