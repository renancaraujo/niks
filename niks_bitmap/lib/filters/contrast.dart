import 'dart:typed_data';

import 'package:bitmap/filters.dart';

import 'filter.dart';

const contrastIdentity = 'contrastFilter';
const contrastRateKey = 'contrastRate';

class ContrastFilter extends BitmapLayerFilter {
  ContrastFilter(this._contrastRate);

  ContrastFilter.fromSnapshot(ContrastFilterSnapshot snapshot)
      : _contrastRate = snapshot.contrastRate;

  double _contrastRate;
  double get contrastRate => _contrastRate;
  set contrastRate(double contrastRate) {
    _contrastRate = contrastRate;
    shouldRecompute = true;
  }

  @override
  void apply(Uint8List bitmap, int width, int height, int pixelLength) {
    setContrastFunction(bitmap, contrastRate);
  }

  @override
  BitmapLayerFilterSnapshot<BitmapLayerFilter> createSnapshot() {
    return ContrastFilterSnapshot(this);
  }

  @override
  String get filterIdentity => contrastIdentity;
}

class ContrastFilterSnapshot extends BitmapLayerFilterSnapshot<ContrastFilter> {
  ContrastFilterSnapshot(ContrastFilter contrastFilter)
      : contrastRate = contrastFilter.contrastRate;

  ContrastFilterSnapshot.hydrate(Map<String, dynamic> dehydratedFilter)
      : contrastRate = dehydratedFilter[contrastRateKey];

  final double contrastRate;

  @override
  ContrastFilter createFilter() {
    return ContrastFilter.fromSnapshot(this);
  }

  @override
  Map<String, dynamic> dehydrate() {
    final Map<String, dynamic> returnMap = {};

    returnMap[filterIdentityKey] = filterIdentity;
    returnMap[contrastRateKey] = contrastRate;

    return returnMap;
  }

  @override
  String get filterIdentity => contrastIdentity;
}
