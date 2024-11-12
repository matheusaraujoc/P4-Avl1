import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'tela_categoria_tarefas.dart';

class TelaCategorias extends StatefulWidget {
  @override
  _TelaCategoriasState createState() => _TelaCategoriasState();
}

class _TelaCategoriasState extends State<TelaCategorias> {
  List<String> categorias = [];
  late SharedPreferences prefs;
  Set<String> categoriasSelecionadas = {};
  bool emModoDeExclusao = false;

  @override
  void initState() {
    super.initState();
    _loadCategorias();
  }

  Future<void> _loadCategorias() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      categorias = prefs.getStringList('categorias') ?? [];
    });
  }

  Future<void> _adicionarCategoria(String categoria) async {
    categorias.add(categoria);
    await prefs.setStringList('categorias', categorias);
    setState(() {});
  }

  Future<void> _removerCategorias() async {
    categorias
        .removeWhere((categoria) => categoriasSelecionadas.contains(categoria));
    await prefs.setStringList('categorias', categorias);
    await _removerTarefasPorCategoriasSelecionadas();
    setState(() {
      categoriasSelecionadas.clear();
      emModoDeExclusao = false;
    });
  }

  Future<void> _removerTarefasPorCategoriasSelecionadas() async {
    final String? tarefasJson = prefs.getString('tarefas');
    if (tarefasJson != null) {
      final List<dynamic> tarefasList = jsonDecode(tarefasJson);
      final List<Map<String, dynamic>> tarefasFiltradas = tarefasList
          .map((tarefa) => Map<String, dynamic>.from(tarefa))
          .where(
              (tarefa) => !categoriasSelecionadas.contains(tarefa['categoria']))
          .toList();
      await prefs.setString('tarefas', jsonEncode(tarefasFiltradas));
    }
  }

  void _alternarModoExclusao() {
    setState(() {
      emModoDeExclusao = !emModoDeExclusao;
      categoriasSelecionadas.clear();
    });
  }

  void _mostrarDialogNovaCategoria() {
    final TextEditingController _categoriaController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Nova Categoria",
              style: TextStyle(color: Colors.lightBlueAccent)),
          content: TextField(
            controller: _categoriaController,
            decoration: InputDecoration(hintText: 'Digite o nome da categoria'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  Text("Cancelar", style: TextStyle(color: Colors.redAccent)),
            ),
            TextButton(
              onPressed: () {
                String categoria = _categoriaController.text.trim();
                if (categoria.isNotEmpty) {
                  _adicionarCategoria(categoria);
                  Navigator.pop(context);
                }
              },
              child: Text("Adicionar",
                  style: TextStyle(color: Colors.lightBlueAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Categorias"),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          if (emModoDeExclusao)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _removerCategorias,
              color: Colors.redAccent,
            ),
          if (!emModoDeExclusao)
            IconButton(
              icon: Icon(Icons.delete_outline),
              onPressed: _alternarModoExclusao,
              color: Colors.white,
            ),
          if (emModoDeExclusao)
            IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  emModoDeExclusao = false;
                  categoriasSelecionadas.clear();
                });
              },
              color: Colors.redAccent,
            ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _mostrarDialogNovaCategoria,
            color: Colors.white,
          ),
        ],
      ),
      body: categorias.isEmpty
          ? Center(
              child: Text("Nenhuma categoria disponível",
                  style: TextStyle(color: Colors.lightBlueAccent)))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: categorias.length,
              itemBuilder: (context, index) {
                final categoria = categorias[index];
                return Card(
                  color: Colors.blue[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.blueAccent),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      categoria,
                      style: TextStyle(
                          color: Colors.blue[800], fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      if (emModoDeExclusao) {
                        setState(() {
                          if (categoriasSelecionadas.contains(categoria)) {
                            categoriasSelecionadas.remove(categoria);
                          } else {
                            categoriasSelecionadas.add(categoria);
                          }
                        });
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TelaCategoriaTarefas(categoria: categoria),
                          ),
                        );
                      }
                    },
                    trailing: emModoDeExclusao
                        ? Checkbox(
                            value: categoriasSelecionadas.contains(categoria),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  categoriasSelecionadas.add(categoria);
                                } else {
                                  categoriasSelecionadas.remove(categoria);
                                }
                              });
                            },
                            activeColor: Colors.lightBlueAccent,
                          )
                        : null,
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Colors.lightBlueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (int index) {
          if (index == 0) {
            Navigator.pop(context);
          } else if (index == 1) {
            return;
          }
        },
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
