import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Offset> points=[];
  final pointMode= ui.PointMode.points;
  int digit=-1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Digit Recognizer'),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10,),
            Container(
              height: 400,
              width: 400,
              color: Colors.black12,
              child: Container(
                color: Colors.black26,
                margin:const EdgeInsets.symmetric(horizontal:5,vertical: 10 ),
                padding:const EdgeInsets.all(5),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black45,

                  ),
                  child: GestureDetector(

                    onPanUpdate: (DragUpdateDetails details){
                      Offset _location= details.localPosition;
                      if(_location.dx>=0 && _location.dx<=400 &&
                      _location.dy>=0 && _location.dy<=400){
                        setState(() {
                          points.add(_location);
                        });
                      }
                      if (kDebugMode) {
                        print(_location);
                      }
                    },
                    onPanEnd: (DragEndDetails details){
                     // List.from(line.path)..add(null);
                      // digit= // call classifier

                      setState(() {
                      });
                    },
                    child: CustomPaint(
                      painter: Painter(points:points),
                    ),
                  ),
                ),
              ),
            ),
           // const SizedBox(height: 50,),
            Column(
              children: const [
               Text("1",style: TextStyle(
                 fontSize: 60,
                 color: Colors.black,
                 fontWeight: FontWeight.bold,

               ),),

              ],
            ),
          ],
        ),
    floatingActionButton: FloatingActionButton(
      onPressed: () { setState(() {
        points.clear();
      }); },
      child: const Icon(Icons.clear),
    ),);
  }
}

class Painter extends CustomPainter {

  final List<Offset> points;
  Painter({required this.points});

  final Paint _paintDetails = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 8.0 // strokeWidth 4 looks good, but strokeWidth approx. 16 looks closer to training data
    ..color = Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
     // if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i], points[i + 1], _paintDetails);
     // }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
   return true;
  }
}
