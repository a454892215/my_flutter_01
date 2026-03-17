import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    return Obx(
      () {
        return CupertinoButton(
          onPressed: () {
            controller.startSwitch();
            onClick();
          },
          minSize: 0,
          padding: EdgeInsets.zero,
          child: AnimatedRotation(
            turns: controller.turns.value,
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
  final turns = 0.0.obs;

  void startSwitch({value = 0.5}) {
    turns.value = turns.value == 0 ? value : 0;
  }
}
