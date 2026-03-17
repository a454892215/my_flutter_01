import 'package:flutter/cupertino.dart';
import 'package:flutter_comm/util/bottom_sheet_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class
AppSelect extends StatefulWidget {
  const AppSelect({
    super.key,
    this.width,
    this.height,
    this.value,
    required this.selectDataList,
    this.onChange
  });

  final double? width;
  final double? height;
  final String? value;
  final List<Map<String, String>> selectDataList;
  final void Function(String value)? onChange;

  @override
  State<AppSelect> createState() => _AppSelectState();
}

class _AppSelectState extends State<AppSelect> {

  late String _label;

  _setValue(String label) {
    setState(() {
      _label = label;
    });
  }

  _initLabel() {
    String v = widget.value ?? widget.selectDataList[0]['value']!;
    _label = widget.selectDataList.firstWhere((element) => element['value'] == v)['label']!;
  }

  @override
  void initState() {
    super.initState();
    _initLabel();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.all(0),
      minSize: 0,
      onPressed: () {
        BottomSheetUtil.showBottomSheet(
            context,
            data: widget.selectDataList,
            selectData: _label,
            ok: (String value, String label) {
              _setValue(label);
              if (widget.onChange != null) {
                widget.onChange!(value);
              }
            }
        );
      },
      child: Container(
        width: widget.width ?? 200.w,
        height: widget.height ?? 80.w,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.w),
          border: Border.all(color: const Color.fromRGBO(14, 209, 244, 1), width: 1.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_label, style: TextStyle(color: const Color.fromRGBO(14, 209, 244, 1), fontSize: 24.w)),
            SizedBox(width: 10.w),
            Image.asset('assets/images/down.webp', width: 25.w)
          ],
        )
      ),
    );
  }
}
