import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

import '../../../../util/Log.dart';


/// SliverStickyHeader
class TabView7 extends StatelessWidget {
  const TabView7({super.key});

  @override
  Widget build(BuildContext context) {
    // 只要第一次打开时请求过，数据就会一直保存在这个内存对象中
    return CustomScrollView(slivers: [
      SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, i) => ListTile(
            leading: SizedBox(),
            title: Text('=====List tile #$i', style: TextStyle(fontSize: 13, color: Color(0xff333333)),),
          ),
          childCount: 5,
        ),
      ),
      SliverStickyHeaderWidget(childIndex: 1,),
      SliverStickyHeaderWidget(childIndex: 2,),
      SliverStickyHeaderWidget(childIndex: 3,),
      SliverStickyHeaderWidget(childIndex: 4,),
      SliverStickyHeaderWidget(childIndex: 5,),
      SliverStickyHeaderWidget(childIndex: 6,),
    ],);
  }
}


class SliverStickyHeaderWidget extends StatelessWidget {
  const SliverStickyHeaderWidget({
    super.key, required this.childIndex,
  });

  final int childIndex;

  @override
  Widget build(BuildContext context) {
    ///  header和第一个item widget 总是会渲染出来 无论是否可见，
    return SliverStickyHeader.builder(
      builder: (context, state) {
      //  Log.d("=builder==header==childIndex:$childIndex");
        return Container(
          height: 60.0,
          color: (state.isPinned ? Colors.lightBlue : Colors.lightBlue)
              .withOpacity(1.0 - state.scrollPercentage),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          alignment: Alignment.centerLeft,
          child:  Text(
            'Header #$childIndex',
            style: TextStyle(color: Colors.white),
          ),
        );
      },
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, i){
                Log.d("=sliver====childIndex:$childIndex---$i==");
                return ListTile(
                  leading:  CircleAvatar(
                    child: Text('$childIndex'),
                  ),
                  title: Text('List tile #$i'),
                );
              },
          childCount: 8,
        ),
      ),
    );
  }
}

