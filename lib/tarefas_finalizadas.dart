import 'package:flutter/material.dart';

class TarefasFinalizadas extends StatefulWidget {
  final List<Map<String, dynamic>> tarefas;
  final List<Map<String, dynamic>> tarefasFinalizadas;
  final Function(Map<String, dynamic>) restaurarTarefa;
  final Function(Map<String, dynamic>)
      removerTarefa; // Função para remover a tarefa

  TarefasFinalizadas({
    required this.tarefas,
    required this.tarefasFinalizadas,
    required this.restaurarTarefa,
    required this.removerTarefa, // Passando a função de remoção
  });

  @override
  _TarefasFinalizadasState createState() => _TarefasFinalizadasState();
}

class _TarefasFinalizadasState extends State<TarefasFinalizadas> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tarefas Finalizadas",
            style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
        backgroundColor: Colors.lightBlueAccent, // Cor de fundo da AppBar
      ),
      body: widget.tarefasFinalizadas.isEmpty
          ? Center(
              child: Text("Nenhuma tarefa finalizada",
                  style: TextStyle(color: Colors.blueGrey)))
          : ListView.builder(
              itemCount: widget.tarefasFinalizadas.length,
              itemBuilder: (context, index) {
                final tarefa = widget.tarefasFinalizadas[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.white, // Fundo do card
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        tarefa['titulo'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent, // Cor do título
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tarefa['descricao'],
                              style: TextStyle(color: Colors.black87)),
                          SizedBox(height: 8),
                          Text(
                            "Dias: ${tarefa['dias'].join(", ")}", // Exibe os dias
                            style:
                                TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Horário: ${tarefa['horario'] ?? 'Não definido'}", // Exibe o horário
                            style:
                                TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Botão para restaurar a tarefa
                          IconButton(
                            icon: Icon(Icons.undo, color: Colors.green),
                            onPressed: () {
                              widget
                                  .restaurarTarefa(tarefa); // Restaura a tarefa
                              Navigator.pop(context); // Fecha a tela
                            },
                          ),
                          // Botão para apagar a tarefa
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _confirmarRemocao(context,
                                  tarefa); // Passa a tarefa para remoção
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Função para confirmar a remoção da tarefa
  void _confirmarRemocao(BuildContext context, Map<String, dynamic> tarefa) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Remover Tarefa',
              style: TextStyle(color: Colors.blueAccent)),
          content: Text('Deseja realmente apagar esta tarefa?',
              style: TextStyle(color: Colors.black)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fecha o diálogo sem remover
              },
              child:
                  Text('Cancelar', style: TextStyle(color: Colors.blueAccent)),
            ),
            TextButton(
              onPressed: () {
                widget.removerTarefa(tarefa); // Chama a função de remoção
                Navigator.pop(context); // Fecha o diálogo
                setState(() {}); // Atualiza o estado da tela
              },
              child: Text('Apagar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
