import 'dart:html';
import 'package:hello_world/asset_manager.dart';

void main() {
  int result = add(3,4);
  querySelector('#output').text = 'Your Dart app is running. ${result}';
  print("aaaaaaaaaaaa");

  loadJson("http://127.0.0.1:8080/resources/small_cards.json").listen((data){
    print(data.name);
    print(data.url);
    print(data.percentage());
    print(data.isComplete());
  }, onError: (err)=>print(err), onDone: ()=>print("done"));
}
