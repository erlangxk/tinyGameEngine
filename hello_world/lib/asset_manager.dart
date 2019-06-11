import 'dart:html';
import 'dart:convert';
import 'dart:async';

int add(int a, int b)=> a+b;

abstract class Event {
  final String url;
  final String name;
  const Event(this.url, this.name);
  

  bool isComplete();
  double percentage();
}



class OngoingEvent extends Event {
  final int total;
  final int loaded;
  final bool computable;

  const OngoingEvent(String url, this.total, this.loaded,this.computable):super(url,"OngoingEvent");

  double percentage() =>computable?loaded/total: null;

  bool isComplete() => computable && total == loaded;     
}

class CompleteEvent<T> extends Event {
  final T data;
  const CompleteEvent(String url, this.data):super(url,"CompleteEvent");

  bool isComplete() => true;

  double percentage() => 1.0;
}

class ErrorEvent<E> extends Event {
  final E error;
  const ErrorEvent(String url, this.error):super(url,"ErrorEvent");
  
  bool isComplete() =>false;
  double percentage() => null;
}

Stream<Event> loadJson(String url) {
      var sc = StreamController<Event>();

      void startLoading(){
        HttpRequest.getString(url, onProgress: (event){
          sc.add(OngoingEvent(url, event.total, event.loaded,event.lengthComputable));
        }).then((js){
          sc.add(CompleteEvent(url,json.decode(js)));
          sc.close();
        }).catchError((err){
          sc.add(ErrorEvent(url, err));
          sc.close();
        });
      }

      sc.onListen =  startLoading;
      return sc.stream;
}
