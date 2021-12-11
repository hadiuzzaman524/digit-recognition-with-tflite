import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tf;
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:io' as io;
import "package:image/image.dart" as img;

class Classifier {
  Classifier(); // Empty init/constructor

/*  classifyImage(PickedFile image) async {
    // Takes PickedFile image as input and returns an integer
    // of which integer it was (hopefully)!

    // Ugly boilerplate to get it to Uint8List
    var _file = io.File(image.path);
    img.Image imageTemp = img.decodeImage(_file.readAsBytesSync());
    img.Image resizedImg = img.copyResize(imageTemp, height: 28, width: 28);
    var imgBytes = resizedImg.getBytes();
    var imgAsList = imgBytes.buffer.asUint8List();

    // Everything "important" is done in getPred
    return getPred(imgAsList);
  }*/

  Future<int> classifyDrawing(List<Offset?> points) async {
    // Takes img as a List of Points from Drawing and returns Integer
    // of which digit it was (hopefully)!

    // Ugly boilerplate to get it to Uint8List
    final picture = toPicture(points); // convert List to Picture
    final image = await picture.toImage(28, 28); // Picture to 28x28 Image
    ByteData? imgBytes = await image.toByteData(); // Read this image
    var imgAsList = imgBytes?.buffer.asUint8List();

    // Everything "important" is done in getPred
    return getPred(imgAsList!);
    // return 5;
  }

  Future<int> getPred(Uint8List imgAsList) async {
    // Takes img as a List as input and returns an Integer of which digit
    // the model predicts.

    // We need to convert Image which is in RGBA to Grayscale, first we can ignore
    // the alpha (opacity) and we can take the mean of R,G,B into a single channel
    List<double> resultBytes = List.filled(28 * 28, 0, growable: false);

    int index = 0;
    for (int i = 0; i < imgAsList.lengthInBytes; i += 4) {
      final r = imgAsList[i];
      final g = imgAsList[i + 1];
      final b = imgAsList[i + 2];

      // Take the mean of R,G,B channel into single GrayScale
      resultBytes[index] = (((r + g + b) / 3.0) / 255.0);
      index++;
    }

    // Thanks for having inbuilt reshape in tflite flutter, this would much more
    // annoying otherwise :)
    var input = resultBytes.reshape([1, 28, 28, 1]);
    var output = List.filled(1 * 10, 0, growable: false).reshape([1, 10]);

    // Can be used to set GPUDelegate, NNAPI, parallel cores etc. We won't use
    // this, but can be good to know it exists.
    tf.InterpreterOptions interpreterOptions = tf.InterpreterOptions();

    // Track how long it took to do inference
    int startTime = DateTime.now().millisecondsSinceEpoch;
    try {
      tf.Interpreter interpreter = await tf.Interpreter.fromAsset(
          "model.tflite",
          options: interpreterOptions);
      interpreter.run(input, output);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading or running model: ' + e.toString());
      }
    }

    int endTime = new DateTime.now().millisecondsSinceEpoch;
    if (kDebugMode) {
      print("Inference took ${endTime - startTime} ms");
    }

    // Obtain the highest score from the output of the model
    double highestProb = 0;
    late int digitPred;

    for (int i = 0; i < output[0].length; i++) {
      if (output[0][i] > highestProb) {
        highestProb = output[0][i];
        digitPred = i;
      }
    }
    return digitPred;
  }
}

ui.Picture toPicture(List<Offset?> points) {
  // Obtain a Picture from a List of points
  // This Picture can then be converted to something
  // we can send to our model. Seems unnecessary to draw twice,
  // but couldn't find a way to record while using CustomPainter,
  // this is a future improvement to make.

  final _whitePaint = Paint()
    ..strokeCap = StrokeCap.round
    ..color = Colors.white
    ..strokeWidth = 16;

  final _bgPaint = Paint()..color = Colors.black;
  final _canvasCullRect =
      Rect.fromPoints(const Offset(0, 0), const Offset(28.0, 28.0));
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, _canvasCullRect)..scale(28 / 372);

  canvas.drawRect(const Rect.fromLTWH(0, 0, 28, 28), _bgPaint);
  for (int i = 0; i < points.length - 1; i++) {
    if (points[i] != null && points[i + 1] != null) {
      canvas.drawLine(
          points[i] as Offset, points[i + 1] as Offset, _whitePaint);
    }
  }
  return recorder.endRecording();
}
