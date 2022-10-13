import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sirkl/common/language.dart';
import 'package:sirkl/common/model/db/collection_dto.dart';
import 'package:sirkl/home/controller/home_controller.dart';

import 'navigation/ui/navigation_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ListOfCollectionDbDtoAdapter());
  Hive.registerAdapter(CollectionDbDtoAdapter());
  await Hive.openBox("collections");
  await Firebase.initializeApp();
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: Language(),
      locale: const Locale('en'),
      darkTheme: ThemeData(brightness: Brightness.dark, dividerColor: Colors.transparent),
      themeMode: ThemeMode.system,
      theme: ThemeData(brightness: Brightness.light, dividerColor: Colors.transparent),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final _homeController = Get.put(HomeController());

  @override
  void initState() {
    _homeController.retrieveAccessToken();
    if(_homeController.accessToken.value.isNotEmpty) _homeController.putFCMToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const NavigationScreen();
  }
}
