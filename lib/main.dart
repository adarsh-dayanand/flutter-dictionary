import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dictionary',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String _url = "https://wordsapiv1.p.rapidapi.com/words/";
  
  TextEditingController controller = TextEditingController();

  StreamController streamController;
  Stream stream;
  Timer timer;

  search() async {
    if(controller.text == null || controller.text.length == 0){
      streamController.add(null);
      return;
    }
    else{
      streamController.add("Waiting");
      Response response = await get(_url + controller.text.trim(), headers: {
        "x-rapidapi-key": "", //Your API
        "x-rapidapi-host": "wordsapiv1.p.rapidapi.com"
      });

      streamController.add(json.decode(response.body));
    }

  }

  @override
  void initState(){
    super.initState();
    streamController = StreamController();
    stream = streamController.stream;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      appBar: AppBar(
        title: Text("Dictionary"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 12.0, bottom: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: TextFormField(

                    onChanged: (String text){
                    
                      if(timer ?.isActive ?? false) timer.cancel();
                    
                      timer = Timer(const Duration(milliseconds: 1000), (){
                        search();
                      });
                    
                    },
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Search for a word",
                      contentPadding: const EdgeInsets.only(left: 24.0),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                  ), 
                  onPressed: () { 
                    search();
                  }, 
                  )
            ],
          ),
        ),
      ),

      body: Container(
        margin: const EdgeInsets.all(8.0),
        child: StreamBuilder(
          stream: stream,
          builder: (BuildContext context, AsyncSnapshot snapshot) { 
              if(snapshot.data == null ){
                return Center(
                  child: Text("Enter the search word"),
                );
              }
              
              if(snapshot.data == "Waiting"){
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              if(snapshot.data["success"] == "false" || snapshot.data["message"] == "word not found" ){
                return Center(
                  child: Text("Word not found"),
                );
              }


              return ListView.builder(
                itemCount: snapshot.data["results"].length,
                itemBuilder: (BuildContext context, int index){
                  return ListBody(
                    children: <Widget>[
                      Container(
                        color: Colors.grey[300],
                        child: ListTile(
                          title: Text(controller.text.trim() + "( " + snapshot.data["results"][index]["partOfSpeech"] + " )" ),
                          // subtitle: Text(controller.text.trim() + snapshot.data["results"][index]["definition"] ),
                        ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(snapshot.data["results"][index]["definition"]),
                        )
                    ]
                  );
              });

           },

        ),
      ),
    );
  }
}
