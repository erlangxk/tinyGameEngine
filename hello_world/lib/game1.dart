import 'dart:html';
import 'dart:math';
import 'dart:async';

const int CELL_SIZE = 10;

typedef void DrawFunction(CanvasRenderingContext2D ctx);

DrawFunction drawCell(Point corrds, String color) {
  return (CanvasRenderingContext2D ctx) {
    ctx
      ..fillStyle = color
      ..strokeStyle = "white";

    final int x = corrds.x * CELL_SIZE;
    final int y = corrds.y * CELL_SIZE;

    ctx
      ..fillRect(x, y, CELL_SIZE, CELL_SIZE)
      ..strokeRect(x, y, CELL_SIZE, CELL_SIZE);
  };
}

DrawFunction clear(int width, int height) {
  return (CanvasRenderingContext2D ctx) {
    ctx
      ..fillStyle = "white"
      ..fillRect(0, 0, width, height);
  };
}

class Keyboard {
  final Set<int> _keys = Set<int>();

  Keyboard() {
    window.onKeyDown.listen((KeyboardEvent event) {
      _keys.add(event.keyCode);
    });

    window.onKeyUp.listen((KeyboardEvent event) {
      _keys.remove(event.keyCode);
    });
  }

  bool isPressed(int keyCode) => _keys.contains(keyCode);
}

class Direction {
  static const LEFT = const Point(-1, 0);
  static const RIGHT = const Point(1, 0);
  static const UP = const Point(0, -1);
  static const DOWN = const Point(0, 1);

  static Point<int> change(Keyboard keyboard, Point currDir) {
    if (keyboard.isPressed(KeyCode.LEFT) && currDir != RIGHT) {
      return LEFT;
    } else if (keyboard.isPressed(KeyCode.RIGHT) && currDir != LEFT) {
      return RIGHT;
    } else if (keyboard.isPressed(KeyCode.UP) && currDir != DOWN) {
      return UP;
    } else if (keyboard.isPressed(KeyCode.DOWN) && currDir != UP) {
      return DOWN;
    } else {
      return currDir;
    }
  }
}

class Snake {
  static const int START_LENGTH = 6;
  int maxX;
  int maxY;

  var _dir = Direction.RIGHT;
  List<Point> _body;

  Snake(this.maxX, this.maxY) {
    _body = List<Point>.generate(
        START_LENGTH, (int idx) => Point(START_LENGTH - idx - 1, 0));
  }

  Point get head => _body.first;

  void _checkInput(Keyboard keyboard) {
    _dir = Direction.change(keyboard, _dir);
  }

  void grow() {
    _body.insert(0, head + _dir);
  }

  void _move() {
    grow();
    _body.removeLast();
  }

  void _draw(CanvasRenderingContext2D ctx) {
    for (Point p in _body) {
      drawCell(p, "green")(ctx);
    }
  }

  bool biteItself() {
    return _body.skip(1).any((p) => p == head);
  }

  void update(CanvasRenderingContext2D ctx, Keyboard keyboard) {
    _checkInput(keyboard);
    _move();
    _draw(ctx);
  }

  bool hitEdge() {
    return head.x < 0 || head.x >= maxX || head.y < 0 || head.y >= maxY;
  }
}

typedef Point GenFood();
GenFood foodGen(int maxX, int maxY) {
  Random _random = Random();
  return () {
    return Point(_random.nextInt(maxX), _random.nextInt(maxY));
  };
}

class Game {
  static const num GAME_SPEED = 50;

  int width;
  int height;
  GenFood _foodGen;

  DrawFunction _clear;

  Snake _snake;
  Point _food;
  num _lastTimeStamp = 0;

  Game(this.width, this.height) {
    final maxX = width ~/ CELL_SIZE;
    final maxY = height ~/ CELL_SIZE;
    _foodGen = foodGen(maxX, maxY);
    _snake = new Snake(maxX, maxY);
    _clear = clear(width, height);
    _food = _foodGen();
  }

  void _checkForCollisions() {
    if (_snake.head == _food) {
      _snake.grow();
      _food = _foodGen();
    }

    if (_snake.hitEdge() || _snake.biteItself()) {
      _snake = new Snake(width ~/ CELL_SIZE, height ~/ CELL_SIZE);
      _food = _foodGen();
    }
  }

  Future run(CanvasRenderingContext2D ctx, Keyboard keyboard) async {
    var timeElasped = await window.animationFrame;
    update(timeElasped, ctx, keyboard);
  }

  void update(
      num timeElapsed, CanvasRenderingContext2D ctx, Keyboard keyboard) {
    final diff = timeElapsed - _lastTimeStamp;
    if (diff > GAME_SPEED) {
      _lastTimeStamp = timeElapsed;
      _clear(ctx);
      drawCell(_food, "blue")(ctx);
      _snake.update(ctx, keyboard);
      _checkForCollisions();
    }
    run(ctx, keyboard);
  }
}
