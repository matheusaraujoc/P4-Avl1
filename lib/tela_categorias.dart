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
    // Remove categorias selecionadas da lista de categorias
    categorias
        .removeWhere((categoria) => categoriasSelecionadas.contains(categoria));
    await prefs.setStringList('categorias', categorias);

    // Remover tarefas associadas às categorias selecionadas
    await _removerTarefasPorCategoriasSelecionadas();

    setState(() {
      categoriasSelecionadas.clear();
      emModoDeExclusao = false;
    });
  }

  Future<void> _removerTarefasPorCategoriasSelecionadas() async {
    // Carregar tarefas do SharedPreferences
    final String? tarefasJson = prefs.getString('tarefas');
    if (tarefasJson != null) {
      final List<dynamic> tarefasList = jsonDecode(tarefasJson);
      // Filtrar para manter apenas tarefas que não estão nas categorias selecionadas
      final List<Map<String, dynamic>> tarefasFiltradas = tarefasList
          .map((tarefa) => Map<String, dynamic>.from(tarefa))
          .where(
              (tarefa) => !categoriasSelecionadas.contains(tarefa['categoria']))
          .toList();

      // Salvar tarefas filtradas de volta no SharedPreferences
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
          title: Text("Nova Categoria"),
          content: TextField(
            controller: _categoriaController,
            decoration: InputDecoration(hintText: 'Digite o nome da categoria'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                String categoria = _categoriaController.text.trim();
                if (categoria.isNotEmpty) {
                  _adicionarCategoria(categoria);
                  Navigator.pop(context);
                }
              },
              child: Text("Adicionar"),
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
        backgroundColor: const Color.fromARGB(255, 148, 132, 214),
        automaticallyImplyLeading: false,
        actions: [
          if (emModoDeExclusao)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _removerCategorias,
            ),
          if (!emModoDeExclusao)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _alternarModoExclusao,
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
            ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _mostrarDialogNovaCategoria,
          ),
        ],
      ),
      body: categorias.isEmpty
          ? Center(child: Text("Nenhuma categoria disponível"))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: categorias.length,
              itemBuilder: (context, index) {
                final categoria = categorias[index];
                return Card(
                  color: const Color.fromARGB(255, 190, 174, 255),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(categoria),
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
                            builder: (context) => TelaCategoriaTarefas(
                              categoria: categoria,
                            ),
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
                          )
                        : null,
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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
