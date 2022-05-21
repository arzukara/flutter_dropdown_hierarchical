import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

List<Map<String, dynamic>> agag = [];

List<Map<String, dynamic>> flat = [
  {"id": 1, "parentId": 3, "name": "id1-parent3"},
  {"id": 3, "parentId": 8, "name": "id3-parent8"},
  {"id": 6, "parentId": 3, "name": "id6-parent3"},
  {"id": 8, "parentId": 0, "name": "id8"},
  {"id": 10, "parentId": 8, "name": "id10-parent8"},
  {"id": 14, "parentId": 10, "name": "id14-parent10"},
  {"id": 15, "parentId": 0, "name": "id15"},
  {"id": 16, "parentId": 15, "name": "id16-parent15"}
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multiselect Hierarchical Dropdown',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const MyHomePage(title: 'Multiselect Hierarchical Dropdown'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Map<String, dynamic> treeOrder(List<Map<String, dynamic>> nodes) {
  Map<String, dynamic> result = {};

  var map = <int, Map<String, dynamic>>{};
  for (var node in nodes) {
    map[node["id"]] = node;
    node["children"] = [];
  }

  for (var node in nodes) {
    var parentId = node.remove("parentId");
    if (parentId == 0) {
      result = node;
      agag.add(node);
    } else {
      map[parentId]!["children"].add(node);
    }
  }

  return result;
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _selectedItems = [];

  void _showMultiSelect(agag) async {
    final List<String>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(agag);
      },
    );

    // Update UI
    if (results != null) {
      setState(() {
        _selectedItems = results;
      });
    }
  }

  Map<String, dynamic> result = treeOrder(flat);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text('Select Your Favorite Topics'),
          onPressed: () => _showMultiSelect(agag),
        ),
      ),
    );
  }
}

class MultiSelect extends StatefulWidget {
  List<Map<String, dynamic>> agag;
  MultiSelect(this.agag, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  final List<String> _selectedItems = [];

  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedItems.add(itemValue);
      } else {
        _selectedItems.remove(itemValue);
      }
    });
  }

  void _cancel() {
    Navigator.pop(context);
  }

  void _submit() {
    Navigator.pop(context, _selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Topics'),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.agag.map((item) {
            return Column(
              children: [
                CheckboxListTile(
                  value: _selectedItems.contains(item["name"]),
                  contentPadding: EdgeInsets.all(0),
                  visualDensity: VisualDensity.compact,
                  title: Transform.translate(
                    offset: Offset(-20, 0),
                    child: Text(item["name"]),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (isChecked) => _itemChange(item["name"], isChecked!),
                ),
                if (item["children"] != [])
                  ListBody(
                    children: item["children"].map<Widget>((item) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 25),
                            child: CheckboxListTile(
                              value: _selectedItems.contains(item["name"]),
                              contentPadding: EdgeInsets.all(0),
                              visualDensity: VisualDensity.compact,
                              title: Transform.translate(
                                offset: Offset(-20, 0),
                                child: Text(item["name"]),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              onChanged: (isChecked) => _itemChange(item["name"], isChecked!),
                            ),
                          ),
                          if (item["children"] != [])
                            ListBody(
                              children: item["children"].map<Widget>((item) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 45),
                                  child: CheckboxListTile(
                                    value: _selectedItems.contains(item["name"]),
                                    contentPadding: EdgeInsets.all(0),
                                    visualDensity: VisualDensity.compact,
                                    title: Transform.translate(
                                      offset: Offset(-20, 0),
                                      child: Text(item["name"]),
                                    ),
                                    controlAffinity: ListTileControlAffinity.leading,
                                    onChanged: (isChecked) => _itemChange(item["name"], isChecked!),
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: _cancel,
        ),
        ElevatedButton(
          child: const Text('Submit'),
          onPressed: _submit,
        ),
      ],
    );
  }
}
