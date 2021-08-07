import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wall_layout/flutter_wall_layout.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wall Layout Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        backgroundColor: Color(0xFFF5F5F5),
      ),
      home: MyHomePage(title: 'Wall Layout Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late bool _reversed;
  late Axis _direction;
  late int _nbLayers;
  late bool _wrapedOptions;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    _reversed = false;
    _direction = Axis.vertical;
    _nbLayers = 3;
    _controller.forward(from: 0);
    _wrapedOptions = true;
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).backgroundColor;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(title: Text(this.widget.title)),
      body: buildWallLayout(),
      floatingActionButton: _buildOptions(context),
    );
  }

  Widget _buildOptions(BuildContext context) {
    return AnimatedSize(
      duration: Duration(milliseconds: 200),
      reverseDuration: Duration(milliseconds: 200),
      alignment: Alignment.bottomRight,
      vsync: this,
      child: Container(
        margin: EdgeInsets.only(left: 32),
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 6.0),
          ],
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if(!_wrapedOptions) Padding(padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  __buildDivisionsOption(),
                  __buildDirectionOption(),
                  __buildReverseOption(),
                ],
              ),
            ),
            FloatingActionButton(
              elevation: 0.0,
              highlightElevation: 0.0,
              onPressed: () => setState(() => _wrapedOptions = !_wrapedOptions),
              child: Icon(Icons.build),
            ),
          ],
        ),
      ),
    );
  }

  Widget __buildDivisionsOption() {
    return _buildOption(
      "Layers",
      CupertinoSegmentedControl<int>(
        groupValue: _nbLayers,
        children: {2: Text("2"), 3: Text("3"), 4: Text("4")},
        onValueChanged: (value) => setState(() {
          _controller.forward(from: 0.0);
          _nbLayers = value;
        }),
      ),
    );
  }

  Widget __buildReverseOption() {
    return _buildOption(
      "Reverse",
        CupertinoSegmentedControl<bool>(
          groupValue: _reversed,
          children: {false: Text("no"), true: Text("yes")},
          onValueChanged: (value) => setState(() {
            _controller.forward(from: 0.0);
            _reversed = value;
          }),
        ),
    );
  }

  Widget __buildDirectionOption() {
    return _buildOption(
      "Direction",
      CupertinoSegmentedControl<Axis>(
        groupValue: _direction,
        children: {Axis.vertical: Text("vertical"), Axis.horizontal: Text("horizontal")},
        onValueChanged: (value) => setState(() {
          _controller.forward(from: 0.0);
          _direction = value;
        }),
      ),
    );
  }

  Widget _buildOption(String text, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, left: 8.0, bottom: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(child: Text(text), flex: 1,),
          Expanded(child: child, flex: 2,),
        ],
      ),
    );
  }

  Widget buildWallLayout() {
    return WallLayout(
      scrollDirection: _direction,
      stones: _buildStonesList(),
      reverse: _reversed,
      layersCount: _nbLayers,
    );
  }

  List<Stone> _buildStonesList() {
    final data = [
      {"color": Colors.red, "width": 2, "height": 2},
      {"color": Colors.greenAccent, "width": 1, "height": 1},
      {"color": Colors.lightBlue, "width": 1, "height": 2},
      {"color": Colors.purple, "width": 2, "height": 1},
      {"color": Colors.yellow, "width": 1, "height": 1},
      {"color": Colors.cyanAccent, "width": 1, "height": 1},
      {"color": Colors.orange, "width": 2, "height": 2},
      {"color": Colors.green, "width": 1, "height": 1},
      {"color": Colors.pink, "width": 2, "height": 1},
      {"color": Colors.blueAccent, "width": 1, "height": 1},
      {"color": Colors.amber, "width": 1, "height": 2},
      {"color": Colors.teal, "width": 2, "height": 1},
      {"color": Colors.lightGreenAccent, "width": 1, "height": 1},
      {"color": Colors.deepOrange, "width": 1, "height": 1},
      {"color": Colors.deepPurpleAccent, "width": 2, "height": 2},
      {"color": Colors.lightBlueAccent, "width": 1, "height": 1},
      {"color": Colors.limeAccent, "width": 1, "height": 1},
    ];
    return data.map((d) {
      int width = d["width"] as int;
      int height = d["height"] as int;
      return Stone(
        id: data.indexOf(d),
        width: width,
        height: height,
        child: __buildStoneChild(
          background: d["color"] as Color,
          text: "${width}x$height",
          surface: (width * height).toDouble(),
        ),
      );
    }).toList();
  }

  Widget __buildStoneChild({required Color background, required String text, required double surface}) {
    return ScaleTransition(
      scale: CurveTween(curve: Interval(0.0, min(1.0, 0.25 + surface / 6.0))).animate(_controller),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [background, Color.alphaBlend(background.withOpacity(0.6), Colors.black)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text, style: TextStyle(color: Colors.white, fontSize: 32.0)),
      ),
    );
  }
}