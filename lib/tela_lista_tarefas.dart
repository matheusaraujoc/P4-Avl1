import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tela_nova_tarefa.dart';
import 'tarefas_finalizadas.dart';
import 'dart:convert'; // Para converter objetos em JSON
import 'package:flutter/services.dart'; // Importar para usar SystemNavigator.pop()
import 'tela_categorias.dart'; // Importe a tela de Categorias

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

  // Carregar tarefas do SharedPreferences
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

  // Recarregar tarefas após retornar da tela de categorias
  Future<void> _recarregarTarefas() async {
    await _loadTarefas();
  }

  // Carregar tarefas finalizadas do SharedPreferences
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

  // Salvar tarefas no SharedPreferences
  Future<void> _saveTarefas() async {
    final prefs = await SharedPreferences.getInstance();
    final String tarefasJson = jsonEncode(tarefas);
    await prefs.setString('tarefas', tarefasJson);
  }

  // Salvar tarefas finalizadas no SharedPreferences
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

  void atualizarTarefa(int index, Map<String, dynamic> tarefaAtualizada) {
    setState(() {
      tarefas[index] = tarefaAtualizada;
    });
    _saveTarefas();
  }

  // Função para remover a tarefa finalizada
  void removerTarefa(Map<String, dynamic> tarefa) {
    setState(() {
      tarefasFinalizadas.remove(tarefa); // Remove a tarefa de finalizadas
    });
    _saveTarefasFinalizadas();
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
      tarefas.add(tarefa); // Adiciona a tarefa de volta às tarefas ativas
      tarefasFinalizadas.remove(tarefa); // Remove a tarefa das finalizadas
    });
    _saveTarefas();
    _saveTarefasFinalizadas();
  }

  void _mostrarDialogoDeEdicaoOuRemocao(int index) {
    showDialog(
      context: context,
      barrierDismissible: true, // Permite fechar o diálogo clicando fora
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Fundo transparente
          child: GestureDetector(
            onTap: () {}, // Impede que o fundo do diálogo feche
            child: Center(
              child: Material(
                color: Colors.transparent, // Fundo do Material transparente
                child: AlertDialog(
                  title: Text("O que você deseja fazer?"),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context); // Fecha o diálogo imediatamente
                        // Editar tarefa
                        final tarefaEditada = await Navigator.push(
                          context,
                          PageRouteBuilder(
                            opaque: false, // Faz o fundo transparente
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
                              return TelaNovaTarefa(tarefa: tarefas[index]);
                            },
                          ),
                        );

                        // Verificar se a tarefa foi editada e atualizar a lista
                        if (tarefaEditada != null) {
                          setState(() {
                            tarefas[index] =
                                tarefaEditada; // Atualiza a tarefa no índice
                          });
                          _saveTarefas();
                        }
                      },
                      child: Text("Editar"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Fecha o diálogo imediatamente
                        // Apagar tarefa
                        setState(() {
                          tarefas.removeAt(index); // Remove a tarefa
                        });
                        _saveTarefas();
                      },
                      child: Text("Apagar"),
                    ),
                  ],
                ),
              ),
            ),
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
        backgroundColor: const Color.fromARGB(255, 148, 132, 214),
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
                      removerTarefa: removerTarefa,
                    ),
                  ),
                );
              } else if (value == 'sair') {
                SystemNavigator.pop(); // Fecha o aplicativo
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
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dataAtual,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Aqui estão suas tarefas",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          Expanded(
            child: tarefas.isEmpty
                ? Center(child: Text("Nenhuma tarefa adicionada"))
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
                            color: const Color.fromARGB(255, 190, 174, 255),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: ListTile(
                            title: Text(
                              tarefa['titulo'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tarefa['descricao']),
                                SizedBox(height: 5),
                                Text(
                                  "Dias: ${tarefa['dias'].join(", ")}",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black54),
                                ),
                                Text(
                                  "Categoria: ${tarefa['categoria']}",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black54),
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
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(Icons.check_circle_outline),
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
        child: Icon(Icons.add),
        onPressed: () async {
          final novaTarefa = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (context) => TelaNovaTarefa(),
          );
          if (novaTarefa != null) adicionarTarefa(novaTarefa);
        },
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // Aqui está o ajuste
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Para indicar que estamos na tela de Tarefas
        onTap: (int index) async {
          if (index == 0) {
            // Mantém na tela de Tarefas
            return;
          } else if (index == 1) {
            // Navega para a tela de Categorias
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TelaCategorias(),
              ),
            );
            await _recarregarTarefas(); // Recarrega tarefas após voltar
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
