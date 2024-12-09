import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Search the Best Freight Rates'),
          backgroundColor: Colors.blueAccent,
        ),
        body: FreightForm(),
      ),
    );
  }
}

class FreightForm extends StatefulWidget {
  @override
  _FreightFormState createState() => _FreightFormState();
}

class _FreightFormState extends State<FreightForm> {
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _noOfBoxesController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  bool _includeNearbyOriginPorts = false;
  bool _includeNearbyDestinationPorts = false;

  String? _selectedContainerSize = "40' Standard";
  double _length = 39.46;
  double _width = 7.70;
  double _height = 7.84;

  List<String> _originSuggestions = [];
  List<String> _destinationSuggestions = [];

  Future<void> _fetchSuggestions(String query, Function(List<String>) updateSuggestions) async {
    final url = Uri.parse('http://universities.hipolabs.com/search?name=$query');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final suggestions = data.map<String>((e) => e['name'].toString()).toList();
        updateSuggestions(suggestions);
      } else {
        print("Failed to load suggestions: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching suggestions: $e");
    }
  }

  void _updateDimensions() {
    if (_selectedContainerSize == "20' Standard") {
      _length = 19.35;
      _width = 7.71;
      _height = 7.87;
    } else if (_selectedContainerSize == "40' Standard") {
      _length = 39.46;
      _width = 7.70;
      _height = 7.84;
    } else if (_selectedContainerSize == "40' High Cube") {
      _length = 39.46;
      _width = 7.70;
      _height = 8.85;
    }

    int noOfBoxes = int.tryParse(_noOfBoxesController.text) ?? 1;
    _length = (_length / noOfBoxes).clamp(1.0, _length);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Origin Field with Checkbox
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              _fetchSuggestions(
                textEditingValue.text,
                    (suggestions) => setState(() => _originSuggestions = suggestions),
              );
              return _originSuggestions;
            },
            onSelected: (value) {
              _originController.text = value;
            },
            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: 'Origin',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              );
            },
          ),
          Row(
            children: [
              Checkbox(
                value: _includeNearbyOriginPorts,
                onChanged: (value) {
                  setState(() {
                    _includeNearbyOriginPorts = value ?? false;
                  });
                },
              ),
              Text('Include nearby origin ports'),
            ],
          ),
          SizedBox(height: 16),

          // Destination Field with Checkbox
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              _fetchSuggestions(
                textEditingValue.text,
                    (suggestions) => setState(() => _destinationSuggestions = suggestions),
              );
              return _destinationSuggestions;
            },
            onSelected: (value) {
              _destinationController.text = value;
            },
            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: 'Destination',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              );
            },
          ),
          Row(
            children: [
              Checkbox(
                value: _includeNearbyDestinationPorts,
                onChanged: (value) {
                  setState(() {
                    _includeNearbyDestinationPorts = value ?? false;
                  });
                },
              ),
              Text('Include nearby destination ports'),
            ],
          ),
          SizedBox(height: 16),

          // Container Size Dropdown and No of Boxes
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedContainerSize,
                  decoration: InputDecoration(
                    labelText: 'Container Size',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: "20' Standard",
                      child: Text("20' Standard"),
                    ),
                    DropdownMenuItem(
                      value: "40' Standard",
                      child: Text("40' Standard"),
                    ),
                    DropdownMenuItem(
                      value: "40' High Cube",
                      child: Text("40' High Cube"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedContainerSize = value;
                      _updateDimensions();
                    });
                  },
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _noOfBoxesController,
                  decoration: InputDecoration(
                    labelText: 'No of Boxes',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _updateDimensions(),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Weight Field
          TextField(
            controller: _weightController,
            decoration: InputDecoration(
              labelText: 'Weight (Kg)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16),

          // Dynamic Container Internal Dimensions
          Text(
            "Container Internal Dimensions:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Length: ${_length.toStringAsFixed(2)} ft"),
                Text("Width: ${_width.toStringAsFixed(2)} ft"),
                Text("Height: ${_height.toStringAsFixed(2)} ft"),
              ],
            ),
          ),
          SizedBox(height: 16),


          SizedBox(height: 16),

          // Search Button
          ElevatedButton(
            onPressed: () {
              print("Origin: ${_originController.text}");
              print("Include Nearby Origin Ports: $_includeNearbyOriginPorts");
              print("Destination: ${_destinationController.text}");
              print("Include Nearby Destination Ports: $_includeNearbyDestinationPorts");
              print("Container Size: $_selectedContainerSize");
              print("No of Boxes: ${_noOfBoxesController.text}");
              print("Weight: ${_weightController.text}");
              print("Length: $_length");
              print("Width: $_width");
              print("Height: $_height");
            },
            child: Text('Search'),
          ),
        ],
      ),
    );
  }
}
