import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/store_cubit.dart';
import 'data/product_repository.dart';
import 'screens/store_screen.dart';

void main() => runApp(
  BlocProvider(
    create: (_) => StoreCubit(ProductRepository())..load(),
    child: const GemStoreApp(),
  ),
);

class GemStoreApp extends StatelessWidget {
  const GemStoreApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'GemStore',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff444444)),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
    ),
    home: const StoreScreen(),
  );
}
