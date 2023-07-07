import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Assessment',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CityPage(),
    );
  }
}

// there are no comments in the code provided which makes it difficult to figure out what is doing what
// recommendation: add comments where necessary
// meaningless variable names
// dangerous use of var
// not following naming conventions/rules
// doesn't check for null values
class CityPage extends StatefulWidget {
  const CityPage({Key? key}) : super(key: key);

  @override
  State<CityPage> createState() => _CityPageState();
}

class _CityPageState extends State<CityPage> {
  bool _hasError =
      false; // prefix with _ for private variable, it's better to initialize _hasError as false rather than null

  // store the error message
  String? _error;

  bool _loading =
      false; // should be declared as bool, declaring it as var can result in type change at runtime, variable name is not meaningful, what does _l mean? seems to mean _loading, also, this should be initialized to false?
  // final _N = "City"; // camelCase is recommended for naming variables, what does _N mean? unnecessary variable that adds no value
  // String?
  // _rawStringFromApi; // for private variables, prefixing with _ is recommended, what does d mean?
  late TextEditingController
      _cityController; // can be declared as final for performance, can be renamed to _cityTextFieldController to emphasize that it is the controller for TextField City
  String? _token;

  String? _cityName;

  CityApiResponse? _cityApiResponse;

  // initialize bearer token from shared preferences
  Future<void> _loadTokenFromSharedPreferences() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();

    final token = sharedPreferences.getString('TOKEN');

    setState(() {
      _token = token;
    });
  }

  Future<void> _loadCityFromApi() async {
    // if token is null, we should prevent the api call as the user is not logged in
    if (_token == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('You are not logged in! Please log in to continue.')));

      return;
    }

    setState(() {
      _loading = true;
    });

    // http package is missing
    // invalid domain
    // error is not caught
    // move this function call outside the build method
    // add loading indicator to prevent successive function calls
    // should also check if the text is empty because it can result in unnecessary api call
    // post requires a Uri value
    // the request should also be `get` because you are fetching data, not creating records
    // it is better to parse the response
    // it is better to use request class
    final url = Uri.https('mybackend.com', '/cities',
        CityApiRequest(cityName: _cityController.text).toJson());

    try {
      final response = await get(url, headers: {
        // shared preferences can be initialized at initState
        // check for null value
        // only make the call if token value is not null
        "Authorization":
            "Bearer $_token" // it's better to declare TOKEN as const for consistency and easier maintainability, Bearer prefix is also missing
      });

      if (response.statusCode == 200) {
        // parse the response from the server
        var decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;

        setState(() {
          _cityApiResponse = CityApiResponse.fromJson(decodedResponse);
          _loading = false;
        });
      }
    } catch (error) {
      setState(() {
        _hasError = true;
        _error = error.toString();
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _loadTokenFromSharedPreferences();

    // hook the cityController text to cityName state
    _cityController = TextEditingController();

    _cityController.addListener(() {
      setState(() {
        _cityName = _cityController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // easier to read
        title: const Text(
          "Weather Page",
        ), // unnecessary use of center, use centerTitle instead, declare as const for performance
      ),
      body: Column(
        children: [
          Row(
            children: [
              // unnecessary container as there are no decorations, size or other properties added
              // what is needed here is SizedBox to constrain the width of the TextField
              Expanded(
                child: TextField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                      hintText: "Enter City name"), // unnecessary variable use
                ),
              ),
              // child is missing
              // disable if user is not logged in, i.e. _token is null
              ElevatedButton(
                // if the city name is empty, disable fetch city button
                onPressed: _cityName != null && _cityName!.isNotEmpty
                    ? _loadCityFromApi
                    : null,
                child: const Text('Fetch City'),
              )
            ],
          ),
          // center the contents because using Center alone will only center the contents in the x-axis
          Expanded(
            child: buildBody(context),
          )
        ],
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    // replace the code below with parsed cityApiResponse
    // String pattern =
    // '"(weather)":"((\\"|[^"])*)"'; // what does rg mean here? isn't it pattern?
    // String? w = RegExp(pattern).firstMatch(d).group(
    // 2); // check for null as String is not nullable, w is another variable with no meaning

    // use early return

    // if the request is loading, show a loading indicator
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // if the api has error, display the error as well as a try again button
    if (_hasError) {
      return Center(
        child: Column(
          children: [
            Text(_error ?? 'UNKNOWN ERROR'),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: _loadCityFromApi, child: const Text('TRY AGAIN')),
          ],
        ),
      );
    }

    if (_cityName == null || _cityName!.isEmpty) {
      return const Center(
        child:
            Text('Please type a name of city to view its weather information.'),
      );
    }

    return _cityApiResponse != null
        ? SingleChildScrollView(
            child: Card(
              child: Column(
                children: [
                  // unnecessary use of container
                  // extract regex above for better readability
                  // check for nullability
                  Text("City: ${_cityApiResponse!.name}"),
                  // no reason for using text span
                  RichText(
                    text: TextSpan(children: [
                      // add const to improve performance
                      const TextSpan(
                        text: "History:\n",
                      ),
                      TextSpan(
                        text: _cityApiResponse!.name,
                      ),
                    ]),
                  ),
                  Container(
                    // add const to improve performance
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    height: 750.0,
                    // check for null values
                    child: Image.network(
                      _cityApiResponse!.imageUrl,
                      fit: BoxFit.fill,
                    ),
                  ),
                  IntrinsicHeight(
                    child: Row(
                      // added to center the content
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // unnecessary use of container
                        Column(
                          children: [
                            // add const
                            const Text("Temperature:"),
                            // check for null values
                            Text(_cityApiResponse!.temp)
                          ],
                        ),
                        const VerticalDivider(
                          color: Colors.black,
                        ),
                        // replaced with vertical divider
                        // Container(
                        //   height: 20.0,
                        //   // const can be added
                        //   decoration: const BoxDecoration(
                        //       border: Border(right: BorderSide())),
                        // ),
                        // unnecessary container
                        Column(
                          children: [
                            // const can be added
                            const Text("Unit:"),
                            // check for null
                            Text(_cityApiResponse!.unit)
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        : const Center(
            child: Text('NO DATA'),
          );
  }
}

class CityApiRequest {
  String cityName;

  CityApiRequest({
    required this.cityName,
  });

  Map<String, dynamic> toJson() => {
        'city_name': cityName,
      };
}

class CityApiResponse {
  String weather;

  String name;

  String imageUrl;

  String temp;

  String unit;

  CityApiResponse({
    required this.weather,
    required this.name,
    required this.imageUrl,
    required this.temp,
    required this.unit,
  });

  factory CityApiResponse.fromJson(Map<String, dynamic> json) =>
      CityApiResponse(
        weather: json['weather'] ?? '',
        name: json['name'] ?? '',
        imageUrl: json['image_url'] ?? '',
        temp: json['temp'] ?? '',
        unit: json['unit'] ?? '',
      );
}
