import 'dart:ui';

import '../../../niks.dart';

const String rectIdentity = "Rect";
const String rectWidthKey = "width";
const String rectHeightKey = "height";
const String rectXKey = "x";
const String rectYKey = "y";
const String rectColorValueKey = "colorValue";

class RectLayer implements NiksLayer {
  RectLayer.fromLTWH(
    double left,
    double top,
    double width,
    double height, [
    this._color = const Color(0xFFFFFFFF),
  ])  : _size = Size(width, height),
        _coordinates = Offset(left, top),
        super();

  RectLayer.fromSnapshot(RectLayerSnapshot snapshot)
      : uuid = snapshot.uuid,
        _size = Size(snapshot.width, snapshot.height),
        _coordinates = Offset(snapshot.x, snapshot.y),
        _color = Color(snapshot.colorValue),
        super();

  @override
  bool locked;

  @override
  String uuid;

  @override
  Size get size => _size;

  set size(Size newSize) {
    _size = newSize;
    _pendingRepaint = true;
  }

  @override
  Offset get coordinates => _coordinates;

  set coordinates(Offset newCoordinates) {
    _coordinates = newCoordinates;
    _pendingRepaint = true;
  }

  Color get color => _color;

  set color(Color newColor) {
    _color = newColor;
    _pendingRepaint = true;
  }

  Color _color;
  Size _size;
  Offset _coordinates;
  bool _pendingRepaint = true;

  @override
  NiksLayerSnapshot<NiksLayer> createSnapshot() {
    return RectLayerSnapshot(this);
  }

  @override
  NiksLayerInstallation<NiksLayer, NiksLayerSnapshot<NiksLayer>> install() {
    return RectLayerInstallation();
  }

  @override
  void paint(
    Canvas canvas,
    Offset offset,
    NiksState state,
  ) {
    canvas.drawRect(
      Rect.fromLTWH(
        coordinates.dx,
        coordinates.dy,
        size.width,
        size.height,
      ),
      Paint()..color = color,
    );

    _pendingRepaint = false;
  }

  @override
  String get layerIdentity => rectIdentity;

  @override
  bool shouldRepaint() => _pendingRepaint;
}

class RectLayerSnapshot implements NiksLayerSnapshot<RectLayer> {
  RectLayerSnapshot(RectLayer layer)
      : uuid = layer.uuid,
        width = layer.size.width,
        height = layer.size.height,
        x = layer.coordinates.dx,
        y = layer.coordinates.dy,
        colorValue = layer.color.value;

  RectLayerSnapshot.hydrate(Map<String, dynamic> dehydratedLayer)
      : uuid = dehydratedLayer[UUIDKey],
        width = dehydratedLayer[rectWidthKey],
        height = dehydratedLayer[rectHeightKey],
        x = dehydratedLayer[rectXKey],
        y = dehydratedLayer[rectYKey],
        colorValue = dehydratedLayer[rectColorValueKey];

  @override
  final String uuid;

  @override
  String get layerIdentity => rectIdentity;

  final double width;
  final double height;
  final double x;
  final double y;
  final int colorValue;

  @override
  Map<String, dynamic> dehydrate() {
    final Map<String, dynamic> returnMap = {};

    returnMap[layerIdentityKey] = layerIdentity;
    returnMap[UUIDKey] = uuid;
    returnMap[rectWidthKey] = width;
    returnMap[rectHeightKey] = height;
    returnMap[rectXKey] = x;
    returnMap[rectYKey] = y;
    returnMap[rectColorValueKey] = colorValue;

    return returnMap;
  }

  @override
  RectLayer createLayer(RectLayer previousLayer) {
    return RectLayer.fromSnapshot(this);
  }
}

class RectLayerInstallation
    extends NiksLayerInstallation<RectLayer, RectLayerSnapshot> {
  @override
  RectLayerSnapshot hydrate(final Map<String, dynamic> dehydratedLayer) {
    return RectLayerSnapshot.hydrate(dehydratedLayer);
  }

  @override
  bool checkIdentity(String identity) {
    return identity == this.identity;
  }

  @override
  String get identity => rectIdentity;
}
