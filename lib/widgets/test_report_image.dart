import 'package:tflite/tflite.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';

class ObjectDetectionScreen extends StatefulWidget {
  @override
  _ObjectDetectionScreenState createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  File? _image;
  final picker = ImagePicker();
  List<dynamic> _recognitions = [];
  bool _isModelLoaded = false;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    await Tflite.loadModel(
      model: 'assets/best-fp16.tflite',
      labels: 'assets/labels.txt',
    );
    setState(() {
      _isModelLoaded = true;
    });
    print('Inside Load Model');
  }

  List<List<List<double>>> convertImageToFileShape(
      File imageFile, int width, int height) {
    img.Image? image = img.decodeImage(imageFile.readAsBytesSync());

    img.Image resizedImage =
        img.copyResize(image!, width: width, height: height);

    List<int> pixelData = resizedImage.getBytes();

    List<List<List<double>>> inputData = [];

    for (int i = 0; i < pixelData.length; i += width) {
      List<List<double>> row = [];
      for (int j = i; j < i + width; j++) {
        double value = pixelData[j].toDouble();
        row.add([value]);
      }
      inputData.add(row);
    }

    return inputData;
  }

  Future<void> convertImageToTensorFlowLite(String imagePath) async {
    final File imageFile = File(imagePath);
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final img.Image? image = img.decodeImage(imageBytes);

    const int width = 10647;
    const int height = 7;

    final img.Image resizedImage =
        img.copyResize(image!, width: width, height: height);
    final img.Image grayscaleImage = img.grayscale(resizedImage);
    final Uint8List inputBytes = grayscaleImage.getBytes();

    final interpreter = await Interpreter.fromAsset('assets/best-fp16.tflite');

    final List<int> inputShape = [1, width, height, 1];

    final inputTensor = Tensor.computeNumElements(
      inputShape,
    );

    interpreter.allocateTensors();
    var inputTensors = interpreter.getInputTensors();
    inputTensors[0].copyTo(inputTensor);

    interpreter.invoke();

    final outputTensor = interpreter.getOutputTensor(0);
    final outputData = outputTensor.data;

    // Process the output data as needed

    interpreter.close();
  }

  Future<void> classifyImage(File image) async {
    print('Inside Classify Image');
    File imageFile = File(image.path);
    int width = 640;
    int height = 640;

    // List<List<List<double>>> inputData =
    //     convertImageToFileShape(imageFile, width, height);
    await convertImageToTensorFlowLite(image.path);
    //  print(inputData);

    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      threshold: 0.5,
      numResults: 2,
    );

    print(recognitions);

    if (recognitions != null) {
      // Check if the inference was successful
      if (recognitions.isNotEmpty) {
        print(recognitions);
        setState(() {
          _recognitions = recognitions;
        });
      } else {
        // Handle the case when no results are returned
        print('No results were obtained from the model inference.');
      }
    } else {
      // Handle the case when an error occurs during inference
      // var error = Tflite.getLastSdkError();
      print('Error during model inference: ');
    }
  }

  void pickImage() async {
    // final pickedFile = await picker.pickImage(source: ImageSource.camera);
    XFile? imageFile = await picker.pickImage(source: ImageSource.gallery);
    print(imageFile);
    if (imageFile != null) {
      setState(() {
        _image = File(imageFile.path);
        print(_image!.path);
      });
      classifyImage(_image!);
    } else {
      print('No Image selected');
    }
    print('Inside Pick Image');
  }

  Widget buildImageWithBoundingBoxes() {
    final image = img.decodeImage(_image!.readAsBytesSync());
    final imageWidget = Image.file(_image!);
    final imageSize = MediaQuery.of(context).size;
    final originalImageWidth = image!.width.toDouble();
    final originalImageHeight = image.height.toDouble();
    final screenScaleFactor = imageSize.width / originalImageWidth;

    return Stack(
      children: <Widget>[
        imageWidget,
        Container(
          width: imageSize.width,
          height: imageSize.height,
          child: CustomPaint(
            painter: BoundingBoxPainter(
              recognitions: _recognitions,
              originalImageWidth: originalImageWidth,
              originalImageHeight: originalImageHeight,
              screenScaleFactor: screenScaleFactor,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Object Detection'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            if (_isModelLoaded)
              if (_image != null)
                buildImageWithBoundingBoxes()
              else
                Text('No image selected.'),
            ElevatedButton(
              onPressed: pickImage,
              child: Text('Select Image'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}

class BoundingBoxPainter extends CustomPainter {
  final List<dynamic> recognitions;
  final double originalImageWidth;
  final double originalImageHeight;
  final double screenScaleFactor;

  BoundingBoxPainter({
    required this.recognitions,
    required this.originalImageWidth,
    required this.originalImageHeight,
    required this.screenScaleFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    print('In Paint');
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    print(recognitions);
    if (recognitions != null && recognitions.isNotEmpty) {
      for (final recognition in recognitions) {
        final double left = recognition['rect']['x'] * screenScaleFactor;
        final double top = recognition['rect']['y'] * screenScaleFactor;
        final double width = recognition['rect']['w'] * screenScaleFactor;
        final double height = recognition['rect']['h'] * screenScaleFactor;

        final rect = Rect.fromLTWH(left, top, width, height);
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(BoundingBoxPainter oldDelegate) {
    return recognitions != oldDelegate.recognitions ||
        originalImageWidth != oldDelegate.originalImageWidth ||
        originalImageHeight != oldDelegate.originalImageHeight ||
        screenScaleFactor != oldDelegate.screenScaleFactor;
  }
}

Future<void> main() async {
  final imagePath = 'path/to/image.jpg';
}
