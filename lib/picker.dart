import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'area.dart';
import 'city.dart';
import 'model.dart';
import 'province.dart';

const _kSmallDuration = Duration(milliseconds: 100);
const _kDuration = Duration(milliseconds: 200);

/// 省、市、区 选择器
class AddressPicker extends StatefulWidget {
  final String? provinceId;
  final String? cityId;
  final String? areaId;
  final WidgetBuilder? loadingBuilder;
  final String title;
  final TextStyle? textStyle;
  final TextStyle? unSelectTextStyle;
  final BorderRadius? borderRadius;
  final Function(Province? province, City? city, Area? area)? onConfirm;

  const AddressPicker({
    Key? key,
    this.onConfirm,
    this.provinceId,
    this.cityId,
    this.areaId,
    this.loadingBuilder,
    this.borderRadius,
    this.title = '选择地区',
    this.textStyle,
    this.unSelectTextStyle,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddressPickerState();
}

class _AddressPickerState extends State<AddressPicker> {
  ///
  bool isLoading = true;
  bool showProvince = false, showCity = false, showArea = false;

  var tabIndex = 0;

  List<Province>? provinces;
  List<City>? cities;
  List<Area>? areas;

  Province? _province;
  City? _city;
  Area? _area;

  int initialIndexP = 0;
  int initialIndexC = 0;
  int initialIndexA = 0;
  int initialIndexS = 0;

  ///
  final provinceController = ItemScrollController();
  final cityController = ItemScrollController();
  final areaController = ItemScrollController();
  final selectionController = ScrollController();

  /// 是否显示预设地址
  bool get isFindIndex =>
      widget.provinceId != null ||
      (widget.provinceId != null && widget.cityId != null) ||
      (widget.provinceId != null && widget.cityId != null && widget.areaId != null);

  /// 将地址信息返回
  void _onConfirm() async {
    Navigator.pop(context);
    if (_province == null || _city == null) return;
    widget.onConfirm?.call(_province, _city, _area);
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    super.dispose();
    selectionController.dispose();
  }

  /// 初始化时获取省份
  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // _province = widget.province;
    // _city = widget.city;
    // _area = widget.area;

    // 省
    provinces = provinces ?? await loadProvinces();
    showProvince = provinces?.isNotEmpty ?? false;

    int pIndex = -1, cIndex = -1, aIndex = -1;

    if (isFindIndex) {
      pIndex = provinces?.indexWhere((e) => e.id == widget.provinceId) ?? -1;
      if (pIndex != -1) {
        initialIndexP = pIndex;
        _province = provinces![pIndex];
      }

      // 市
      if (_province != null) {
        var cities = await loadCities(provinces, _province!.id);
        cIndex = cities?.indexWhere((e) => e.id == widget.cityId) ?? -1;
        if (cIndex != -1) {
          this.cities = cities;
          initialIndexC = cIndex;
          _city = cities![cIndex];
        }

        // 区
        if (_city != null) {
          var areas = await loadAreas(_province, _city?.id ?? '');
          aIndex = areas?.indexWhere((e) => e.id == widget.areaId) ?? -1;
          if (aIndex != -1) {
            this.areas = areas;
            initialIndexA = aIndex;
            _area = areas![aIndex];
            _onAreaChanged(aIndex);
          } else if (cIndex != -1) {
            _onCityChanged(cIndex);
          }
        }
      }

      if (!mounted) return;
      isLoading = false;
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      if (pIndex != -1) {
        provinceController.scrollTo(index: pIndex, duration: _kDuration);
      }
      if (cIndex != -1) {
        cityController.scrollTo(index: cIndex, duration: _kDuration);
      }
      if (aIndex != -1) {
        areaController.scrollTo(index: aIndex, duration: _kDuration);
      }

      if (kDebugMode) {
        print('init: pIndex:$pIndex, cIndex:$cIndex, aIndex:$aIndex');
      }

      await Future.delayed(_kDuration * 2);
      if (!mounted) return;
      setState(() {});
      return;
    }

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  /// 省份选择
  void _onProvinceChanged(int index) async {
    _province = provinces![index];
    if (kDebugMode) {
      print('_onProvinceChanged ${_province?.name}');
    }
    tabIndex = 1;
    areas?.clear();
    _city = null;
    _area = null;
    showCity = true;
    showArea = false;
    isLoading = true;

    // 获取对应的城市
    await Future.delayed(_kSmallDuration);
    if (!mounted) return;
    cities = await loadCities(provinces, _province!.id);
    isLoading = false;
    setState(() {});
  }

  /// 城市选择
  void _onCityChanged(int index) async {
    _city = cities![index];
    if (kDebugMode) {
      print('_onCityChanged ${_city?.name}');
    }
    if (_city?.children?.isEmpty ?? true) {
      tabIndex = 1;
      showCity = true;
      setState(() {});
      return;
    }
    tabIndex = 2;
    _area = null;
    showCity = true;
    showArea = true;
    isLoading = true;

    // 获取对应的区
    await Future.delayed(_kSmallDuration);
    if (!mounted) return;
    areas = await loadAreas(_province, _city!.id);
    isLoading = false;
    setState(() {});

    if (kDebugMode) {
      print('areas ${areas?.length}');
    }
  }

  /// 区域选择
  void _onAreaChanged(int index) async {
    _area = areas![index];
    if (kDebugMode) {
      print('_onAreaChanged ${_area?.name}');
    }
    tabIndex = 2;
    showCity = true;
    showArea = true;
    isLoading = true;
    setState(() {});

    await Future.delayed(_kDuration);
    if (!mounted) return;
    isLoading = false;
    setState(() {});
    _animatedToEnd();
  }

  /// 将选择地址信息滑动到最右端
  void _animatedToEnd() async {
    await Future.delayed(_kSmallDuration);
    if (!mounted) return;
    selectionController.animateTo(
      selectionController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastLinearToSlowEaseIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).backgroundColor,
      borderRadius: widget.borderRadius ??
          const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///
            Title(
              title: widget.title,
              textStyle: widget.textStyle,
              onConfirm: _onConfirm,
            ),

            /// 已选择地址信息
            Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: selectionController,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (showProvince)
                        TitleButton(
                          text: _province?.name,
                          select: tabIndex == 0,
                          textStyle: widget.textStyle,
                          unSelectTextStyle: widget.unSelectTextStyle,
                          onTap: () => setState(() => tabIndex = 0),
                        ),
                      if (showCity)
                        TitleButton(
                          text: _city?.name,
                          select: tabIndex == 1,
                          textStyle: widget.textStyle,
                          unSelectTextStyle: widget.unSelectTextStyle,
                          onTap: () => setState(() => tabIndex = 1),
                        ),
                      if (showArea)
                        TitleButton(
                          text: _area?.name,
                          select: tabIndex == 2,
                          textStyle: widget.textStyle,
                          unSelectTextStyle: widget.unSelectTextStyle,
                          onTap: () => setState(() => tabIndex = 2),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            ///
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  IndexedStack(
                    index: tabIndex,
                    children: [
                      /// 省
                      ScrollablePositionedList.builder(
                        physics: const ClampingScrollPhysics(),
                        itemScrollController: provinceController,
                        itemPositionsListener: ItemPositionsListener.create(),
                        initialScrollIndex: initialIndexP,
                        itemCount: provinces?.length ?? 0,
                        itemBuilder: (_, index) => _ItemView(
                          label: provinces![index].name,
                          select: provinces![index].name == _province?.name,
                          onItem: () => _onProvinceChanged(index),
                          textStyle: widget.textStyle,
                          unSelectTextStyle: widget.unSelectTextStyle,
                        ),
                      ),

                      /// 市
                      ScrollablePositionedList.builder(
                        physics: const ClampingScrollPhysics(),
                        itemScrollController: cityController,
                        itemPositionsListener: ItemPositionsListener.create(),
                        initialScrollIndex: initialIndexC,
                        itemCount: cities?.length ?? 0,
                        itemBuilder: (_, index) => _ItemView(
                          label: cities![index].name,
                          select: cities![index].name == _city?.name,
                          onItem: () => _onCityChanged(index),
                          textStyle: widget.textStyle,
                          unSelectTextStyle: widget.unSelectTextStyle,
                        ),
                      ),

                      /// 区
                      ScrollablePositionedList.builder(
                        physics: const ClampingScrollPhysics(),
                        itemScrollController: areaController,
                        itemPositionsListener: ItemPositionsListener.create(),
                        initialScrollIndex: initialIndexA,
                        itemCount: areas?.length ?? 0,
                        itemBuilder: (_, index) => _ItemView(
                          label: areas![index].name,
                          select: areas![index].name == _area?.name,
                          onItem: () => _onAreaChanged(index),
                          textStyle: widget.textStyle,
                          unSelectTextStyle: widget.unSelectTextStyle,
                        ),
                      ),
                    ],
                  ),

                  /// Loading
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isLoading
                        ? widget.loadingBuilder?.call(context)
                        : const SizedBox(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 选择的信息
class TitleButton extends StatelessWidget {
  final String? text;
  final bool select;
  final VoidCallback? onTap;
  final TextStyle? textStyle;
  final TextStyle? unSelectTextStyle;

  const TitleButton({
    Key? key,
    required this.text,
    this.select = false,
    this.onTap,
    this.textStyle,
    this.unSelectTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: ButtonStyle(
        padding: MaterialStateProperty.resolveWith(
          (states) => const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
      ),
      child: Text(
        text ?? '请选择',
        style: select
            ? textStyle ??
                TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                )
            : unSelectTextStyle ??
                TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyText1?.color,
                ),
      ),
    );
  }
}

///标题栏
class Title extends StatelessWidget {
  final String? title;
  final TextStyle? textStyle;

  ///
  final VoidCallback? onConfirm;

  const Title({Key? key, this.title, this.textStyle, this.onConfirm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '取消',
              style: textStyle ??
                  Theme.of(context)
                      .textTheme
                      .subtitle2
                      ?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            title ?? '选择地区',
            style: textStyle ??
                Theme.of(context)
                    .textTheme
                    .subtitle2
                    ?.copyWith(fontWeight: FontWeight.w500),
          ),
          TextButton(
            onPressed: onConfirm,
            child: Text(
              '确定',
              style: textStyle ??
                  Theme.of(context)
                      .textTheme
                      .subtitle2
                      ?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

/// Item
class _ItemView extends StatelessWidget {
  final String label;
  final bool select;
  final VoidCallback? onItem;
  final TextStyle? textStyle;
  final TextStyle? unSelectTextStyle;

  const _ItemView({
    Key? key,
    required this.label,
    this.select = false,
    this.onItem,
    this.textStyle,
    this.unSelectTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onItem,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Text(
          label,
          style: select
              ? textStyle ??
                  TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).primaryColor,
                  )
              : unSelectTextStyle ??
                  TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context).textTheme.bodyText1?.color,
                  ),
        ),
      ),
    );
  }
}
