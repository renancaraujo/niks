import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:niks/niks_flutter.dart';
import 'package:niks/niks.dart';
import 'package:image_picker_saver/image_picker_saver.dart' as saver;
import 'package:niks_bitmap/niks_bitmap.dart';
import 'package:bitmap/bitmap.dart';

const imageSize = Size(690.0, 362.0);

void main() => runApp(IsThisAnApp());

class IsThisAnApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Is this a niks demo?',
      theme: ThemeData(
        primarySwatch: Colors.grey, // is this a color?
      ),
      home: IsThisAPage(title: 'Is this generator'),
    );
  }
}

class IsThisAPage extends StatefulWidget {
  IsThisAPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _IsThisAPageState createState() => _IsThisAPageState();
}

class _IsThisAPageState extends State<IsThisAPage> {
  Niks skin;
  BitmapLayer butterflyLayer;
  TextLayer faceLayer;
  TextLayer subtitleLayer;
  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    skin = Niks.blank(
      NiksOptions(width: imageSize.width, height: imageSize.height),
    );
    initLayers();
  }

  @override
  void dispose() {
    skin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildPreview(context),
            _builldOptions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final zoom = constraints.maxWidth / imageSize.width;
        return Container(
          width: imageSize.width * zoom,
          height: imageSize.height * zoom,
          transform: Matrix4.identity()..scale(zoom),
          child: NiksRenderWidget(skin),
        );
      },
    );
  }

  void onChangedFaceText(String newFaceText) {
    faceLayer.text = newFaceText;
    print(newFaceText);
    skin.state.markNeedsPaint();
  }

  void onChangedSubtitleText(String newSubtitle) {
    subtitleLayer.text = newSubtitle;
  }

  void onSaveImage() async {
    setState(() {
      saving = true;
    });

    await exportImage(skin);

    setState(() {
      saving = false;
    });
  }

  Widget _builldOptions(BuildContext context) {
    return Flexible(
      child: Container(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Field(
                    placeholder: 'Subtitle',
                    onChanged: onChangedSubtitleText,
                  ),
                  Field(
                    placeholder: 'Face text',
                    onChanged: onChangedFaceText,
                  ),
                  RaisedButton(
                    onPressed: changeButterfly,
                    child: const Text("Butterfly image"),
                  ),
                ],
              ),
            ],
          )),
    );
  }

  void initLayers() async {
    setState(() {
      loading = true;
    });
    final uint8list = await loadImage();

    final imageLayer = BitmapLayer.fromLTWH(
      Bitmap(
        imageSize.width.toInt(),
        imageSize.height.toInt(),
        uint8list,
      ),
      0,
      0,
      imageSize.width,
      imageSize.height,
    );
    skin.state.addOnTop(imageLayer);
    butterflyLayer = BitmapLayer.fromLTWH(
      Bitmap.blank(130, 130),
      445,
      0,
      130,
      130,
    );
    skin.state.addOnTop(butterflyLayer);

    faceLayer = TextLayer.fromLTWH(
      "",
      107,
      99,
      235,
      46,
      textStyle: TextStyle(
        fontSize: 35,
        fontWeight: FontWeight.w600,
      ),
    );
    skin.state.addOnTop(faceLayer);

    subtitleLayer = TextLayer.fromLTWH(
      "",
      330,
      278,
      257,
      45,
      textStyle: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: Colors.white,
      ),
    );
    skin.state.addOnTop(subtitleLayer);

    await imageLayer.scheduleImageConversion(skin.state);

    setState(() {
      loading = false;
    });
  }

  void changeButterfly() async {
    final image = await ImagePicker.pickImage(source: ImageSource.gallery);
    final imageProvider = FileImage(image);
    final imageInfo = await resolveImageInfo(imageProvider);

    final byteData = await imageInfo.image.toByteData();

    final uint8list = byteData.buffer.asUint8List();
    butterflyLayer.bitmap = Bitmap(
      imageInfo.image.width,
      imageInfo.image.height,
      uint8list,
    );

    butterflyLayer.scheduleImageConversion(skin.state);
  }
}

class Field extends StatelessWidget {
  const Field({Key key, this.placeholder, this.onChanged}) : super(key: key);

  final String placeholder;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: placeholder,
        ),
      ),
    );
  }
}

Future<Uint8List> loadImage() async {
  const ImageProvider imageProvider = const AssetImage("assets/isthis.png");
  final Completer completer = Completer<ImageInfo>();
  final ImageStream stream = imageProvider.resolve(const ImageConfiguration());
  final listener = ImageStreamListener((ImageInfo info, bool synchronousCall) {
    if (!completer.isCompleted) {
      completer.complete(info);
    }
  });
  stream.addListener(listener);
  final imageInfo = await completer.future;
  final byteData = await imageInfo.image.toByteData();
  return byteData.buffer.asUint8List();
}

Future<ImageInfo> resolveImageInfo(imageProvider) {
  final Completer completer = Completer<ImageInfo>();
  final ImageStream stream = imageProvider.resolve(const ImageConfiguration());
  final listener = ImageStreamListener((ImageInfo info, bool synchronousCall) {
    if (!completer.isCompleted) {
      completer.complete(info);
    }
  });
  stream.addListener(listener);
  completer.future.then((_) {
    stream.removeListener(listener);
  });
  return completer.future;
}

Future exportImage(Niks skin) async {
  final transformedIntList = await skin.generatePicture(ImageByteFormat.png);
  final path =
      await saver.ImagePickerSaver.saveFile(fileData: transformedIntList);
  return path;
}
