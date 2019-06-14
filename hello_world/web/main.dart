import 'dart:html';
import 'package:gamedev/game1.dart' as game1;

void runGame1(){
  CanvasElement canvas = querySelector("#canvas");
  CanvasRenderingContext2D ctx = canvas.getContext('2d');
  game1.Keyboard keyboard = game1.Keyboard();
  var game = game1.Game(canvas.width, canvas.height, ctx);
  game.run(keyboard);
}

void main() {
  
}



