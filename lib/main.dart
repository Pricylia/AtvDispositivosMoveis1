import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int ? idContato;
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  List<Map<String, dynamic>> _contatos = [];

  
  _openBanco() async {
      var dataBasePath = await getDatabasesPath();
      String path = join(dataBasePath, 'banco.db');

      Database bd = await openDatabase(path, version: 1,
      onCreate: (Database db, int versaoRecente) async{
        String sql = "CREATE TABLE contato (id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT, email TEXT)";
        await db.execute(sql);
      }
      );
      print("AQUI");
      return bd;
  }  

  _salvar(Map<String, dynamic> dadosContato) async{  
      Database bd = await _openBanco();    
      await bd.insert('contato', dadosContato);
      print("Contato salvo com id:");
      _verContatos();
  }

  _verContatos() async {
    Database bd = await _openBanco(); 
    List<Map<String, dynamic>> contatos = await bd.query('contatos');

    setState(() {
      _contatos = contatos;
    });
  }

  @override
    void initState(){
      super.initState();
      _openBanco();
      _verContatos();

    }

  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3, 
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lista de Contatos'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.add_box_outlined),
              ),
              Tab(
                icon: Icon(Icons.view_list_outlined),
              ),
              Tab(
                icon: Icon(Icons.account_box_outlined),
              ),
            ]
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            // Tab 1
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.network(width: 100, 'https://cdn-icons-png.freepik.com/512/1144/1144760.png?ga=GA1.1.177399096.1709223240&'),
                Container(
                  margin: const EdgeInsets.all(15),
                  width: 300,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Nome'
                    ),
                    controller: _nomeController,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(15),
                  width: 300,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'E-mail'
                    ),
                    controller: _emailController,
                  ),
                ),
                ElevatedButton(
                  child: const Text('Salvar'),
                  onPressed: () async {
                    String nome = _nomeController.text;
                    String email = _emailController.text;
                    Map<String, dynamic> dadosContato = {
                        'nome': nome,
                        'email': email
                      };
                    await _salvar(dadosContato);
                     _nomeController.clear();
                     _emailController.clear();
                  },
                ),
              ]
            ),
            // Tab 2
            ListView.builder(
              itemCount: _contatos.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_contatos[index]['nome']),
                  subtitle: Text(_contatos[index]['email']),
                );
              },
            ),
            // Tab 3
            Center(
              child: Text('Tab 3')
            ),
          ]
        )
      ),
    );
  }
}
