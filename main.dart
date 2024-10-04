// para lidar com arquivos
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ex3/registros.dart';
import 'package:path/path.dart';
// requer flutter pub add sqflite path (funciona somente em Android, Ios)
import 'package:sqflite/sqflite.dart';
//in main.dart write this:
// requer flutter pub add sqflite_common_ffi caso queira testar em Windows
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// requer flutter pub add path_provider
import 'package:path_provider/path_provider.dart';
// requer flutter pub add shared_preferences
//import 'package:shared_preferences/shared_preferences.dart';

// outras configurações
// 1- Como o SQLFLite só funciona em mobile, abra o Android Studio e o emumlador Android
// 2- No Flutter, configure pra enviar o projeto para o emulador android
// 3- No terminal coloque flutter run e veja as mensagens de erro
// 4- Caso dê erro, vá no android\app\build.grade altere a linha 25 (mais ou menos) onde tem compileSdkVersion flutter.compileSdkVersion para compileSdkVersion 34,
// ficará como abaixo
// android {
//     namespace "com.example.ex3"
//     //compileSdkVersion flutter.compileSdkVersion
//     compileSdkVersion 34
// 5- Aplique no terminal o flutter run ou flutter build apk
// 6- Pelo explorer, encontre o arquivo .apk e envie para o emulador Android (do Android Studio) ARRASTANDO o apk
// 7- Execute o apk pelo emulador Android e teste, seja feliz

void main() async {
  // ao usar mais de uma tela é necessário trocar, na primeira tela que irá utilizar o navigator,
  // a chamada do runapp
  // é necessário chamar como abaixo: informando o MaterialApp e depois chamando o MainApp
  //runApp(const MainApp());
  runApp(MaterialApp(home: MainApp()));
}

class Cao {
  final int id;
  final String nome;
  final String raca;
  final int idade;

  Cao({
    required this.id,
    required this.nome,
    required this.raca,
    required this.idade,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'nome': nome,
      'raca': raca,
      'idade': idade,
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'Cao{id: $id, nome: $nome, raça: $raca, idade: $idade}';
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  var conteudo = '';
  var msg = '';
  var msgN = '';
  var msgR = '';
  var msgI = '';
  //TextEditingController tfCep = TextEditingController();
  TextEditingController contNome = TextEditingController();
  TextEditingController contRaca = TextEditingController();
  TextEditingController contIdade = TextEditingController();

  // declaro variável e informo que vou instanciar no futuro (late)
  late final database;

  @override
  void initState() {
    super.initState();
    carregaBD();
  }

  void carregaBD() async {
    WidgetsFlutterBinding.ensureInitialized();
    // verifica se plataforma é Desktop
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // inicializa o sqflite ffi
      sqfliteFfiInit(); // Inicializa o FFI
      databaseFactory = databaseFactoryFfi; // Define o databaseFactory para FFI
    }

    // databaseFactory = databaseFactoryFfi;
    // final database = openDatabase(

    // caso exista o banco ele carrega, caso não o método OnCreate será ativado
    database = openDatabase(
      join(await getDatabasesPath(), 'petshop.db'),
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          'CREATE TABLE caes(id INTEGER PRIMARY KEY, nome TEXT, raca TEXT,idade INTEGER)',
        );
      },
      version: 1,
    );
  }

  Future<void> insereCao(Cao cao) async {
    final db = await database;

    await db.insert(
      'caes',
      cao.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Cao>> caes() async {
    final db = await database;

    final List<Map<String, Object?>> mapasCaes = await db.query('caes');

    return [
      for (final {
            'id': id as int,
            'nome': nome as String,
            'raca': raca as String,
            'idade': idade as int,
          } in mapasCaes)
        Cao(id: id, nome: nome, raca: raca, idade: idade),
    ];
  }

  Future<void> atualizaCao(Cao cao) async {
    final db = await database;

    await db.update(
      'caes',
      cao.toMap(),
      where: 'id = ?',
      whereArgs: [cao.id],
    );
  }

  Future<void> apagaCao(int id) async {
    final db = await database;

    await db.delete(
      'caes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  void limpaCampos() {
    contNome.clear();
    contRaca.clear();
    contIdade.clear();
  }

  void limpa() async {
    final db = await database;
    await db.rawDelete("DELETE FROM caes");
    print("Tabela caes limpa com sucesso");
  }

  void salva() async {
    int resultado = 1;
    int? idade = 0;
    msgN = '';
    msgR = '';
    msgI = '';
    final db = await database;

    if (contNome.text.length < 1) {
      resultado = 0;
      msgN = "Informe um nome de cachorro válido";
    }

    if (resultado != 0) {
      if (contRaca.text.length < 1) {
        resultado = 0;
        msgR = "Informe uma raça de cachorro válida";
      }
    }

    if (resultado != 0) {
      // caso o try dê errado ele retorna NULO
      idade = int.tryParse(contIdade.text);
      if (idade == null) {
        resultado = 0;
        msgI = "Informe uma idade de cachorro válida";
      }
    }

    setState(() {
      // forço atualizar variável aqui
      msgN = msgN;
      msgR = msgR;
      msgI = msgI;
    });

    // exibo no console só pra ver
    // print(contNome.text);
    // print(contRaca.text);
    // print(contIdade.text);
    if (resultado != 0) {
      // obtem última ID no banco
      var maxID =
          await db.rawQuery('SELECT max(coalesce(ID,0)) as ID FROM caes');
      // print("Max ID:  $maxID");
      // primeira posição do vetor
      maxID = maxID[0];
      // acessar objeto
      maxID = maxID['ID'];
      // caso nulo converte pra zero
      maxID = (maxID == null) ? 0 : maxID;
      //print("Max ID sem nulo:  $maxID");
      // incrementa ID
      maxID = maxID + 1;

      // cria classe para salvar dados
      var novoCao = Cao(
        id: maxID,
        nome: contNome.text,
        raca: contRaca.text,
        idade: int.parse(contIdade.text),
      );

      // insere registro
      await insereCao(novoCao);
      // imprime registros
      print(await caes());
    }
  }

  void exibeDados(BuildContext context) async {
    // uso o navigator para mudar de página pelo push. Ao chamar o segundo widget informo no parâmetro numX (do segundo Widget) o valor que desejo
    // para usar await o async deve estar declarado na função telaSubtracao

    var dados = "Dados do cão: \n";
    // obtem lista de registros do bd
    List<Cao> registros = await caes();

    // faz itearção para criar string com a informação
    registros.forEach((e) => {
          dados = dados +
              "ID: ${e.id}, Nome: ${e.nome}, Raça: ${e.raca}, Idade: ${e.idade}\n"
        });
    // print("Opa");
    // print(dados);
    // envia dados para a tela de exibição de registros
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SegundaTela(
            records: dados,
          ),
        ));
  }

  // caramelo = Cao(
  //   id: caramelo.id,
  //   nome: caramelo.nome,
  //   raca: caramelo.raca,
  //   idade: caramelo.idade + 7,
  // );
  // await atualizaCao(caramelo);

  // print(await caes());

  // // Delete Fido from the database.
  // await apagaCao(caramelo.id);

  // // Print the list of dogs (empty).
  // print(await caes());

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: contNome,
                  decoration:
                      InputDecoration(labelText: 'Nome:', helperText: msgN),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: contRaca,
                  decoration:
                      InputDecoration(labelText: 'Raça:', helperText: msgR),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: contIdade,
                  decoration:
                      InputDecoration(labelText: 'Idade:', helperText: msgI),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: salva, child: const Text('Salva')),
                  ElevatedButton(
                      onPressed: limpa,
                      child: const Text('Limpa todos os registros')),
                  ElevatedButton(
                      onPressed: () {
                        exibeDados(context);
                      },
                      child: const Text('Exibir dados')),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Text('Resultado: $msg'),
            ],
          ),
        ),
      ),
    );
  }
}
