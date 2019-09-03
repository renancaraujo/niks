import 'package:flutter/widgets.dart';

import '../niks.dart';

typedef NiksChangesWidgetBuilder = Widget Function(
    BuildContext context, Niks skin);

class NiksChangesBuilder extends StatefulWidget {
  const NiksChangesBuilder({
    Key key,
    this.skin,
    this.builder,
  }) : super(key: key);

  final Niks skin;
  final NiksChangesWidgetBuilder builder;

  @override
  _NiksChangesBuilderState createState() => _NiksChangesBuilderState();
}

class _NiksChangesBuilderState extends State<NiksChangesBuilder> {
  @override
  void initState() {
    super.initState();
    widget.skin.state.addListener(onRepainted);
  }

  void onRepainted() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.skin.state.removeListener(onRepainted);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.skin);
  }
}
