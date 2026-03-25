import 'dart:async';
import 'package:flutter/material.dart';

typedef OnBannerTap = void Function(int index);
typedef BannerItemBuilder = Widget Function(BuildContext context, int index);

class CommonBanner extends StatefulWidget {
  final int itemCount;
  final BannerItemBuilder itemBuilder;
  final OnBannerTap? onTap;
  final Duration duration; // 轮播间隔
  final double width; // 宽高比
  final double height; // 宽高比
  final bool autoPlay; // 是否自动播放
  final Curve curve; // 动画曲线

  const CommonBanner({
    super.key,
    required this.width,
    required this.height,
    required this.itemCount,
    required this.itemBuilder,
    this.onTap,
    this.duration = const Duration(seconds: 3),
    this.autoPlay = true,
    this.curve = Curves.easeInOut,
  });

  @override
  State<CommonBanner> createState() => _CommonBannerState();
}

class _CommonBannerState extends State<CommonBanner> {
  late PageController _pageController;
  Timer? _timer;
  int _currentIndex = 0;
  // 设置一个较大的初始倍数实现无限循环
  final int _vritualItemCount = 10000;

  @override
  void initState() {
    super.initState();
    // 1. 初始化 Controller，初始位置设为中间，保证左右都能滑动
    int initialPage = (_vritualItemCount ~/ 2) - ((_vritualItemCount ~/ 2) % (widget.itemCount > 0 ? widget.itemCount : 1));
    _pageController = PageController(initialPage: initialPage);

    // 2. 开启定时器
    _startTimer();
  }

  void _startTimer() {
    if (!widget.autoPlay || widget.itemCount <= 1) return;
    _stopTimer();
    _timer = Timer.periodic(widget.duration, (timer) {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: widget.curve,
        );
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount == 0) return const SizedBox.shrink();

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          // 监听原始指针事件，处理手动滑动与定时器的冲突
          Listener(
            onPointerDown: (_) => _stopTimer(),
            onPointerUp: (_) => _startTimer(),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index % widget.itemCount;
                });
              },
              itemBuilder: (context, index) {
                final int realIndex = index % widget.itemCount;
                return GestureDetector(
                  onTap: () => widget.onTap?.call(realIndex),
                  child: widget.itemBuilder(context, realIndex),
                );
              },
            ),
          ),
          // 指示器 (Indicator)
          _buildIndicator(),
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    return Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.itemCount, (index) {
          return Container(
            width: 8.0,
            height: 8.0,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentIndex == index
                  ? Colors.white
                  : Colors.white.withOpacity(0.5),
            ),
          );
        }),
      ),
    );
  }
}