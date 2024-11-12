import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tela_nova_tarefa.dart';
import 'tarefas_finalizadas.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'tela_categorias.dart';

class TelaListaTarefas extends StatefulWidget {
  @override
  _TelaListaTarefasState createState() => _TelaListaTarefasState();
}

class _TelaListaTarefasState extends State<TelaListaTarefas> {
  List<Map<String, dynamic>> tarefas = [];
  List<Map<String, dynamic>> tarefasFinalizadas = [];

  @override
  void initState() {
    super.initState();
    _loadTarefas();
    _loadTarefasFinalizadas();
  }

  Future<void> _loadTarefas() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tarefasJson = prefs.getString('tarefas');
    if (tarefasJson != null) {
      final List<dynamic> tarefasList = jsonDecode(tarefasJson);
      setState(() {
        tarefas = tarefasList
            .map((tarefa) => Map<String, dynamic>.from(tarefa))
            .toList();
      });
    }
  }

  Future<void> _loadTarefasFinalizadas() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tarefasFinalizadasJson =
        prefs.getString('tarefasFinalizadas');
    if (tarefasFinalizadasJson != null) {
      final List<dynamic> tarefasList = jsonDecode(tarefasFinalizadasJson);
      setState(() {
        tarefasFinalizadas = tarefasList
            .map((tarefa) => Map<String, dynamic>.from(tarefa))
            .toList();
      });
    }
  }

  Future<void> _saveTarefas() async {
    final prefs = await SharedPreferences.getInstance();
    final String tarefasJson = jsonEncode(tarefas);
    await prefs.setString('tarefas', tarefasJson);
  }

  Future<void> _saveTarefasFinalizadas() async {
    final prefs = await SharedPreferences.getInstance();
    final String tarefasFinalizadasJson = jsonEncode(tarefasFinalizadas);
    await prefs.setString('tarefasFinalizadas', tarefasFinalizadasJson);
  }

  void adicionarTarefa(Map<String, dynamic> tarefa) {
    setState(() {
      tarefas.add(tarefa);
    });
    _saveTarefas();
  }

  void finalizarTarefa(int index) {
    setState(() {
      tarefasFinalizadas.add(tarefas[index]);
      tarefas.removeAt(index);
    });
    _saveTarefas();
    _saveTarefasFinalizadas();
  }

  void restaurarTarefa(Map<String, dynamic> tarefa) {
    setState(() {
      tarefas.add(tarefa);
      tarefasFinalizadas.remove(tarefa);
    });
    _saveTarefas();
    _saveTarefasFinalizadas();
  }

  void _mostrarDialogoDeEdicaoOuRemocao(int index) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Remove o fundo branco extra
          child: AlertDialog(
            backgroundColor: Colors
                .white, // Mantém o fundo branco apenas do próprio AlertDialog
            title: Text(
              "O que você deseja fazer?",
              style: TextStyle(color: Colors.lightBlueAccent),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final tarefaEditada = await Navigator.push(
                    context,
                    PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return TelaNovaTarefa(tarefa: tarefas[index]);
                      },
                    ),
                  );
                  if (tarefaEditada != null) {
                    setState(() {
                      tarefas[index] = tarefaEditada;
                    });
                    _saveTarefas();
                  }
                },
                child: Text("Editar",
                    style: TextStyle(color: Colors.lightBlueAccent)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    tarefas.removeAt(index);
                  });
                  _saveTarefas();
                },
                child:
                    Text("Apagar", style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String dataAtual = DateFormat('EEEE, d \'de\' MMMM \'de\' y', 'pt_BR')
        .format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'finalizadas') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TarefasFinalizadas(
                      tarefas: tarefas,
                      tarefasFinalizadas: tarefasFinalizadas,
                      restaurarTarefa: restaurarTarefa,
                      removerTarefa: (tarefa) {
                        setState(() {
                          tarefasFinalizadas.remove(tarefa);
                        });
                        _saveTarefasFinalizadas();
                      },
                    ),
                  ),
                );
              } else if (value == 'sair') {
                SystemNavigator.pop();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'finalizadas',
                child: Text('Tarefas Finalizadas'),
              ),
              PopupMenuItem(
                value: 'sair',
                child: Text('Sair'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dataAtual,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlueAccent,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Aqui estão suas tarefas",
                  style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                ),
              ],
            ),
          ),
          Expanded(
            child: tarefas.isEmpty
                ? Center(
                    child: Text("Nenhuma tarefa adicionada",
                        style: TextStyle(color: Colors.blueGrey)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    itemCount: tarefas.length,
                    itemBuilder: (context, index) {
                      final tarefa = tarefas[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.lightBlue[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.lightBlueAccent),
                          ),
                          child: ListTile(
                            title: Text(
                              tarefa['titulo'],
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightBlueAccent),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tarefa['descricao'],
                                    style: TextStyle(color: Colors.blueGrey)),
                                SizedBox(height: 5),
                                Text(
                                  "Dias: ${tarefa['dias'].join(", ")}",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.blueGrey),
                                ),
                                Text(
                                  "Categoria: ${tarefa['categoria']}",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.blueGrey),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  tarefa['horario'] ?? '',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.lightBlueAccent),
                                ),
                                SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(Icons.check_circle_outline,
                                      color: Colors.lightBlueAccent),
                                  onPressed: () {
                                    finalizarTarefa(index);
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              _mostrarDialogoDeEdicaoOuRemocao(index);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SizedBox(height: 16),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlueAccent,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final novaTarefa = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (context) => TelaNovaTarefa(),
          );
          if (novaTarefa != null) adicionarTarefa(novaTarefa);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (int index) async {
          if (index == 1) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TelaCategorias(),
              ),
            );
            await _loadTarefas();
          }
        },
        backgroundColor: Colors.white,
        selectedItemColor: Colors.lightBlueAccent,
        unselectedItemColor: Colors.blueGrey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box),
            label: 'Tarefas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categorias',
          ),
        ],
      ),
    );
  }
}
