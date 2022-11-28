import 'city.dart';

/// 省/直辖市、特别行政区）
class Province implements Comparable<Province> {
  /// 名称
  final String name;

  /// 代码
  final String id;

  /// 城市
  final List<City>? children;

  const Province({
    required this.name,
    required this.id,
    this.children,
  });

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      name: json["name"].toString(),
      id: json["id"].toString(),
      children:
          (json["children"] as List<dynamic>?)?.map((e) => City.fromJson(e)).toList(),
    );
  }

  @override
  int compareTo(Province other) => id.compareTo(other.id);
}
