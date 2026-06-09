import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_comm/util/Log.dart';
import 'package:logger/logger.dart';


class LogViewerPage extends StatefulWidget {
  const LogViewerPage({super.key});

  @override
  State<LogViewerPage> createState() => _LogViewerPageState();
}

class _LogViewerPageState extends State<LogViewerPage> {
  static const double _logFontSize = 10;
  static const Color _bgColor = Color(0xFF191A1C);
  static const Color _dividerColor = Color(0xFF636363);
  static const Color _timestampColor = Color(0xFF6B7280);
  static const Color _hintColor = Color(0xFF8B8F96);
  static const Color _inputBgColor = Color(0xFF25262A);
  static const Color _inputBorderColor = Color(0xFF3A3C40);
  static const Color _inputTextColor = Color(0xFFE5E7EB);

  final TextEditingController _filterController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _refreshTimer;
  String _filterText = '';

  @override
  void initState() {
    super.initState();
    _filterController.addListener(() {
      setState(() => _filterText = _filterController.text.trim());
    });
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _filterController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<LogItem> get _filteredLogs {
    final logs = Log.getLogList();
    if (_filterText.isEmpty) return logs;
    final keyword = _filterText.toLowerCase();
    return logs.where((item) => item.log.toLowerCase().contains(keyword)).toList();
  }

  Color _levelColor(Level level) {
    if (level == Level.error || level == Level.fatal) return const Color(0xFFFF6B6B);
    if (level == Level.warning) return const Color(0xFFFFB020);
    if (level == Level.info) return const Color(0xFF5B9BFF);
    if (level == Level.debug || level == Level.trace) return const Color(0xFF9CA3AF);
    return const Color(0xFFE5E7EB);
  }


  @override
  Widget build(BuildContext context) {
    final logs = _filteredLogs;
    return Scaffold(
      appBar: AppBar(
        title: const Text('日志', style: TextStyle(fontSize: 15, color: Color(0xFFE5E7EB))),
        backgroundColor: _bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFFE5E7EB)),
      ),
      body: ColoredBox(
        color: _bgColor,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: TextField(
                controller: _filterController,
                style: const TextStyle(fontSize: 12, color: _inputTextColor),
                cursorColor: _inputTextColor,
                decoration: InputDecoration(
                  hintText: '输入关键字过滤日志',
                  hintStyle: const TextStyle(fontSize: 12, color: _hintColor),
                  filled: true,
                  fillColor: _inputBgColor,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: _inputBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF5B9BFF)),
                  ),
                  suffixIcon: _filterText.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear, size: 18, color: _hintColor),
                          onPressed: _filterController.clear,
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '共 ${logs.length} 条',
                  style: const TextStyle(fontSize: 11, color: _hintColor),
                ),
              ),
            ),
            Expanded(
              child: logs.isEmpty
                  ? Center(
                      child: Text(
                        _filterText.isEmpty ? '暂无日志' : '无匹配日志',
                        style: const TextStyle(fontSize: 12, color: _hintColor),
                      ),
                    )
                  : ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      itemCount: logs.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 0.5,
                        thickness: 1,
                        color: _dividerColor,
                      ),
                      itemBuilder: (context, index) {
                        final item = logs[index];
                        return InkWell(
                          onLongPress: () {
                           ///TODO '${item.time ?? ''} ${item.log}'.trim().copyToClipboard(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: _logFontSize,
                                  fontFamily: 'monospace',
                                  height: 1.3,
                                ),
                                children: [
                                  TextSpan(
                                    text: '${item.time} ',
                                    style: const TextStyle(color: _timestampColor),
                                  ),
                                  TextSpan(
                                    text: item.log,
                                    style: TextStyle(color: _levelColor(item.level)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
