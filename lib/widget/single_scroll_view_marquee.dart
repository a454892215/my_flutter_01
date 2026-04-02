import 'package:flutter/cupertino.dart';
import 'package:flutter_comm/widget/scroller_marquee_helper.dart';

import '../../util/Log.dart';
import '../../util/text_util.dart';
import '../screnn_info.dart';


class SingleScrollViewMarquee extends StatefulWidget {
  const SingleScrollViewMarquee({
    super.key,
    required this.style,
    required this.text,
  });

  final TextStyle style;
  final String text;

  @override
  State<StatefulWidget> createState() {
    return MyState();
  }
}

class MyState extends State<SingleScrollViewMarquee> with TickerProviderStateMixin {
  late MarqueeHelper marqueeHelper;
  @override
  void initState() {
    Size size = TextMeasureUtil.getTextSize(text: widget.text, maxWidth: 9999999, style: widget.style);
    int seconds = size.width ~/ 150.w;
    Log.d("SingleScrollViewMarquee 的时间是： $seconds");
    marqueeHelper = MarqueeHelper(seconds, vsync: this);
    marqueeHelper.setUpMarquee();

    /// 设置滚动到结尾的接听 滚动到结尾才能进行数据置换更新
    // marqueeHelper.setOnScrollToEndListener(() {});
    super.initState();
  }

  @override
  void dispose() {
    marqueeHelper.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        controller: marqueeHelper.sc,
        child: Center(
            child: Row(
          children: [
            Text(
              widget.text,
              style: widget.style,
            ),
          ],
        )));
  }
}
