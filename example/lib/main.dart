import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wall_layout/flutter_wall_layout.dart';
import 'package:flutter_wall_layout/wall_builder.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wall Layout Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.light(background: Color(0xFFF5F5F5)),
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
  late bool _fixedPrimaryAxisStoneSize;
  late bool _reversed;
  late Axis _direction;
  late int _nbLayers;
  late bool _wrapedOptions;
  bool _random = false;
  late List<Stone> _stones;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    _fixedPrimaryAxisStoneSize = false;
    _reversed = false;
    _direction = Axis.vertical;
    _nbLayers = 3;
    _controller.forward(from: 0);
    _wrapedOptions = true;
    _stones = _buildStonesList();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).colorScheme.background;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(this.widget.title),
        actions: [
          IconButton(
            onPressed: _onRandomClicked,
            icon: Icon(
              _random ? Icons.sync : Icons.sync_disabled,
            ),
            tooltip: "Random stone sizes + custom WallHandler",
          )
        ],
      ),
      body: buildWallLayout(),
      floatingActionButton: _buildOptions(context),
    );
  }

  void _onRandomClicked() {
    setState(() {
      _random = !_random;
      if (_random) {
        _stones = _buildRandomStonesList(_nbLayers);
      } else {
        _stones = _buildStonesList();
      }
    });
  }

  Widget _buildOptions(BuildContext context) {
    return AnimatedSize(
      duration: Duration(milliseconds: 200),
      reverseDuration: Duration(milliseconds: 200),
      alignment: Alignment.bottomRight,
      child: Container(
        margin: EdgeInsets.only(left: 32),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 6.0),
          ],
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!_wrapedOptions)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    __buildDivisionsOption(),
                    __buildDirectionOption(),
                    __buildReverseOption(),
                    __buildFixedPrimaryAxisStoneSizeOption(),
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
          if (_random) {
            _stones = _buildRandomStonesList(_nbLayers);
          }
        }),
      ),
    );
  }

  Widget __buildFixedPrimaryAxisStoneSizeOption() {
    return _buildOption(
      "Fixed Primary Axis Size",
      CupertinoSegmentedControl<bool>(
        groupValue: _fixedPrimaryAxisStoneSize,
        children: {false: Text("no"), true: Text("yes (300px)")},
        onValueChanged: (value) => setState(() {
          _controller.forward(from: 0.0);
          _fixedPrimaryAxisStoneSize = value;
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
        children: {
          Axis.vertical: Text("vertical"),
          Axis.horizontal: Text("horizontal")
        },
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
          Flexible(
            child: Text(text),
            flex: 1,
          ),
          Expanded(
            child: child,
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget buildWallLayout() {
    return WallLayout(
      wallBuilder: _random
          ? FillingHolesWallBuildHandler(
              context: context,
              childBuilder: (_) => DecoratedBox(
                decoration: BoxDecoration(
                    color: Color(0xffececee),
                    borderRadius: BorderRadius.circular(12)),
              ),
            )
          : WallBuilder.standard(),
      scrollDirection: _direction,
      stones: _stones,
      reverse: _reversed,
      layersCount: _nbLayers,
      primaryAxisStoneSize: _fixedPrimaryAxisStoneSize ? 300 : null,
    );
  }

  List<Stone> _buildRandomStonesList(int maxLayer) {
    Random r = Random();
    final next = () => r.nextInt(maxLayer) + 1;
    final colors = [
      Colors.red,
      Colors.greenAccent,
      Colors.lightBlue,
      Colors.purple,
      Colors.yellow,
      Colors.cyanAccent,
      Colors.orange,
      Colors.green,
      Colors.pink,
      Colors.blueAccent,
      Colors.amber,
      Colors.teal,
      Colors.lightGreenAccent,
      Colors.deepOrange,
      Colors.deepPurpleAccent,
      Colors.lightBlueAccent,
      Colors.limeAccent,
    ];
    return colors.map((color) {
      int width = next();
      int height = next();
      return Stone(
        id: colors.indexOf(color),
        width: width,
        height: height,
        child: __buildStoneChild(
          background: color,
          text: "${width}x$height",
          surface: (width * height).toDouble(),
        ),
      );
    }).toList();
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

  Widget __buildStoneChild(
      {required Color background,
      required String text,
      required double surface}) {
    return ScaleTransition(
      scale: CurveTween(curve: Interval(0.0, min(1.0, 0.25 + surface / 6.0)))
          .animate(_controller),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              background,
              Color.alphaBlend(background.withOpacity(0.6), Colors.black)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child:
            Text(text, style: TextStyle(color: Colors.white, fontSize: 32.0)),
      ),
    );
  }
}

// Fill empty place with stone 1x1
class FillingHolesWallBuildHandler extends WallBuilder {
  final WallBuilder proxy = WallBuilder.standard();
  final BuildContext context;
  final WidgetBuilder childBuilder;

  FillingHolesWallBuildHandler(
      {required this.childBuilder, required this.context})
      : super();

  WallBlueprint _buildBlueprint(List<Stone> stones) {
    return proxy.build(
        mainAxisSeparations: mainAxisSeparations,
        reverse: reverse,
        direction: direction,
        stones: stones);
  }

  void _findHoles(WallBlueprint blueprint, Function(int x, int y) onHoleFound) {
    List<Rect> bounds = blueprint.stonesPosition
        .map((key, value) => MapEntry(
            key,
            Rect.fromLTWH(value.x.toDouble(), value.y.toDouble(),
                key.width.toDouble(), key.height.toDouble())))
        .values
        .toList();
    for (int x = 0; x < blueprint.size.width; x++) {
      for (int y = 0; y < blueprint.size.height; y++) {
        Rect area = Rect.fromLTWH(x.toDouble(), y.toDouble(), 1.0, 1.0);
        bounds.firstWhere(
          (element) => area.overlaps(element),
          orElse: () {
            onHoleFound(x, y);
            return area;
          },
        );
        bounds.add(area);
      }
    }
  }

  @override
  Map<Stone, StoneStartPosition> computeStonePositions(List<Stone> stones) {
    final blueprint = _buildBlueprint(stones);
    Map<Stone, StoneStartPosition> positions = blueprint.stonesPosition;
    int idStart = 10000;
    _findHoles(blueprint, (x, y) {
      final stone = Stone(
        height: 1,
        width: 1,
        id: idStart++,
        child: childBuilder.call(context),
      );
      positions[stone] = StoneStartPosition(x: x, y: y);
    });
    return positions;
  }
}
