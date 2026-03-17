import 'package:flutter/cupertino.dart';

/// 页面保活
class AliveWidget extends StatefulWidget {
  final Widget child;

  const AliveWidget({super.key, required this.child});

  @override
  State<StatefulWidget> createState() {
    return _KeepAliveState();
  }
}

class _KeepAliveState extends State<AliveWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
