import 'package:flutter/material.dart';
import 'package:buscador_gifs/ui/gif_page.dart';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:http/http.dart' as http;
import "dart:convert";
import 'dart:async';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _off = 0;
  Future<Map> _getSearch() async {
    http.Response response;
    (_search == null)
        ? response = await http.get(
            "https://api.giphy.com/v1/gifs/trending?api_key=4m7wOUvOlXptUS0QI2UUo993PpALFebN&limit=20&rating=G")
        : response = await http.get(
            "https://api.giphy.com/v1/gifs/search?api_key=4m7wOUvOlXptUS0QI2UUo993PpALFebN&q=$_search&limit=19&offset=$_off&rating=G&lang=en");
    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
    _getSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Search giphys",
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                setState(() {
                  _search = text;
                  _off = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getSearch(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200.0,
                      height: 200.0,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        strokeWidth: 5.0,
                      ),
                    );
                  default:
                    return (snapshot.hasError)
                        ? Text("Ouve um erro na requisição dos gifs")
                        : _createGifsTable(context, snapshot);
                }
              },
            ),
          )
        ],
      ),
    );
  }

  int _getCount(List data) {
    return (_search == null) ? data.length : data.length + 1;
  }

  Widget _createGifsTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: _getCount(snapshot.data["data"]),
      itemBuilder: (context, index) {
        return (_search == null || index < snapshot.data["data"].length)
            ? GestureDetector(
                child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
                  height: 300.0,
                  fit: BoxFit.cover,
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              GifPage(snapshot.data["data"][index])));
                },
                onLongPress: () {
                  Share.share(snapshot.data["data"][index]["images"]
                      ["fixed_height"]["url"]);
                },
              )
            : Container(
                child: GestureDetector(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 70.0,
                      ),
                      Text(
                        "Show more",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.0,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    setState(
                      () {
                        _off += 19;
                      },
                    );
                  },
                ),
              );
      },
    );
  }
}
