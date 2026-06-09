import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/log_controller.dart';
import 'log_viewer_page.dart';

class LogView extends GetView<LogController> {
  const LogView({super.key});
  @override
  Widget build(BuildContext context) {
    return LogViewerPage();
  }
}
