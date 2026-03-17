import 'package:flutter/cupertino.dart';


class AutoScrollUtil {
  final ScrollController sc = ScrollController();
  double curScrolledDistance = 0;
  double scrollSpeed;
  AnimationController? controller;

  AutoScrollUtil({this.scrollSpeed = 1, required TickerProvider vsync}) {

    controller = AnimationController(duration: const Duration(days: 365), vsync: vsync);
    controller!.addListener(() {
      if(sc.hasClients && sc.position.extentAfter > 0){
        sc.position.jumpTo(scrollSpeed + sc.offset);
        curScrolledDistance = sc.offset;
      }
    });
    controller!.forward();
  }

  void dispose(){
    controller?.dispose();
  }
}
