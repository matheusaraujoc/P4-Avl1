import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tela_lista_tarefas.dart';

Future<void> inicializarCategorias() async {
  final prefs = await SharedPreferences.getInstance();
  List<String> savedCategorias = prefs.getStringList('categorias') ?? [];

  if (savedCategorias.isEmpty) {
    savedCategorias = ['Trabalho', 'Pessoal', 'Lista de Desejos'];
    await prefs.setStringList('categorias', savedCategorias);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  final prefs = await SharedPreferences.getInstance();
  final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

  if (isFirstTime) {
    await inicializarCategorias();
  }

  runApp(AppDeTarefas(isFirstTime: isFirstTime));
}

class AppDeTarefas extends StatelessWidget {
  final bool isFirstTime;

  AppDeTarefas({required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Tarefas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: isFirstTime ? TelaBoasVindas() : TelaListaTarefas(),
    );
  }
}

class TelaBoasVindas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Bem-Vindo",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent),
            ),
            Text(
              "Vamos começar!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            Image.asset(
              'assets/images/iniciar_image.png',
              height: 270,
            ),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isFirstTime', false);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => TelaListaTarefas()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent, // Cor azul claro
                  fixedSize: Size(
                      180, 50), // Tamanho fixo para evitar redimensionamento
                  textStyle:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10), // Bordas arredondadas
                  ),
                ),
                child: Text("INICIAR", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
