import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UpArrowSwitcher extends StatelessWidget {
  const UpArrowSwitcher({
    super.key,
    this.size = 20,
    required this.color,
    required this.onClick,
    required this.controller,
  });

  final double size;
  final Color color;
  final VoidCallback onClick;
  final UpArrowSwitcherController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: controller.turns,
      builder: (context, turns, _) {
        return CupertinoButton(
          onPressed: () {
            controller.startSwitch();
            onClick();
          },
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 0),
          child: AnimatedRotation(
            turns: turns,
            duration: const Duration(milliseconds: 250),
            child: Icon(
              Icons.keyboard_arrow_up_outlined,
              color: color,
              size: size,
            ),
          ),
        );
      },
    );
  }
}

class UpArrowSwitcherController {
  final ValueNotifier<double> turns = ValueNotifier(0.0);

  void startSwitch({double value = 0.5}) {
    turns.value = turns.value == 0 ? value : 0;
  }

  void dispose() {
    turns.dispose();
  }
}
