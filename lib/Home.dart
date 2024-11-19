import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> countries = [];
  List<String> cities = [];
  String? selectedCountry;
  String? selectedCity;

  @override
  void initState() {
    super.initState();
    fetchCountries();
  }

  Future<void> fetchCountries() async {
    final url = Uri.parse('https://restcountries.com/v3.1/all');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          countries = data;
        });
      } else {
        throw Exception('Failed to load countries');
      }
    } catch (error) {
      print('Error fetching countries: $error');
    }
  }

  Future<void> fetchCities(String country) async {
    final url = Uri.parse('https://countriesnow.space/api/v0.1/countries/cities');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'country': country}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          cities = List<String>.from(data['data']);
        });
      } else {
        throw Exception('Failed to load cities');
      }
    } catch (error) {
      print('Error fetching cities: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Countries and Cities'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Country Dropdown
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.public, color: Colors.blue), // Country icon
                  SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: Text('Select a Country'),
                        value: selectedCountry,
                        items: countries.map((country) {
                          return DropdownMenuItem<String>(
                            value: country['name']['common'],
                            child: Text(country['name']['common']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedCountry = value;
                              selectedCity = null; // Reset city selection
                              cities = []; // Clear cities list
                            });
                            fetchCities(value);
                          }
                        },
                        dropdownColor: Colors.blue[100],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // City Dropdown
              if (selectedCountry != null && cities.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_city, color: Colors.green), // City icon
                    SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: Text('Select a City'),
                          value: selectedCity,
                          items: cities.map((city) {
                            return DropdownMenuItem<String>(
                              value: city,
                              child: Text(city),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedCity = value;
                              });
                            }
                          },
                          dropdownColor: Colors.green[100],
                        ),
                      ),
                    ),
                  ],
                ),
              // Display Selection
              if (selectedCountry != null && selectedCity != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    'You have selected: $selectedCountry with the city $selectedCity',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
