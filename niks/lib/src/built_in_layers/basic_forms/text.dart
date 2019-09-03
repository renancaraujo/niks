import 'dart:ui';

import 'package:flutter/rendering.dart';

import '../../../niks.dart';

const String textIdentity = "Text";
const String textWidthKey = "width";
const String textHeightKey = "height";
const String textXKey = "x";
const String textYKey = "y";
const String textColorValueKey = "colorValue";
const String textKey = "text";
const String textFontSizeKey = "fontSize";

class TextLayer implements NiksLayer {
  TextLayer.fromLTWH(
      this._text, double left, double top, double width, double height,
      {TextStyle textStyle})
      : _size = Size(width, height),
        _coordinates = Offset(left, top),
        _textStyle = textStyle,
        super();

  TextLayer.fromSnapshot(TextLayerSnapshot snapshot)
      : uuid = snapshot.uuid,
        _size = Size(snapshot.width, snapshot.height),
        _coordinates = Offset(snapshot.x, snapshot.y),
        _text = snapshot.text,
        _textStyle = TextStyle(
          color: Color(snapshot.colorValue),
          fontSize: snapshot.fontSize,
        ),
        super();

  bool _pendingRepaint = true;

  @override
  bool locked;

  @override
  String uuid;

  @override
  Offset get coordinates => _coordinates;

  set coordinates(Offset newCoordinates) {
    _coordinates = newCoordinates;
    _pendingRepaint = true;
  }

  Offset _coordinates;

  @override
  Size get size => _size;

  set size(Size newSize) {
    _size = newSize;
    _pendingRepaint = true;
  }

  Size _size;

  String get text => _text;

  set text(String text) {
    _text = text;
    _pendingRepaint = true;
  }

  String _text;

  TextStyle get textStyle => _textStyle;

  set textStyle(TextStyle textStyle) {
    _textStyle = textStyle;
    _pendingRepaint = true;
  }

  TextStyle _textStyle;

  @override
  NiksLayerSnapshot<NiksLayer> createSnapshot() {
    // TODO: implement createSnapshot
    return null;
  }

  @override
  TextLayerInstallation install() {
    return TextLayerInstallation();
  }

  @override
  String get layerIdentity => textIdentity;

  @override
  void paint(Canvas canvas, Offset offset, NiksState state) {
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    final offset = coordinates;
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint() => _pendingRepaint;
}

class TextLayerSnapshot implements NiksLayerSnapshot<TextLayer> {
  TextLayerSnapshot(TextLayer layer)
      : uuid = layer.uuid,
        width = layer.size.width,
        height = layer.size.height,
        x = layer.coordinates.dx,
        y = layer.coordinates.dy,
        colorValue = layer.textStyle.color.value,
        fontSize = layer.textStyle.fontSize,
        text = layer.text;

  TextLayerSnapshot.hydrate(Map<String, dynamic> dehydratedLayer)
      : uuid = dehydratedLayer[UUIDKey],
        width = dehydratedLayer[textWidthKey],
        height = dehydratedLayer[textHeightKey],
        x = dehydratedLayer[textXKey],
        y = dehydratedLayer[textYKey],
        colorValue = dehydratedLayer[textColorValueKey],
        text = dehydratedLayer[textKey],
        fontSize = dehydratedLayer[textFontSizeKey];

  @override
  final String uuid;

  final double width;
  final double height;
  final double x;
  final double y;
  final int colorValue;
  final String text;
  final double fontSize;

  @override
  String get layerIdentity => textIdentity;

  @override
  TextLayer createLayer(TextLayer previousLayer) {
    return TextLayer.fromSnapshot(this);
  }

  @override
  Map<String, dynamic> dehydrate() {
    final Map<String, dynamic> returnMap = {};

    returnMap[layerIdentityKey] = layerIdentity;
    returnMap[UUIDKey] = uuid;
    returnMap[textWidthKey] = width;
    returnMap[textHeightKey] = height;
    returnMap[textXKey] = x;
    returnMap[textYKey] = y;
    returnMap[textColorValueKey] = colorValue;
    returnMap[textKey] = text;
    returnMap[textFontSizeKey] = fontSize;

    return returnMap;
  }
}

class TextLayerInstallation
    extends NiksLayerInstallation<TextLayer, TextLayerSnapshot> {
  @override
  TextLayerSnapshot hydrate(Map<String, dynamic> dehydratedLayer) {
    return TextLayerSnapshot.hydrate(dehydratedLayer);
  }

  @override
  bool checkIdentity(String identity) {
    return identity == this.identity;
  }

  @override
  String get identity => textIdentity;
}
