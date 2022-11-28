import 'area.dart';

/// 城市
class City implements Comparable<City> {
  /// 市
  final String name;

  /// 代码
  final String id;

  /// 城市
  final List<Area>? children;

  const City({required this.name, required this.id, this.children});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json["name"] as String,
      id: json["id"] as String,
      children:
          (json["children"] as List<dynamic>?)?.map((e) => Area.fromJson(e)).toList(),
    );
  }

  @override
  int compareTo(City other) => id.compareTo(other.id);
}
