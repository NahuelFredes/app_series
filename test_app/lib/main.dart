import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

void main() => runApp(MaterialApp(title: "Weather App", home: TestApp()));

class TestApp extends StatefulWidget {
  @override
  _TestAppState createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  final List<Tab> myTabs = <Tab>[
    Tab(text: 'Series Vistas'),
    Tab(text: 'Series para Ver'),
  ];



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: Colors.grey[850],
            appBar: AppBar(
              backgroundColor: Colors.red[900],
              title: Text('Buscar Series'),
              bottom: TabBar(tabs: myTabs, onTap: (index) {}),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    showSearch(context: context, delegate: DataSearch());
                  },
                )
              ],
            ),
            body: TabBarView(
                children: myTabs.map((Tab tab) {
              final String label = tab.text;
              if (label == 'Series Vistas') {
                return FutureBuilder(
                    future: getDates('watched.json'),
                    builder: (context, snapshot) {
                      Map<String, dynamic> dates = snapshot.data;
                      if (dates == null) {
                        return Center(child: Text('No hay series'));
                      } else {
                        return Center(
                            child: ListView.builder(
                                //itemExtent: 115,
                                itemCount: dates.length,
                                itemBuilder: (context, index) {

                                  var key = dates.keys.toList()[index];

                                  return Dismissible(
                                    key: Key(dates[index]),
                                    child: ListTile(
                                      title: Text(
                                          dates[key.toString()]['Title'],
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      subtitle:
                                          Text(dates[key.toString()]['Plot']),
                                      leading: SizedBox(
                                          height: 100,
                                          child: Image.network(
                                              dates[key.toString()]['Poster'],
                                              fit: BoxFit.cover)),
                                    ),
                                    background: Container(
                                        color: Colors.red[800],
                                        child: Icon(Icons.delete)),
                                    onDismissed: (direction) {
                                      dates.remove(key);

                                      getApplicationDocumentsDirectory()
                                          .then((Directory directory) {
                                        File jsonFile = File(directory.path +
                                            '/' +
                                            'watched.json');
                                        Map jsonFileContent = jsonDecode(
                                            jsonFile.readAsStringSync());
                                        jsonFileContent
                                            .remove(key.toString());
                                        jsonFile.writeAsString(
                                            jsonEncode(jsonFileContent));
                                      });
                                    },
                                  );
                                }));
                      }
                    });
              } else {
                return FutureBuilder(
                    future: getDates('towatch.json'),
                    builder: (context, snapshot) {
                      Map<String, dynamic> dates = snapshot.data;
                      if (dates == null) {
                        return Center(child: Text('No hay series'));
                      } else {
                      return Center(
                          child: ListView.builder(
                              //itemExtent: 115,
                              itemCount: dates.length,
                              itemBuilder: (context, index) {

                                var key = dates.keys.toList()[index];
                                return Dismissible(
                                  key: Key(dates[index]),
                                  child: ListTile(
                                    title: Text(dates[key.toString()]['Title'],
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    subtitle:
                                        Text(dates[key.toString()]['Plot']),
                                    leading: SizedBox(
                                        height: 100,
                                        child: Image.network(
                                            dates[key.toString()]['Poster'],
                                            fit: BoxFit.cover)),
                                  ),
                                  background: Container(
                                      color: Colors.red[800],
                                      child: Icon(Icons.delete)),
                                  onDismissed: (direction) {
                                    dates.remove(key);

                                    getApplicationDocumentsDirectory()
                                        .then((Directory directory) {
                                      File jsonFile = File(directory.path +
                                          '/' +
                                          'towatch.json');
                                      Map jsonFileContent = jsonDecode(
                                          jsonFile.readAsStringSync());
                                      jsonFileContent.remove(key.toString());
                                      jsonFile.writeAsString(
                                          jsonEncode(jsonFileContent));
                                    });
                                  },
                                );
                              }));}
                    });
              }
            }).toList()),
          )),
    );
  }
}

  

Future getDates(file) async {
  final directorio = await getApplicationDocumentsDirectory();
  File jsonFile = File(directorio.path + '/' + file);
  Map dates = jsonDecode(jsonFile.readAsStringSync());
  final fileExists = jsonFile.existsSync();
  if(fileExists!=false){
  return dates;
  }else{
    return null;
  }
  
}

Future getData(data) async {
  Response response =
      await get('http://www.omdbapi.com/?t=' + data + '&apikey=dfdc1c2c');
  Map map = jsonDecode(response.body);
  return map;
}

class DataSearch extends SearchDelegate<String> {
  final cities = [];

  final citiesRecientes = [];

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
      future: getData(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Center(
              child: ListView(
            children: <Widget>[
              Image.network(snapshot.data['Poster']),
              Text(snapshot.data['Title'],
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(snapshot.data['Plot']),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <
                  Widget>[
                SizedBox.fromSize(
                  size: Size(80, 80), // button width and height
                  child: ClipOval(
                    child: Material(
                      color: Colors.grey, // button color
                      child: InkWell(
                        splashColor: Colors.red, // splash color
                        onTap: () {
                          getApplicationDocumentsDirectory()
                              .then((Directory directory) {
                            File jsonFile =
                                File(directory.path + '/' + 'watched.json');
                            final fileExists = jsonFile.existsSync();

                            File jsonFileId =
                                File(directory.path + '/' + 'id_watched.json');
                            final fileExistsId = jsonFileId.existsSync();
                            if (fileExistsId != false) {
                              Map jsonFileContentId =
                                  jsonDecode(jsonFileId.readAsStringSync());
                              if (jsonFileContentId.isEmpty) {
                                jsonFileId.writeAsString(jsonEncode({'id': 0}));
                              } else {
                                int finalContentId =
                                    jsonFileContentId['id'] + 1;
                                jsonFileId
                                    .writeAsString(
                                        jsonEncode({'id': finalContentId}))
                                    .then((context) {
                                  if (fileExists != false) {
                                    int id = jsonDecode(
                                        jsonFileId.readAsStringSync())['id'];
                                    Map<String, dynamic> content = {
                                      id.toString(): snapshot.data
                                    };
                                    Map jsonFileContent =
                                        jsonDecode(jsonFile.readAsStringSync());
                                    if (jsonFileContent.isEmpty) {
                                      jsonFile
                                          .writeAsString(jsonEncode(content));
                                    } else {
                                      jsonFileContent.addAll(content);
                                      jsonFile.writeAsString(
                                          jsonEncode(jsonFileContent));

                                                                              }
                                                                            } else {
                                                                              int id = jsonDecode(
                                                                                  jsonFileId.readAsStringSync())['id'];
                                                                              Map<String, dynamic> content = {
                                                                                id.toString(): snapshot.data
                                                                              };
                                                                              jsonFile.create();
                                                                              jsonFile
                                                                                  .writeAsString(jsonEncode({}))
                                                                                  .then((context) {
                                                                                Map jsonFileContent = jsonDecode(
                                                                                    jsonFile.readAsStringSync());
                                                                                if (jsonFileContent.isEmpty) {
                                                                                  jsonFile
                                                                                      .writeAsString(jsonEncode(content));
                                                                                } else {
                                                                                  jsonDecode(jsonFile.readAsStringSync())
                                                                                      .addAll(content);
                                                                                  jsonFile.writeAsString(
                                                                                      jsonEncode(jsonFileContent));
                                                                                }
                                                                              });
                                                                            }
                                                                          });
                                                                        }
                                                                      } else {
                                                                        jsonFileId.create();
                                                                        jsonFileId
                                                                            .writeAsString(jsonEncode({'id': 0}))
                                                                            .then((context) {
                                                                          if (fileExists != false) {
                                                                            int id = jsonDecode(
                                                                                jsonFileId.readAsStringSync())['id'];
                                                                            Map<String, dynamic> content = {
                                                                              id.toString(): snapshot.data
                                                                            };
                                                                            Map jsonFileContent =
                                                                                jsonDecode(jsonFile.readAsStringSync());
                                                                            if (jsonFileContent.isEmpty) {
                                                                              jsonFile.writeAsString(jsonEncode(content));
                                                                            } else {
                                                                              jsonFileContent.addAll(content);
                                                                              jsonFile.writeAsString(
                                                                                  jsonEncode(jsonFileContent));
                                          
                                                                            }
                                                                          } else {
                                                                            int id = jsonDecode(
                                                                                jsonFileId.readAsStringSync())['id'];
                                                                            Map<String, dynamic> content = {
                                                                              id.toString(): snapshot.data
                                                                            };
                                                                            jsonFile.create();
                                                                            jsonFile
                                                                                .writeAsString(jsonEncode({}))
                                                                                .then((context) {
                                                                              Map jsonFileContent =
                                                                                  jsonDecode(jsonFile.readAsStringSync());
                                                                              if (jsonFileContent.isEmpty) {
                                                                                jsonFile
                                                                                    .writeAsString(jsonEncode(content));
                                                                              } else {
                                                                                jsonDecode(jsonFile.readAsStringSync())
                                                                                    .addAll(content);
                                                                                jsonFile.writeAsString(
                                                                                    jsonEncode(jsonFileContent));
                                                                              }
                                                                            });
                                                                          }
                                                                        });
                                                                      }
                                                                    });
                                                                  }, // button pressed
                                                                  child: Column(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: <Widget>[
                                                                      Icon(Icons.add), // icon
                                                                      Text("Add Watched",
                                                                          textAlign: TextAlign.center), // text
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox.fromSize(
                                                            size: Size(80, 80), // button width and height
                                                            child: ClipOval(
                                                              child: Material(
                                                                color: Colors.grey, // button color
                                                                child: InkWell(
                                                                  splashColor: Colors.red, // splash color
                                                                  onTap: () {
                                                                    getApplicationDocumentsDirectory()
                                                                        .then((Directory directory) {
                                                                      File jsonFile =
                                                                          File(directory.path + '/' + 'towatch.json');
                                                                      final fileExists = jsonFile.existsSync();
                                          
                                                                      File jsonFileId =
                                                                          File(directory.path + '/' + 'id_towatch.json');
                                                                      final fileExistsId = jsonFileId.existsSync();
                                          
                                                                      if (fileExistsId != false) {
                                                                        Map jsonFileContentId =
                                                                            jsonDecode(jsonFileId.readAsStringSync());
                                                                        if (jsonFileContentId.isEmpty) {
                                                                          jsonFileId.writeAsString(jsonEncode({'id': 0}));
                                                                        } else {
                                                                          int finalContentId =
                                                                              jsonFileContentId['id'] + 1;
                                                                          jsonFileId
                                                                              .writeAsString(
                                                                                  jsonEncode({'id': finalContentId}))
                                                                              .then((context) {
                                                                            if (fileExists != false) {
                                                                              int id = jsonDecode(
                                                                                  jsonFileId.readAsStringSync())['id'];
                                                                              Map<String, dynamic> content = {
                                                                                id.toString(): snapshot.data
                                                                              };
                                                                              Map jsonFileContent =
                                                                                  jsonDecode(jsonFile.readAsStringSync());
                                                                              if (jsonFileContent.isEmpty) {
                                                                                jsonFile
                                                                                    .writeAsString(jsonEncode(content));
                                                                              } else {
                                                                                jsonFileContent.addAll(content);
                                                                                jsonFile.writeAsString(
                                                                                    jsonEncode(jsonFileContent));
                                          
                                                                              }
                                                                            } else {
                                                                              int id = jsonDecode(
                                                                                  jsonFileId.readAsStringSync())['id'];
                                                                              Map<String, dynamic> content = {
                                                                                id.toString(): snapshot.data
                                                                              };
                                                                              jsonFile.create();
                                                                              jsonFile
                                                                                  .writeAsString(jsonEncode({}))
                                                                                  .then((context) {
                                                                                Map jsonFileContent = jsonDecode(
                                                                                    jsonFile.readAsStringSync());
                                                                                if (jsonFileContent.isEmpty) {
                                                                                  jsonFile
                                                                                      .writeAsString(jsonEncode(content));
                                                                                } else {
                                                                                  jsonDecode(jsonFile.readAsStringSync())
                                                                                      .addAll(content);
                                                                                  jsonFile.writeAsString(
                                                                                      jsonEncode(jsonFileContent));
                                                                                }
                                                                              });
                                                                            }
                                                                          });
                                                                        }
                                                                      } else {
                                                                        jsonFileId.create();
                                                                        jsonFileId
                                                                            .writeAsString(jsonEncode({'id': 0}))
                                                                            .then((context) {
                                                                          if (fileExists != false) {
                                                                            int id = jsonDecode(
                                                                                jsonFileId.readAsStringSync())['id'];
                                                                            Map<String, dynamic> content = {
                                                                              id.toString(): snapshot.data
                                                                            };
                                                                            Map jsonFileContent =
                                                                                jsonDecode(jsonFile.readAsStringSync());
                                                                            if (jsonFileContent.isEmpty) {
                                                                              jsonFile.writeAsString(jsonEncode(content));
                                                                            } else {
                                                                              jsonFileContent.addAll(content);
                                                                              jsonFile.writeAsString(
                                                                                  jsonEncode(jsonFileContent));
                                          
                                                                            }
                                                                          } else {
                                                                            int id = jsonDecode(
                                                                                jsonFileId.readAsStringSync())['id'];
                                                                            Map<String, dynamic> content = {
                                                                              id.toString(): snapshot.data
                                                                            };
                                                                            jsonFile.create();
                                                                            jsonFile
                                                                                .writeAsString(jsonEncode({}))
                                                                                .then((context) {
                                                                              Map jsonFileContent =
                                                                                  jsonDecode(jsonFile.readAsStringSync());
                                                                              if (jsonFileContent.isEmpty) {
                                                                                jsonFile
                                                                                    .writeAsString(jsonEncode(content));
                                                                              } else {
                                                                                jsonDecode(jsonFile.readAsStringSync())
                                                                                    .addAll(content);
                                                                                jsonFile.writeAsString(
                                                                                    jsonEncode(jsonFileContent));
                                                                              }
                                                                            });
                                                                          }
                                                                        });
                                                                      }
                                                                    });
                                                                  }, // button pressed
                                                                  child: Column(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: <Widget>[
                                                                      Icon(Icons.add), // icon
                                                                      Text("Add to Watch",
                                                                          textAlign: TextAlign.center), // text
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ]),
                                                      ],
                                                    ));
                                                  } else {
                                                    return Center(
                                                      child: Text('Conection Lost'),
                                                    );
                                                  }
                                                },
                                              );
                                            }
                                          
                                            @override
                                            Widget buildSuggestions(BuildContext context) {
                                              final suggestionList = query.isEmpty
                                                  ? citiesRecientes
                                                  : cities.where((p) => p.startsWith(query)).toList();
                                          
                                              return ListView.builder(
                                                itemBuilder: (context, index) => ListTile(
                                                  leading: Icon(Icons.location_city),
                                                  title: Text(suggestionList[index]),
                                                ),
                                                itemCount: suggestionList.length,
                                              );
                                            }
                                          
                                           
}
