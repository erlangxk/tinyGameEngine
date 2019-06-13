import 'dart:html';
import 'package:gamedev/game1.dart';


void main() {
  CanvasElement canvas = querySelector("#canvas");
  CanvasRenderingContext2D ctx = canvas.getContext('2d');

  var game=Game(canvas.width, canvas.height);
  game.run(ctx);

}

