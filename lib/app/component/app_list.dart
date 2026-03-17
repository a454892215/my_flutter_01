import 'package:flutter/material.dart';
import 'package:flutter_comm/app/component/app_empty.dart';
import 'package:flutter_comm/util/loading_util.dart';
import 'package:flutter_comm/util/toast_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../http/dio_util.dart';

class AppList extends StatefulWidget {
  const AppList({
    super.key,
    required this.getList,
    required this.builder,
    this.params,
    this.noDataBuilder,
  });

  // getList 函数 ，返回 Future<dynamic>
  final Future<dynamic> Function({Map<String, Object>? params}) getList;
  final Widget Function(dynamic item, int index) builder;
  final Map<String, Object>? params;
  final Function? noDataBuilder;

  @override
  State<AppList> createState() => _AppListState();
}

class _AppListState extends State<AppList> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  // 总数
  int _t = 0;

  // page
  int _page = 1;

  // 每页条数
  int _page_size = 20;

  bool isFetching = false;

  // 当前页数据
  List<Map<String, dynamic>> _d = [];

  // 页面数据
  final List<dynamic> _data = [];

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  _getData() async {
    try {
      isFetching = true;
      AppLoading.show();
      final data = await widget
          .getList(params: {"page": _page, "page_size": _page_size, ...widget.params ?? {}});
      print('_第 $_page 页');
      if (_page == 1) {
        _t = data['t'] ?? 0;
      }

      if (_page == 1 && _t == 0) {

        if (widget.noDataBuilder != null) {
          widget.noDataBuilder!();
        }

        _refreshController.loadNoData();
        return;
      }
      _data.addAll(data['d'] ?? []);
      if (_data.length >= _t) {
        _refreshController.loadNoData();
      } else {
        _refreshController.loadComplete();
      }

      setState(() {});
    } catch (e) {
      print('AppList Error: $e');
    } finally {
      isFetching = false;
      AppLoading.close();
    }
  }

  // 监听params变化,重新请求数据
  @override
  void didUpdateWidget(covariant AppList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.params != widget.params) {
      _onRefresh();
    }
  }

  void _onRefresh() async {
    // monitor network fetch
    if (isFetching) {
      return;
    }
    _page = 1;
    _data.clear();
    _refreshController.resetNoData();
    _refreshController.refreshCompleted();
    _getData();
  }

  void _onLoading() async {
    // monitor network fetch
    if (isFetching) {
      return;
    }
    _page++;
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      header: CustomHeader(
        builder: (BuildContext context, RefreshStatus? mode) {
          Widget body;
          if (mode == RefreshStatus.idle) {
            body = const Text("Puxe para baixo para atualizar");
          } else if (mode == RefreshStatus.refreshing) {
            body = const CircularProgressIndicator(
              color: Color.fromRGBO(14, 209, 244, 1),
            );
          } else if (mode == RefreshStatus.failed) {
            body = const Text("Falha na atualização! Clique para tentar novamente!");
          } else if (mode == RefreshStatus.canRefresh) {
            body = const Text("Deixe ir, atualize!");
          } else {
            body = const Text("atualização completa");
          }
          return SizedBox(
            height: 55.0,
            child: DefaultTextStyle(
              style: TextStyle(
                fontSize: 25.w,
                color: Colors.white,
              ),
              child: Center(child: body),
            ),
          );
        },
      ),
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = const Text("puxe a carga");
          } else if (mode == LoadStatus.loading) {
            body = const CircularProgressIndicator(
              color: Color.fromRGBO(14, 209, 244, 1),
            );
          } else if (mode == LoadStatus.failed) {
            body = const Text("Falha ao carregar! Clique para tentar novamente!");
          } else if (mode == LoadStatus.canLoading) {
            body = const Text("Solte, carregue mais!");
          } else {
            body = _data.isEmpty  ? const SizedBox() : const Text("Não Mais");
          }
          return SizedBox(
            height: 55.0,
            child: DefaultTextStyle(
              style: TextStyle(
                fontSize: 25.w,
                color: Colors.white,
              ),
              child: Center(child: body),
            ),
          );
        },
      ),
      child: _data.isEmpty
          ? Padding(
            padding: EdgeInsets.symmetric(vertical: 150.w),
            child: const AppEmpty(),
          )
          : ListView.builder(
              itemCount: _data.length,
              itemBuilder: (BuildContext context, int index) {
                return widget.builder(_data[index], index);
              },
            ),
    );
  }
}
