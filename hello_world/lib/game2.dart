//https://dart.academy/web-games-with-dart-hangman/
import 'dart:async';
import 'dart:html';

const List<String> wordList = const [
  "PLENTY",
  "ACHIEVE",
  "CLASS",
  "STARE",
  "AFFECT",
  "THICK",
  "CARRIER",
  "BILL",
  "SAY",
  "ARGUE",
  "OFTEN",
  "GROW",
  "VOTING",
  "SHUT",
  "PUSH",
  "FANTASY",
  "PLAN",
  "LAST",
  "ATTACK",
  "COIN",
  "ONE",
  "STEM",
  "SCAN",
  "ENHANCE",
  "PILL",
  "OPPOSED",
  "FLAG",
  "RACE",
  "SPEED",
  "BIAS",
  "HERSELF",
  "DOUGH",
  "RELEASE",
  "SUBJECT",
  "BRICK",
  "SURVIVE",
  "LEADING",
  "STAKE",
  "NERVE",
  "INTENSE",
  "SUSPECT",
  "WHEN",
  "LIE",
  "PLUNGE",
  "HOLD",
  "TONGUE",
  "ROLLING",
  "STAY",
  "RESPECT",
  "SAFELY"
];

const List<String> imageList = const [
  "https://i.imgur.com/kReMv94.png",
  "https://i.imgur.com/UFP8RM4.png",
  "https://i.imgur.com/9McnEXg.png",
  "https://i.imgur.com/vNAW0pa.png",
  "https://i.imgur.com/8UFWc9q.png",
  "https://i.imgur.com/rHCgIvU.png",
  "https://i.imgur.com/CtvIEMS.png",
  "https://i.imgur.com/Z2mPdX0.png"
];

const String winImage = "https://i.imgur.com/QYKuNwB.png";

class HangmanGame {
  static const int hanged = 7;
  final List<String> wordList;
  final Set<String> lettersGuessed = new Set<String>();

  List<String> _wordToGuess;
  int _wrongGuesses;

  int get wrongGuesses => _wrongGuesses;
  List<String> get wordToGuess => _wordToGuess;
  String get fullWord => wordToGuess.join();

  String get wordForDisplay => wordToGuess
      .map((String letter) => lettersGuessed.contains(letter) ? letter : "_")
      .join();

  bool get isWordComplete {
    return _wordToGuess.every(lettersGuessed.contains);
  }

  StreamController<Event> _eventStreamCtrl =
      new StreamController<Event>.broadcast();
  Stream<Event> get eventStream => _eventStreamCtrl.stream;

  HangmanGame(List<String> words) : wordList = List<String>.from(words);

  void newGame() {
    wordList.shuffle();
    _wordToGuess = wordList.first.split('');
    _wrongGuesses = 0;
    lettersGuessed.clear();
    _eventStreamCtrl.add(ChangeEvent(wordForDisplay));
  }

  void guessLetter(String letter) {
    lettersGuessed.add(letter);
    if (_wordToGuess.contains(letter)) {
      _eventStreamCtrl.add(RightEvent(letter));
      if (isWordComplete) {
        _eventStreamCtrl.add(ChangeEvent(fullWord));
        _eventStreamCtrl.add(WinEvent());
      } else {
        _eventStreamCtrl.add(ChangeEvent(wordForDisplay));
      }
    } else {
      _wrongGuesses++;
      _eventStreamCtrl.add(WrongEvent(_wrongGuesses));
      if (_wrongGuesses == hanged) {
        _eventStreamCtrl.add(ChangeEvent(fullWord));
        _eventStreamCtrl.add(LoseEvent());
      }
    }
  }
}

enum EventType { win, lose, wrong, right, change }

class Event {
  final EventType eventType;
  const Event(this.eventType);
}

class WinEvent extends Event {
  WinEvent() : super(EventType.win);
}

class LoseEvent extends Event {
  LoseEvent() : super(EventType.lose);
}

class WrongEvent extends Event {
  final int times;
  const WrongEvent(this.times) : super(EventType.wrong);
}

class RightEvent extends Event {
  final String letter;
  const RightEvent(this.letter) : super(EventType.right);
}

class ChangeEvent extends Event {
  final String value;
  const ChangeEvent(this.value) : super(EventType.change);
}

class UI {
  final HangmanGame game;

  static List<String> generateAlphabet() {
    int startingCharCode = 'A'.codeUnits.first;
    var charCodes = List<int>.generate(26, (index) => startingCharCode + index);
    return charCodes.map((code) => String.fromCharCode(code)).toList();
  }

  ImageElement get gallowsRef => querySelector("#gallows");
  DivElement get wordRef => querySelector("#word");
  DivElement get lettersRef => querySelector("#letters");
  ButtonElement get newGameRef => querySelector("#new-game");

  UI(this.game) {
    game.eventStream.listen((event) {
      switch (event.eventType) {
        case EventType.change:
          updateWordDisplay((event as ChangeEvent).value);
          break;
        case EventType.wrong:
          updateGallowsImage((event as WrongEvent).times);
          break;
        case EventType.win:
          win();
          break;
        case EventType.lose:
          gameOver();
          break;
        case EventType.right:
          break;
      }
    });
    newGameRef.onClick.listen((e) {
      newGame();
    });
    createLeeterButtons();
    newGame();
  }

  void createLeeterButtons() {
    generateAlphabet().forEach((String letter) {
      lettersRef.append(new ButtonElement()
        ..classes.add("letter-btn")
        ..text = letter
        ..onClick.listen((MouseEvent event) {
          (event.target as ButtonElement).disabled = true;
          game.guessLetter(letter);
        }));
    });
  }

  void enableLetterButtons([bool enable = true]) {
    lettersRef.children
        .forEach((Element btn) => (btn as ButtonElement).disabled = !enable);
  }

  void updateWordDisplay(String word) {
    wordRef.text = word;
  }

  void updateGallowsImage(int wrongGuesses) {
    gallowsRef.src = imageList[wrongGuesses];
  }

  void gameOver() {
    enableLetterButtons(false);
    newGameRef.hidden = false;
  }

  void win() {
    gallowsRef.src = winImage;
    gameOver();
  }

  void newGame() {
    game.newGame();
    enableLetterButtons();
    newGameRef.hidden = true;
    updateGallowsImage(0);
  }
}

void runGame2() {
  UI(HangmanGame(wordList));
}
