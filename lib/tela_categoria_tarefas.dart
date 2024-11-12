import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TelaCategoriaTarefas extends StatefulWidget {
  final String categoria;

  TelaCategoriaTarefas({required this.categoria});

  @override
  _TelaCategoriaTarefasState createState() => _TelaCategoriaTarefasState();
}

class _TelaCategoriaTarefasState extends State<TelaCategoriaTarefas> {
  List<Map<String, dynamic>> tarefas = [];

  @override
  void initState() {
    super.initState();
    _loadTarefasPorCategoria();
  }

  // Carregar tarefas por categoria
  Future<void> _loadTarefasPorCategoria() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tarefasJson = prefs.getString('tarefas');
    if (tarefasJson != null) {
      final List<dynamic> tarefasList = jsonDecode(tarefasJson);
      setState(() {
        tarefas = tarefasList
            .map((tarefa) => Map<String, dynamic>.from(tarefa))
            .toList()
            .where((tarefa) => tarefa['categoria'] == widget.categoria)
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tarefas - ${widget.categoria}"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: tarefas.isEmpty
          ? Center(
              child: Text(
                "Nenhuma tarefa encontrada para essa categoria",
                style: TextStyle(color: Colors.blueGrey),
              ),
            )
          : ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: tarefas.length,
              itemBuilder: (context, index) {
                final tarefa = tarefas[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blueAccent),
                    ),
                    child: ListTile(
                      title: Text(
                        tarefa['titulo'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tarefa['descricao'],
                            style: TextStyle(color: Colors.blue[600]),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Dias: ${tarefa['dias'].join(", ")}",
                            style:
                                TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                          Text(
                            "Categoria: ${tarefa['categoria']}",
                            style:
                                TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                      trailing: Text(
                        tarefa['horario'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
