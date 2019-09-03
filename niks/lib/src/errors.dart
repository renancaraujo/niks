class LayerHydrationError extends Error {
  LayerHydrationError(this.message);
  final Object message;
  @override
  String toString() => message;
}

class LayerInstallationError extends Error {
  LayerInstallationError(this.message);
  final Object message;
  @override
  String toString() => message;
}

class BitmapFilterHydrationError extends Error {
  BitmapFilterHydrationError(this.message);
  final Object message;
  @override
  String toString() => message;
}
