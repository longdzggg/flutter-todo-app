// lib/main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/hive_data_store.dart';
import 'models/task.dart';
import 'view/home/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>(HiveDataStore.boxName);

  runApp(BaseWidget(child: const MyApp())); // ← const MyApp() vẫn OK
}

// SỬA: XÓA 'const' ở constructor
class BaseWidget extends InheritedWidget {
  BaseWidget({Key? key, required Widget child}) : super(key: key, child: child);

  final dataStore = HiveDataStore(); // ← runtime object → không const

  static BaseWidget of(BuildContext context) {
    final base = context.dependOnInheritedWidgetOfExactType<BaseWidget>();
    if (base != null) {
      return base;
    } else {
      throw StateError('Could not find ancestor widget of type BaseWidget');
    }
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); //
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Hive Todo',
      theme: ThemeData(
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontSize: 45, fontWeight: FontWeight.bold, color: Colors.black),
          titleMedium: TextStyle(fontSize: 16, color: Colors.grey),
          headlineMedium: TextStyle(fontSize: 21, color: Colors.white),
          titleSmall: TextStyle(
              fontSize: 14, color: Color.fromARGB(255, 234, 234, 234)),
          titleLarge: TextStyle(fontSize: 17, color: Colors.grey),
          displayMedium: TextStyle(
              fontSize: 40, fontWeight: FontWeight.w300, color: Colors.black),
        ),
      ),
      home: const HomeView(),
    );
  }
}
