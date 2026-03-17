import 'package:flutter/material.dart';
import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_pickers/style/picker_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BottomSheetUtil {

  static List<String> _getPickerData(List<Map<String, String>> data) {
    List<String> list = [];
    data.forEach((element) {
      list.add(element['label']!);
    });
    return list;
  }

  static String _getValue(int index, List<Map<String, String>> data) {
    return data[index]['value']!;
  }

  static void showBottomSheet(
      BuildContext context,
      {
        required List<Map<String, String>> data,
        required Function(String value, String label) ok,
        String? selectData,
      }
  ) {
    Pickers.showSinglePicker(context, data: _getPickerData(data),
        onConfirm: (dynamic label, int index) {
          ok(_getValue(index, data), label);
        },
        selectData: selectData ?? _getPickerData(data)[0],
        pickerStyle: PickerStyle(
          backgroundColor: const Color.fromRGBO(0, 10, 29, 1),
          pickerHeight: 500.w,
          pickerTitleHeight: 116.w,
          textColor: Colors.white,
          pickerItemHeight: 90.w,
          textSize: 32.w,
          itemOverlay: Container(
            decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: const Color.fromRGBO(255, 255, 255, 0.25), width: 1.w),
                  top: BorderSide(color: const Color.fromRGBO(255, 255, 255, 0.25), width: 1.w),
                )
            ),
          ),
          headDecoration: BoxDecoration(
            color: const Color.fromRGBO(0, 10, 29, 1),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.w),
              topRight: Radius.circular(20.w),
            ),
          ),
          cancelButton: Padding(
            padding: EdgeInsets.all(25.w),
            child: Text('Cancelar', style: TextStyle(
                fontSize: 28.w,
                color: const Color.fromRGBO(255, 255, 255, 0.7)
            )),
          ),
          commitButton: Padding(
            padding: EdgeInsets.all(25.w),
            child: Text('Confirme', style: TextStyle(
                fontSize: 28.w,
                color: const Color.fromRGBO(14, 209, 244, 1)
            )),
          ),
          title: Center(child: Text('Selecione a data', style: TextStyle(
              color: Colors.white,
              fontSize: 36.w,
              fontWeight: FontWeight.w700
          )
        )
      ),
    ));
  }
}
