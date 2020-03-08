import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //material app widget
    return MaterialApp(
      title: 'Crypto Price List',
      theme: new ThemeData(primaryColor: Colors.white),
      home: CryptoList(),
    ); //use our widget instead of the text previously
  }
}

//creates a stateful widget (data inside will change once created)
class CryptoList extends StatefulWidget {
  @override
  CryptoListState createState() => CryptoListState();
}

class CryptoListState extends State {
  List _cryptoList; //store cryptolist
  final _saved = Set(); //store favourited cryptos
  final _boldStyle =
  new TextStyle(fontWeight: FontWeight.bold , color: Colors.red); //bold text style to be reused
  bool _loading = false; //will be used later to control state
  final List _colors = [
    //to show different colors for different cryptos
    Colors.blue,
    Colors.indigo,
    Colors.lime,
    Colors.teal,
    Colors.cyan
  ];
  //this means that the function will be executed sometime in the future (in this case does not return data)
  Future getCryptoPrices() async {
    //async to use await, which suspends the current function, while it does other stuff and resumes when data ready
    String _apiURL =
        "https://api.nomics.com/v1/currencies/ticker?key=91fe3be20d480b55ee3e6781f636579b"; //url to get data
    setState(() {
      this._loading = true; //before calling the api, set the loading to true
    });
    http.Response response = await http.get(_apiURL); //waits for response
    setState(() {
      this._cryptoList =
          jsonDecode(response.body); //sets the state of our widget
      this._loading = false;
    });
    return;
  }

  //takes in an object and returns the price with 2 decimal places
  String cryptoPrice(Map crypto) {
    int decimals = 2;
    int fac = pow(10, decimals);
    double d = double.parse(crypto['price']);
    return "\$" + (d = (d * fac).round() / fac).toString();
  }

  // takes in an object and color and returns a circle avatar with first letter and required color
  CircleAvatar _getLeadingWidget(String image , String name, MaterialColor color) {
    bool im = image.contains('svg');
    try{
      if(im && !(image.isEmpty) ){
        return new CircleAvatar(
          radius: 30.0,
          backgroundColor: Colors.transparent,
          child: new SvgPicture.network(image),
        );
      }
      else if(im == false && !(image.isEmpty)){
        return new CircleAvatar(
          /*backgroundColor: color,
      child: new Text(name[0]),*/
          radius: 30.0,
          backgroundColor: Colors.transparent,
          backgroundImage: NetworkImage(image),
        );
      }
      else if(image.isEmpty){
        return new CircleAvatar(
          radius: 30.0,
          backgroundColor: color,
          child: new Text(name[0]),
        );

      }
    }
    catch(e){
      return new CircleAvatar(
        radius: 30.0,
        backgroundColor: color,
        child: new Text(name[0]),
      );
    }


  }

  @override
  void initState() {
    //override creation of state so that we can call our function
    super.initState();
    getCryptoPrices(); //this function is called which then sets the state of our app
  }

//build method
  @override
  Widget build(BuildContext context) {
    //Implements the basic Material Design visual layout structure.
    //This class provides APIs for showing drawers, snack bars, and bottom sheets.
    return Scaffold(
      appBar: AppBar(
        title: Text('CryptoList'),
        backgroundColor: Colors.amber,
        actions: [
          // will be used to view favourites
          new IconButton(icon: const Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      body:
      Container(
          color: Colors.black,
          child: _getMainBody(),
      ),
    );
    /*_buildCryptoList());*/

  }
  _getMainBody() {
    if (_loading) { //return progress indicator if it is loading
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      return _buildCryptoList(); //return the list view
    }
  }

  //will be used later to view favourited cryptos
  void _pushSaved() {}

  //widget that builds the list
  Widget _buildCryptoList() {
    return ListView.builder(
        itemCount: _cryptoList
            .length, //set the item count so that index won't be out of range
        padding:
        const EdgeInsets.all(16.0), //add some padding to make it look good
        itemBuilder: (context, i) {
          //item builder returns a row for each index i=0,1,2,3,4
          // if (i.isOdd) return Divider(); //if index = 1,3,5 ... return a divider to make it visually appealing

          // final index = i ~/ 2; //get the actual index excluding dividers.
          final index = i;
          print(index);
          final MaterialColor color = _colors[index %
              _colors.length]; //iterate through indexes and get the next colour
          return _buildRow(_cryptoList[index], color); //build the row widget
        });
  }

  Widget _buildRow(Map crypto, MaterialColor color) {
    // if _saved contains our crypto, return true
    final bool favourited = _saved.contains(crypto);

    // function to handle when heart icon is tapped
    void _fav() {
      setState(() {
        if (favourited) {
          //if it is favourited previously, remove it from the list
          _saved.remove(crypto);
        } else {
          _saved.add(crypto); //else add it to the array
        }
      });
    }

    // returns a row with the desired properties
    return ListTile(
      leading: _getLeadingWidget(crypto['logo_url'] , crypto['name'],
          color), // get the first letter of each crypto with the color
      title: Text(
        crypto['name'],
        style: TextStyle(
          color: Colors.white,
        ),
      ), //title to be name of the crypto
      subtitle: Text(
        //subtitle is below title, get the price in 2 decimal places and set style to bold
        cryptoPrice(crypto),
        style: _boldStyle,
      ),
      trailing: new IconButton(
        //at the end of the row, add an icon button
        // Add the lines from here...
        icon: Icon(favourited
            ? Icons.favorite
            : Icons
            .favorite_border), // if button is favourited, show favourite icon
        color:
        favourited ? Colors.red : Colors.white, // if button is favourited, show red
        onPressed: _fav, //when pressed, let _fav function handle
      ),
    );
  }
}
