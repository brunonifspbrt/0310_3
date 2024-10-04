import 'package:ex3/main.dart';
import 'package:flutter/material.dart';

class SegundaTela extends StatefulWidget {
  //const SegundaTela({super.key});
  var records;
  // o antigo construtor era const SegundaTela({super.key}) perceba que foi alterado para receber o valor
  SegundaTela({super.key, required this.records});

  @override
  State<SegundaTela> createState() => _SegundaTelaState();
}

class _SegundaTelaState extends State<SegundaTela> {
  // records será alimentado ao ser chamado o Widget

  // preciso definir o construtor desse widget onde ele recebe a variavel
  //_SegundaTelaState({key key, @required this.int}) : super(key: key);
  //const _SegundaTelaState({super.key, required this.todo});

  int resultado = 0;

  TextEditingController contTexto = TextEditingController();
  TextEditingController controlaY = TextEditingController();

  @override
  void initState() {
    var conteudo;
    // TODO: implement initState
    super.initState();
    conteudo = widget.records;
    contTexto.text = conteudo.toString();
  }

  // a função deve receber o parâmetro context
  void telaAnterior(BuildContext context) {
    int val = 0;
    Navigator.pop(
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: contTexto,
              maxLines: 10,
              decoration: const InputDecoration(labelText: 'Registros'),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                // perceba que é necessário colocar a função dentro de uma função anônima no evento onPressed
                telaAnterior(context);
              },
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}
