import 'dart:convert';

import 'package:flutter/services.dart';

import 'area.dart';
import 'city.dart';
import 'province.dart';

typedef Transform<T> = T Function(Map<String, dynamic> json);

const name = 'packages/address_picker_pca';

///将[dynamic]转换成指定对象[T]
Future<T> transform<T>({
  Map<String, dynamic>? json,
  required Transform<T> transform,
}) async {
  return transform(json ?? <String, dynamic>{});
}

///将[Map]<[String],[dynamic]>转换成指定类型的数组[List]<[T]>
Future<List<T>> transformList<T>({
  List<dynamic>? json,
  required Transform<T> transform,
}) async {
  return (json ?? <T>[]).map((json) => transform(json)).toList();
}

/// 获取省份列表
Future<List<Province>?> loadProvinces() async {
  var json = await rootBundle.loadString('$name/json/address.json');
  var provinces = await transformList(
    json: jsonDecode(json),
    transform: (json) => Province.fromJson(json),
  );
  return provinces;
}

/// 获取城市列表
Future<List<City>?> loadCities(List<Province>? provinces, String provinceId) async {
  if (provinces?.isEmpty ?? true) return null;
  return provinces?.lastWhere((e) => e.id == provinceId).children;
}

/// 获取区列表
Future<List<Area>?> loadAreas(Province? province, String cityId) async {
  if (province?.children?.isEmpty ?? true) return null;
  return province?.children?.lastWhere((e) => e.id == cityId).children;
}
