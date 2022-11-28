/// 城市-下属区
class Area implements Comparable<Area> {
  /// 区
  final String name;

  /// 代码
  final String id;

  const Area({required this.name, required this.id});

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      name: json["name"] as String,
      id: json["id"] as String,
    );
  }

  @override
  int compareTo(Area other) => id.compareTo(other.id);
}
