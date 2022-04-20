import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(
    //4. wrap with notifierProvider
    ChangeNotifierProvider(
      create: (_) => BreadCrumbProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(),
        routes: {
          '/new': (context) => const NewBreadCrumbWidget(),
        },
      ),
    ),
  );
}

// 1
class BreadCrumb {
  bool isActive;
  final String name;
  final String uuid;

  BreadCrumb({
    required this.isActive,
    required this.name,
  }) : uuid = const Uuid().v4();

  void activate() {
    isActive = true;
  }

  @override
  bool operator ==(covariant BreadCrumb other) => uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;

  String get title => name + (isActive ? ' > ' : '');
}

//2.
class BreadCrumbProvider extends ChangeNotifier {
  final List<BreadCrumb> _items = [];
  //read only version of a list
  UnmodifiableListView<BreadCrumb> get items => UnmodifiableListView(_items);

  void add(BreadCrumb breadCrumb) {
    for (final item in _items) {
      item.activate();
    }
    _items.add(breadCrumb);
    notifyListeners();
  }

  void reset() {
    _items.clear();
    notifyListeners();
  }
}

//3.
//with a callback
typedef OnBreadCrumbTapped = void Function(BreadCrumb);

class BreadCrumbsWidget extends StatelessWidget {
  final OnBreadCrumbTapped onTapped;
  final UnmodifiableListView<BreadCrumb> breadCrumbs;
  const BreadCrumbsWidget({
    Key? key,
    required this.breadCrumbs,
    required this.onTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: breadCrumbs.map(
        (breadCrumb) {
          return GestureDetector(
            onTap: () {
              onTapped(breadCrumb);
            },
            child: Text(
              breadCrumb.title,
              style: TextStyle(
                color: breadCrumb.isActive ? Colors.blue : Colors.black,
              ),
            ),
          );
        },
      ).toList(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Home Page'),
      ),
      body: Column(
        children: [
          Consumer<BreadCrumbProvider>(
            builder: (context, value, child) {
              return BreadCrumbsWidget(
                breadCrumbs: value.items,
                onTapped: (breadCrumb) {},
              );
            },
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                '/new',
              );
            },
            child: const Text("Add new bread crumb"),
          ),
          TextButton(
            onPressed: () {
              //read is just a snapshot, usualy for one way communication
              context.read<BreadCrumbProvider>().reset();
            },
            child: const Text("Reset"),
          ),
        ],
      ),
    );
  }
}

class NewBreadCrumbWidget extends StatefulWidget {
  const NewBreadCrumbWidget({Key? key}) : super(key: key);

  @override
  State<NewBreadCrumbWidget> createState() => _NewBreadCrumbWidgetState();
}

class _NewBreadCrumbWidgetState extends State<NewBreadCrumbWidget> {
  late final TextEditingController _controller;
  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add new Bread Crumb")),
      body: Column(children: [
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: "Enter a new bread crumb here...",
          ),
        ),
        TextButton(
          onPressed: () {
            final text = _controller.text;
            final breadCrumb = BreadCrumb(
              isActive: false,
              name: text,
            );
            context.read<BreadCrumbProvider>().add(breadCrumb);
            Navigator.of(context).pop();
          },
          child: const Text("Add"),
        ),
      ]),
    );
  }
}
