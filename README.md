Flutter 版本的省市区三级联动，此版本不包含街道数据。

## Features
名词解释 ：pca -> Province、City、Area 省市区

## Getting started

```dart
dependencies:
  address_picker_pca:
    git:
      url: "https://github.com/good-good-study/address_picker_pca.git"
```

## Usage

```dart
import 'package:address_picker_pca/address_picker_pca.dart';

Province? province;
City? city;
Area? area;

String? _address = '未选择地址';

/// 选择地址
void _onAddress() async {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return AddressPicker(
        provinceId: province?.id,
        cityId: city?.id,
        areaId: area?.id,
        onConfirm: (province, city, area) async {
          this.province = province;
          this.city = city;
          this.area = area;
          if (province != null && city != null) {
            var address = province.name + city.name + (area?.name ?? '');
            setState(() {
              _address = address;
            });
          }
        },
      );
    },
  );
}
```
