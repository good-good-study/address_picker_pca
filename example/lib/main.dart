import 'package:address_picker_pca/address_picker_pca.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '地址选择器',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        backgroundColor: Colors.white,
      ),
      home: const MyHomePage(title: '地址选择器'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ///
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
          province: province,
          city: city,
          area: area,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            '$_address',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddress,
        tooltip: '选择地址',
        child: const Icon(Icons.location_on),
      ),
    );
  }
}
