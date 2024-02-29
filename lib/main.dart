import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _baseUrl = 'https://jsonplaceholder.typicode.com/posts';
  int _page = 0;
  final int _limit = 20;
  bool _isFirstLoadRunning = false;
  bool _hasNextPage = true;
  bool _isLoadMoreRunning = false;
  List _posts = [];

  void _firstLoad() async{
    setState(() {
      _isFirstLoadRunning = true;
    });

    try{

      final res = await http.get(Uri.parse("$_baseUrl?_page=$_page&_limit=$_limit"));
      setState(() {
        _posts = json.decode(res.body);
        print(_posts.first);
      });

    } catch(err){
      print('something wrong $err');
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  void _loadMore() async{
    if(_hasNextPage==true &&
        _isFirstLoadRunning==false &&
        _isLoadMoreRunning==false &&
        _controller.position.extentAfter < 300
    ){

      setState(() {
        _isLoadMoreRunning = true;
      });

      _page +=1;

      try{
        final res = await http.get(Uri.parse("$_baseUrl?_page=$_page&_limit=$_limit"));

        final List fetchPosts = json.decode(res.body);
        if(fetchPosts.isNotEmpty){
          setState(() {
            _posts.addAll(fetchPosts);
          });
        } else{
          setState(() {
            _hasNextPage = false;
          });
        }

      } catch (err){
        print('Something Wrong $err');
      }

      setState(() {
        _isLoadMoreRunning = false;
      });
    }
  }

  late ScrollController _controller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _firstLoad();
    _controller = ScrollController()..addListener(_loadMore);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Center(child: Text('your news', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center,)),
      ),
      body: _isFirstLoadRunning ? const Center(
        child: CircularProgressIndicator(

        ),
      ) : Column(
        children: [
          Expanded(
              child: ListView.builder(
                itemCount: _posts.length,
                controller: _controller,
                itemBuilder: ( _ , index) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: ListTile(
                    title: Text(_posts[index]['title']),
                    subtitle: Text(_posts[index]['body']),
                  ),
                )
              ),
          ),
          if(_isLoadMoreRunning == true)
            const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 40),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          if(_hasNextPage == false)
            Container(
              padding : const EdgeInsets.only(top: 30, bottom: 40),
              color: Colors.amber,
              child: const Center(
                child: Text('You have fetched all of the content'),
              ),
            ),
        ],
      ),
    );
  }
}
