import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widget_previews.dart';

void main() {
  runApp(MaterialApp(theme: ThemeData.dark(), home: const MyApp()));
}

class MyApp extends StatefulWidget {
  @Preview(name: 'main app', group: 'main apps')
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

typedef FlyingPumpkin = ({Offset pos, Offset vel});

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  int pumpkins = 0;
  int score = 0;
  int auto = 0;
  int power = 1;
  // title system idea by Kipling
  String title = 'Newbie';
  int autoCost = 10;
  bool autobuyAutoClickersBought = false;
  bool autobuyAutoClickers = false;
  bool autobuyPowerBought = false;
  bool autobuyPower = false;
  int powerCost = 10;
  List<FlyingPumpkin> flyingPumpkins = [];
  Random random = Random();

  void click(int multiplier) {
    flyingPumpkins.add((
      pos: Offset.zero,
      vel: Offset(
        10 * (random.nextDouble() - .5),
        -10 * random.nextDouble() * 2,
      ),
    ));
    setState(() {
      if (multiplier == 0) pumpkins = -5;
      pumpkins += multiplier;
      score += multiplier;
      if (score >= 10) {
        title = 'Advancing';
      }
      if (score >= 100) {
        title = 'Experienced';
      }
      if (score >= 1000) {
        title = 'Expert';
      }
      if (score >= 10000) {
        title = 'Master';
      }
      if (score >= 100000) {
        title = 'You Win';
      }
    });
  }

  Ticker? ticker;
  int ticks = 0;

  @override
  void initState() {
    pumpkins = 100;
    super.initState();
    ticker = createTicker((_) {
      ticks++;
      if (auto > 0 && ticks % (60 / auto) < 1) {
        click((auto / 60).ceil());
      }
      if (autobuyAutoClickers && pumpkins >= autoCost) {
        buyAuto();
      }
      if (autobuyPower && pumpkins >= powerCost) {
        buyPower();
      }
      setState(() {
        if (flyingPumpkins.length > 10) flyingPumpkins.removeAt(0);
        int i = 0;
        while (i < flyingPumpkins.length) {
          Offset pos = flyingPumpkins[i].pos;
          Offset vel = flyingPumpkins[i].vel;
          flyingPumpkins[i] = (pos: pos + vel, vel: vel + Offset(0, 1));
          i++;
        }
      });
    })..start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            TextButton(
              onPressed: pumpkins >= autoCost ? buyAuto : null,
              child: Text('Buy auto-clicker ($autoCost pumpkins)'),
            ),
            TextButton(
              onPressed: pumpkins >= powerCost ? buyPower : null,
              child: Text('Better clicks ($powerCost pumpkins)'),
            ),
            if (autobuyAutoClickersBought)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('AutoAutoClickerBuyer'),
                  Switch(
                    value: autobuyAutoClickers,
                    onChanged: (value) {
                      setState(() {
                        autobuyAutoClickers = value;
                      });
                    },
                  ),
                ],
              )
            else
              TextButton(
                onPressed: pumpkins >= 100
                    ? () {
                        setState(() {
                          autobuyAutoClickersBought = true;
                          pumpkins -= 100;
                        });
                      }
                    : null,
                child: Text('AutoAutoClickerBuyer (100 pumpkins)'),
              ),
            if (autobuyPowerBought)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('AutoBetterClicksBuyer'),
                  Switch(
                    value: autobuyPower,
                    onChanged: (value) {
                      setState(() {
                        autobuyPower = value;
                      });
                    },
                  ),
                ],
              )
            else
              TextButton(
                onPressed: pumpkins >= 100
                    ? () {
                        setState(() {
                          autobuyPowerBought = true;
                          pumpkins -= 100;
                        });
                      }
                    : null,
                child: Text('AutoBetterClicksBuyer (100 pumpkins)'),
              ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text.rich(
          TextSpan(
            text: title,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            children: [
              TextSpan(
                text: ' Pumpkin Clicker',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkResponse(
                      // todo: hit testing???, highlight shape
                      customBorder: PumpkinBorder(),
                      highlightShape: BoxShape.rectangle,
                      hoverColor: Colors.orange.withAlpha(100),
                      highlightColor: Colors.orange,
                      containedInkWell: true,
                      onTap: () => click(power),
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: Pumpkin(),
                      ),
                    ),
                    Text('$pumpkins'),
                    Text('$auto/s'),
                    Text('$power/click'),
                  ],
                ),
              ),
              ...flyingPumpkins.map(
                (e) => Positioned(
                  left: constraints.biggest.width / 2 + e.pos.dx,
                  top: constraints.biggest.height / 2 + e.pos.dy,
                  child: SizedBox(width: 20, height: 20, child: Pumpkin()),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void buyPower() {
    setState(() {
      power++;
      pumpkins -= powerCost;
      powerCost++;
    });
  }

  void buyAuto() {
    setState(() {
      auto++;
      pumpkins -= autoCost;
      autoCost++;
    });
  }
}

class PumpkinBorder extends ShapeBorder {
  const PumpkinBorder();

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsetsGeometry.all(0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path();
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return (PumpkinBox.stem(rect.topLeft, rect.size)
      ..addRRect(PumpkinBox.body(rect.topLeft, rect.size)));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    throw UnsupportedError('pumpkinborder.paint');
  }

  @override
  ShapeBorder scale(double t) {
    return this;
  }
}

class Pumpkin extends LeafRenderObjectWidget {
  @Preview(name: 'a pumpkin', group: 'pumpkins')
  const Pumpkin({super.key});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return PumpkinBox();
  }
}

class PumpkinBox extends RenderBox {
  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    double cornerRadius = size.shortestSide / 8;
    context.canvas.drawRRect(
      body(offset, size),
      Paint()..color = Colors.orange.withAlpha(128),
    );
    Path path = stem(offset, size);
    context.canvas.drawPath(path, Paint()..color = Colors.green.withAlpha(128));
    path = Path();
    path.arcTo(
      Offset(
            offset.dx + size.width / 8,
            offset.dy + size.height - cornerRadius * 2,
          ) &
          Size(cornerRadius * 2, cornerRadius * 2),
      pi / 2,
      pi / 2,
      true,
    );
    path.lineTo(
      offset.dx + size.width / 8,
      offset.dy + size.height / 3 + cornerRadius,
    );
    path.arcTo(
      Offset(offset.dx + size.width / 8, offset.dy + size.height / 3) &
          Size(cornerRadius * 2, cornerRadius * 2),
      pi,
      pi / 2,
      true,
    );

    context.canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..strokeWidth = size.width / 50
        ..style = PaintingStyle.stroke,
    );
    path = Path();
    path.arcTo(
      Offset(
            offset.dx + size.width / 3,
            offset.dy + size.height - cornerRadius * 2,
          ) &
          Size(cornerRadius * 2, cornerRadius * 2),
      pi / 2,
      pi / 2,
      true,
    );
    path.lineTo(
      offset.dx + size.width / 3,
      offset.dy + size.height / 3 + cornerRadius,
    );
    path.arcTo(
      Offset(offset.dx + size.width / 3, offset.dy + size.height / 3) &
          Size(cornerRadius * 2, cornerRadius * 2),
      pi,
      pi / 2,
      true,
    );

    context.canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..strokeWidth = size.width / 50
        ..style = PaintingStyle.stroke,
    );
    path = Path();
    path.arcTo(
      Offset(
            offset.dx + size.width - size.width / 8 - cornerRadius * 2,
            offset.dy + size.height / 3,
          ) &
          Size(cornerRadius * 2, cornerRadius * 2),
      -pi / 2,
      pi / 2,
      true,
    );
    path.lineTo(
      offset.dx + size.width * 7 / 8,
      offset.dy + size.height - cornerRadius,
    );
    path.arcTo(
      Offset(
            offset.dx + size.width * 7 / 8 - cornerRadius * 2,
            offset.dy + size.height - cornerRadius * 2,
          ) &
          Size(cornerRadius * 2, cornerRadius * 2),
      0,
      pi / 2,
      true,
    );

    context.canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..strokeWidth = size.width / 50
        ..style = PaintingStyle.stroke,
    );
    path = Path();
    path.arcTo(
      Offset(
            offset.dx + size.width - size.width / 3 - cornerRadius * 2,
            offset.dy + size.height / 3,
          ) &
          Size(cornerRadius * 2, cornerRadius * 2),
      -pi / 2,
      pi / 2,
      true,
    );
    path.lineTo(
      offset.dx + size.width * 2 / 3,
      offset.dy + size.height - cornerRadius,
    );
    path.arcTo(
      Offset(
            offset.dx + size.width * 2 / 3 - cornerRadius * 2,
            offset.dy + size.height - cornerRadius * 2,
          ) &
          Size(cornerRadius * 2, cornerRadius * 2),
      0,
      pi / 2,
      true,
    );

    context.canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..strokeWidth = size.width / 50
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool hitTestSelf(Offset position) {
    return body(Offset.zero, size).contains(position) ||
        stem(Offset.zero, size).contains(position);
  }

  static RRect body(Offset offset, Size size) {
    double cornerRadius = size.shortestSide / 8;
    return RRect.fromRectAndRadius(
      offset + Offset(0, size.height / 3) &
          Size(size.width, size.height * 2 / 3),
      Radius.circular(cornerRadius),
    );
  }

  static Path stem(Offset offset, Size size) {
    Path path = Path();
    path.moveTo(offset.dx + size.width * 10 / 20, offset.dy);
    path.lineTo(offset.dx + size.width * 13 / 20, offset.dy);
    path.lineTo(offset.dx + size.width * 13 / 20, offset.dy + size.height / 12);
    path.lineTo(offset.dx + size.width * 11 / 20, offset.dy + size.height / 12);
    path.lineTo(offset.dx + size.width * 11 / 20, offset.dy + size.height / 3);
    path.lineTo(offset.dx + size.width * 9 / 20, offset.dy + size.height / 3);
    path.lineTo(offset.dx + size.width * 9 / 20, offset.dy + size.height / 12);
    return path;
  }
}
