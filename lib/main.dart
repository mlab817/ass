import 'package:flutter/material.dart';
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

class CityPage extends StatefulWidget {
  const CityPage({Key? key}) : super(key: key);
  @override
  State<CityPage> createState() => _CityPageState();
}

class _CityPageState extends State<CityPage> {
  bool? hasError;
  var _l = true;
  final _N = "City";
  String? d;
  TextEditingController _cityController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Weather Page",
          ),
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              // unnecessary container as there are no decorations, size or other properties added
              Container(
                child: TextField(
                  controller: _cityController,
                  decoration: InputDecoration(hintText: "Enter $_N name"),
                ),
              ),
              // child is missing
              ElevatedButton(
                onPressed: () async {
                  // http is missing
                  // await is missing
                  post("https://mybackend/cities",
                      body: '{"city_name":"name"}'
                          .replaceAll("name", _cityController.text),
                      headers: {
                        "Authorization": (await SharedPreferences
                                .getInstance()) // shared preferences is not imported
                            .getString("TOKEN")
                      }).then((resp) {
                    d = resp.body;
                  });
                },
              )
            ],
          ),
          buildBody(context)
        ],
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    String rg = '"(weather)":"((\\"|[^"])*)"';
    String w = RegExp(rg)
        .firstMatch(d)
        .group(2); // check for null as String is not nullable
    return _l
        ? Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ) // unnecessary use of container
        : hasError // hasError can have a null value
            ? Container()
            : Card(
                child: Column(
                  children: [
                    Container(
                      child: Text(
                          "City:${RegExp('"(name)":"((\\"|[^"])*)"').firstMatch(d).group(2)}"),
                    ),
                    Container(
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: "History:\n",
                          ),
                          TextSpan(
                            text: RegExp('"(name)":"((\\"|[^"])*)"')
                                .firstMatch(d)
                                .group(2),
                          ),
                        ]),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      height: 750.0,
                      child: Image.network(
                        RegExp('"(image_url)":"((\\"|[^"])*)"')
                            .firstMatch(d)
                            .group(2),
                        fit: BoxFit.fill,
                      ),
                    ),
                    Row(
                      children: [
                        // unnecessary use of container
                        Container(
                          child: Column(
                            children: [
                              Text("Temperature:"),
                              Text(
                                  "${RegExp('"(temp)":"((\\"|[^"])*)"').firstMatch(w).group(2)}")
                            ],
                          ),
                        ),
                        Container(
                          height: 20.0,
                          // const can be added
                          decoration: BoxDecoration(
                              border: Border(right: BorderSide())),
                        ),
                        Container(
                          child: Column(
                            children: [
                              // const can be added
                              Text("Unit:"),
                              // check for null
                              Text(
                                  "${RegExp('"(unit)":"((\\"|[^"])*)"').firstMatch(w).group(2)}")
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              );
  }
}
