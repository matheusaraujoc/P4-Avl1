import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TelaNovaTarefa extends StatefulWidget {
  final Map<String, dynamic>? tarefa;

  TelaNovaTarefa({this.tarefa});

  @override
  _TelaNovaTarefaState createState() => _TelaNovaTarefaState();
}

class _TelaNovaTarefaState extends State<TelaNovaTarefa> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  TimeOfDay? horario;
  Map<String, bool> diasSelecionados = {
    "DOM": false,
    "SEG": false,
    "TER": false,
    "QUA": false,
    "QUI": false,
    "SEX": false,
    "SÁB": false,
  };
  String categoriaSelecionada = 'Nenhuma';
  String? _mensagemErro;

  @override
  void initState() {
    super.initState();
    if (widget.tarefa != null) {
      _tituloController.text = widget.tarefa!['titulo'] ?? '';
      _descricaoController.text = widget.tarefa!['descricao'] ?? '';
      horario = widget.tarefa!['horario'] != null
          ? TimeOfDay(
              hour: int.parse(widget.tarefa!['horario'].split(":")[0]),
              minute: int.parse(widget.tarefa!['horario'].split(":")[1]),
            )
          : null;
      for (String dia in widget.tarefa!['dias'] ?? []) {
        diasSelecionados[dia] = true;
      }
      categoriaSelecionada = widget.tarefa!['categoria'] ?? 'Nenhuma';
    }
  }

  void selecionarHorario(BuildContext context) async {
    final novoHorario = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(
            data: ThemeData(
              colorScheme: ColorScheme.light(
                primary: Colors.lightBlueAccent, // Cor do relógio
                onSurface: Colors.blueAccent, // Cor do texto do relógio
              ),
            ),
            child: child!,
          ),
        );
      },
    );
    if (novoHorario != null) setState(() => horario = novoHorario);
  }

  void selecionarCategoria() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> categoriasSalvas = prefs.getStringList('categorias') ?? [];

    if (categoriasSalvas.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text("Categorias", style: TextStyle(color: Colors.black)),
            content: Text("Nenhuma categoria disponível.",
                style: TextStyle(color: Colors.grey)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK", style: TextStyle(color: Colors.blueAccent)),
              ),
            ],
          );
        },
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Selecione uma Categoria",
              style: TextStyle(color: Colors.black)),
          content: SingleChildScrollView(
            child: ListBody(
              children: categoriasSalvas.map((categoria) {
                return ListTile(
                  title: Text(categoria, style: TextStyle(color: Colors.black)),
                  onTap: () {
                    setState(() {
                      categoriaSelecionada = categoria;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _salvarTarefa() async {
    if (_tituloController.text.isEmpty) {
      setState(() {
        _mensagemErro = "O título não pode estar vazio.";
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final String? tarefasJson = prefs.getString('tarefas');

    List<Map<String, dynamic>> tarefasList = [];
    if (tarefasJson != null) {
      tarefasList = List<Map<String, dynamic>>.from(jsonDecode(tarefasJson));
    }

    final tarefa = {
      'titulo': _tituloController.text,
      'descricao': _descricaoController.text,
      'horario': horario != null
          ? "${horario!.hour}:${horario!.minute.toString().padLeft(2, '0')}"
          : null,
      'dias': diasSelecionados.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList(),
      'categoria': categoriaSelecionada,
    };

    tarefasList.add(tarefa);
    await prefs.setString('tarefas', jsonEncode(tarefasList));
    Navigator.pop(context, tarefa);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 4,
                runSpacing: 4,
                children: diasSelecionados.entries.map((entry) {
                  String dia = entry.key;
                  bool selecionado = entry.value;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        diasSelecionados[dia] = !selecionado;
                      });
                    },
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: selecionado
                          ? Colors.lightBlueAccent
                          : Colors.grey[300],
                      child: Text(
                        dia,
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _tituloController,
                decoration: InputDecoration(
                  labelText: "Título",
                  labelStyle: TextStyle(color: Colors.blueAccent),
                ),
              ),
              if (_mensagemErro != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _mensagemErro!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 8),
              TextField(
                controller: _descricaoController,
                decoration: InputDecoration(
                  labelText: "Descrição",
                  labelStyle: TextStyle(color: Colors.blueAccent),
                ),
              ),
              SizedBox(height: 8),
              TextButton(
                onPressed: selecionarCategoria,
                child: Text("Selecionar Categoria: $categoriaSelecionada",
                    style: TextStyle(color: Colors.blueAccent)),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.cancel, color: Colors.redAccent),
                    onPressed: () => Navigator.pop(context, null),
                  ),
                  IconButton(
                    icon: Icon(Icons.access_time, color: Colors.blueAccent),
                    onPressed: () => selecionarHorario(context),
                  ),
                  IconButton(
                    icon: Icon(Icons.save, color: Colors.green),
                    onPressed: _salvarTarefa,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
