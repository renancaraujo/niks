import 'dart:collection';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'layer.dart';

class NiksState extends ChangeNotifier with LayerContainer {
  NiksState() {
    layers = ListQueue<NiksLayer>();
  }

  bool hasDisposed = false;

  void paint(Canvas canvas, Offset offset) {
    for (NiksLayer layer in layers) {
      layer.paint(canvas, offset, this);
    }
  }

  void restoreFromSnapshot(NiksStateSnapshot snapshot) {
    final Map<String, NiksLayer> layersMapped = snapshot.layers
        .map<String, NiksLayer>((String uuid, NiksLayerSnapshot layerSnapshot) {
      final NiksLayer previousLayer = layerByUUID(uuid);
      final NiksLayer layer = layerSnapshot.createLayer(previousLayer);
      return MapEntry(uuid, layer);
    });
    layers.clear();
    layers.addAll(layersMapped.values);
    markNeedsPaint();
  }

  NiksStateSnapshot createSnapshot() {
    return NiksStateSnapshot.fromState(this);
  }

  bool shouldRepaint() {
    return !layers.every((NiksLayer layer) => !layer.shouldRepaint());
  }

  void markNeedsPaint() {
    if (hasDisposed) {
      return;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    hasDisposed = true;
    super.dispose();
  }

  @override
  void addOnTop(NiksLayer layer) {
    super.addOnTop(layer);
    markNeedsPaint();
  }
}

class NiksStateSnapshot {
  NiksStateSnapshot.fromState(NiksState state)
      : layers = Map.fromIterable(
          state.layers,
          key: (layer) => layer.uuid,
          value: (layer) => layer.createSnapshot(),
        );

  NiksStateSnapshot.hydrate(final Map<String, dynamic> dehydratedStateSnapshot,
      NiksLayerDefinition layerDefinition)
      : layers = dehydratedStateSnapshot.map<String, NiksLayerSnapshot>(
            (String key, dynamic dehydratedLayer) {
          final layerSnapshot = layerDefinition.hydrateLayer(dehydratedLayer);
          return MapEntry<String, NiksLayerSnapshot>(key, layerSnapshot);
        });

  final Map<String, NiksLayerSnapshot> layers;

  Map<String, dynamic> dehydrate() {
    final Map<String, dynamic> returnMap = {};
    layers.forEach((String key, NiksLayerSnapshot layerSnapshot) {
      returnMap[key] = layerSnapshot.dehydrate();
    });
    return returnMap;
  }
}

mixin LayerContainer {
  ListQueue<NiksLayer> layers;

  void addOnTop(NiksLayer layer) {
    layers.addLast(layer);
  }

  NiksLayer layerByUUID(String uuid) {
    return layers.firstWhere((NiksLayer layer) => layer.uuid == uuid,
        orElse: () => null);
  }
}
