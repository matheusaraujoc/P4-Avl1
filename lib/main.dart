import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // Importando para inicializar o locale
import 'package:shared_preferences/shared_preferences.dart'; // Importando SharedPreferences
import 'tela_lista_tarefas.dart';

Future<void> inicializarCategorias() async {
  final prefs = await SharedPreferences.getInstance();
  List<String> savedCategorias = prefs.getStringList('categorias') ?? [];

  // Verificar se é a primeira vez ou se não há categorias
  if (savedCategorias.isEmpty) {
    savedCategorias = ['Trabalho', 'Pessoal', 'Lista de Desejos'];
    await prefs.setStringList('categorias', savedCategorias);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting(
      'pt_BR', null); // Inicializando o locale para 'pt_BR'

  // Verificar se é a primeira vez que o app é aberto
  final prefs = await SharedPreferences.getInstance();
  final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

  // Inicializa as categorias apenas na primeira vez
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
      theme: ThemeData(primarySwatch: Colors.purple),
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              "Vamos começar!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Image.asset(
              'assets/images/iniciar_image.png', // Caminho para a imagem
              height: 270, // Ajuste da altura da imagem
            ),
            SizedBox(height: 40), // Espaço extra entre a imagem e o botão
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: ElevatedButton(
                onPressed: () async {
                  // Salvar que o app não é mais aberto pela primeira vez
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isFirstTime', false);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => TelaListaTarefas()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(180, 50), // Largura de 180 e altura de 50
                  textStyle: TextStyle(fontSize: 18), // Tamanho da fonte
                ),
                child: Text("INICIAR"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
