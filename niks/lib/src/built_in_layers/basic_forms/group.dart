import 'dart:collection';
import 'dart:ui';

import '../../../niks.dart';

const String groupIdentity = "Group";
const String layersKey = "layers";

class GroupLayer with LayerContainer implements NiksLayer {
  GroupLayer(layers) {
    this.layers = layers;
  }

  GroupLayer.fromSnapshot(GroupLayerSnapshot snapshot) {
    layers = ListQueue.from(
        snapshot.layers.map<NiksLayer>((NiksLayerSnapshot layerSnapshot) {
      return layerSnapshot.createLayer(null);
    }));
  }

  GroupLayer.fromSnapshotWithPreviousLayer(
      GroupLayer previousLayer, GroupLayerSnapshot snapshot)
      : super() {
    layers = ListQueue.from(
        snapshot.layers.map<NiksLayer>((NiksLayerSnapshot layerSnapshot) {
      final previousLayer = layerByUUID(layerSnapshot.uuid);
      return layerSnapshot.createLayer(previousLayer);
    }));
  }

  @override
  bool locked;

  @override
  String uuid;

  @override
  Offset get coordinates {
    return sizeSpec.coordinates;
  }

  @override
  Size get size {
    return sizeSpec.size;
  }

  @override
  GroupLayerSnapshot createSnapshot() {
    return GroupLayerSnapshot(this);
  }

  @override
  GroupLayerInstallation install() {
    return GroupLayerInstallation();
  }

  @override
  void paint(
    Canvas canvas,
    Offset offset,
    NiksState state,
  ) {
    for (NiksLayer layer in layers) {
      layer.paint(canvas, offset, state);
    }
  }

  SizeSpec get sizeSpec {
    return layers.fold<SizeSpec>(null, (SizeSpec specs, NiksLayer layer) {
      final coordinates = layer.coordinates;
      final size = layer.size;

      final double xFinalItem = coordinates.dx + size.width;
      final double yFinalItem = coordinates.dy + size.height;

      if (specs == null) {
        return SizeSpec(coordinates.dx, coordinates.dy, xFinalItem, yFinalItem);
      }

      final double x = coordinates.dx < specs.x ? coordinates.dx : specs.x;
      final double y = coordinates.dy < specs.y ? coordinates.dy : specs.y;

      final double xFinal =
          xFinalItem > specs.xFinal ? xFinalItem : specs.xFinal;
      final double yFinal =
          yFinalItem > specs.yFinal ? yFinalItem : specs.yFinal;

      return SizeSpec(x, y, xFinal, yFinal);
    });
  }

  @override
  String get layerIdentity => groupIdentity;

  @override
  bool shouldRepaint() {
    return true;
  }
}

class GroupLayerSnapshot implements NiksLayerSnapshot<GroupLayer> {
  GroupLayerSnapshot(GroupLayer groupLayer)
      : uuid = groupLayer.uuid,
        layers = []; // TODO: group snapshot parsing

  GroupLayerSnapshot.hydrate(Map<String, dynamic> dehydratedLayer)
      : uuid = dehydratedLayer[UUIDKey],
        layers = []; // TODO: group snapshot parsing

  @override
  String get layerIdentity => groupIdentity;

  @override
  final String uuid;

  final List<NiksLayerSnapshot> layers;

  @override
  GroupLayer createLayer(GroupLayer previousLayer) {
    if (previousLayer != null) {
      return GroupLayer.fromSnapshot(this);
    }
    return GroupLayer.fromSnapshotWithPreviousLayer(previousLayer, this);
  }

  @override
  Map<String, dynamic> dehydrate() {
    final Map<String, dynamic> returnMap = {};

    returnMap[layerIdentityKey] = layerIdentity;
    returnMap[UUIDKey] = uuid;
    returnMap[layersKey] =
        layers.map<Map<String, dynamic>>((NiksLayerSnapshot layerSnapshot) {
      return layerSnapshot.dehydrate();
    }).toList();

    return returnMap;
  }
}

class GroupLayerInstallation
    implements NiksLayerInstallation<GroupLayer, GroupLayerSnapshot> {
  @override
  bool checkIdentity(String identity) {
    return identity == this.identity;
  }

  @override
  GroupLayerSnapshot hydrate(Map<String, dynamic> dehydratedLayer) {
    return GroupLayerSnapshot.hydrate(dehydratedLayer);
  }

  @override
  String get identity => groupIdentity;
}

class SizeSpec {
  const SizeSpec(
    this.x,
    this.y,
    this.xFinal,
    this.yFinal,
  );

  final double x;
  final double y;
  final double xFinal;
  final double yFinal;

  Size get size {
    return Size(
      xFinal - x,
      yFinal - y,
    );
  }

  Offset get coordinates {
    return Offset(x, y);
  }
}
