import 'package:hello_world/hello_world.dart' as hello_world;
import 'package:rxdart/rxdart.dart';

main(List<String> arguments) {
  print('Hello world: ${hello_world.calculate()}!');

  var n = (arguments.length == 1) ? int.parse(arguments.first) : 10;
  
  const seed = const IndexedPair(1, 1, 0);

  Observable.range(1,n).scan((IndexedPair seq, _,__)=>IndexedPair.next(seq),seed).listen(print, onDone:()=>print("done"));

}

class IndexedPair {
  final int n1, n2, index;

  const IndexedPair(this.n1, this.n2, this.index);

  factory IndexedPair.next(IndexedPair prev) => IndexedPair(prev.n2, prev.index <= 1 ? prev.n1 : prev.n1 + prev.n2, prev.index + 1);

  @override 
  String toString() => '$index: $n2';
}
