library niks;

import 'dart:typed_data';
import 'dart:ui';

import 'package:uuid/uuid.dart';

import 'niks.dart';
import 'src/built_in_layers/built_in_layers.dart';
import 'src/constants.dart' as constants;
import 'src/layer.dart';
import 'src/state.dart';

export 'src/built_in_layers/built_in_layers.dart';
export 'src/constants.dart';
export 'src/errors.dart';
export 'src/layer.dart';
export 'src/state.dart';

class NiksOptions {
  const NiksOptions({
    this.width,
    this.height,
  });

  final double width;
  final double height;

  Size get size => Size(width, height);
}

class Niks {
  Niks.blank(this.options)
      : state = NiksState(),
        layerDefinition = NiksLayerDefinition()
          ..installLayer(RectLayerInstallation())
          ..installLayer(TextLayerInstallation());

  final NiksOptions options;

  final NiksState state;
  final NiksLayerDefinition layerDefinition;

  void addLayerOnTop(NiksLayer layer) {
    _processLayer(layer);
    state.addOnTop(layer);
  }

  void hydrate(Map<String, dynamic> dehydratedNiks) {
    final snapshot = NiksStateSnapshot.hydrate(
      dehydratedNiks[constants.niksStateKey],
      layerDefinition,
    );
    state.restoreFromSnapshot(snapshot);
  }

  void _processLayer(NiksLayer layer) {
    layerDefinition.verifyLayer(layer.createSnapshot().layerIdentity);
    if (layer.uuid != null) {
      return;
    }
    layer.uuid = Uuid().v4();
  }

  void dispose() {
    state.dispose();
  }

  Map<String, dynamic> dehydrate() {
    final Map<String, dynamic> returnMap = {};
    returnMap[constants.niksVersionKey] = constants.niksVersion;
    returnMap[constants.niksProjectWidthKey] = options.width;
    returnMap[constants.niksProjectHeightKey] = options.height;
    returnMap[constants.niksStateKey] = state.createSnapshot().dehydrate();
    return returnMap;
  }

  Future<Uint8List> generatePicture(ImageByteFormat format) async {
    final PictureRecorder recorder = PictureRecorder();

    final canvas = Canvas(recorder);
    final rect = Rect.fromLTWH(0.0, 0.0, options.width, options.height);
    canvas.clipRect(rect);
    state.paint(canvas, Offset.zero);

    final image = await recorder
        .endRecording()
        .toImage(options.width.floor(), options.height.floor());

    final pngBytes = await image.toByteData(format: format);
    return pngBytes.buffer.asUint8List();
  }

  void installLayer(NiksLayerInstallation installation) =>
      layerDefinition.installLayer(installation);
}
