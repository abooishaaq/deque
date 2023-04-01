import 'dart:ffi' as ffi;

// class Deque extends ffi.Struct {
//   external ffi.Pointer<ffi.Void> buf;

//   @ffi.Int64()
//   external int head;

//   @ffi.Int64()
//   external int tail;

//   @ffi.Int64()
//   external int count;

//   @ffi.Int64()
//   external int mincap;
// }

// for 64-bit systems
typedef DequePtr = ffi.Int64;
typedef Deque = int;

typedef DequeNewC = DequePtr Function(ffi.Int64 mincap);
typedef DequeNewDart = Deque Function(int mincap);

typedef DequePushC = ffi.Void Function(DequePtr self, ffi.Int64 value);
typedef DequePushDart = void Function(int self, int value);

typedef DequePopC = ffi.Int64 Function(DequePtr self);
typedef DequePopDart = int Function(int self);

typedef DequePrintC = ffi.Void Function(DequePtr self);
typedef DequePrintDart = void Function(int self);

typedef DequeAtC = ffi.Int64 Function(DequePtr self, ffi.Int64 index);
typedef DequeAtDart = int Function(int self, int index);

typedef DequeFinalizerC = ffi.Void Function(DequePtr self);
typedef DequeFinalizerDart = void Function(Deque self);

class DequeFin implements ffi.Finalizable {
  late final Deque ptr;

  DequeFin._(this.ptr);

  factory DequeFin.new(int mincap) {
    var ptr = lib.dequeNew(mincap);
    final dq = DequeFin._(ptr);
    _finalizer.attach(dq, ffi.Pointer.fromAddress(ptr), detach: dq);
    return dq;
  }

  void pushBack(int value) {
    lib.dequePushBack(ptr, value);
  }

  int popBack() {
    return lib.dequePopBack(ptr);
  }

  void print() {
    lib.dequePrint(ptr);
  }

  int at(int index) {
    return lib.dequeAt(ptr, index);
  }

  static final _finalizer = ffi.NativeFinalizer(lib.dequeFinalizer.cast());
}

class DequeLib {
  final ffi.DynamicLibrary _library;

  DequeLib(this._library);

  late final dequeNew =
      _library.lookupFunction<DequeNewC, DequeNewDart>('NewDeque1');
  late final dequePushBack =
      _library.lookupFunction<DequePushC, DequePushDart>('DequePushBack');
  late final dequePopBack =
      _library.lookupFunction<DequePopC, DequePopDart>('DequePopBack');
  late final dequePrint =
      _library.lookupFunction<DequePrintC, DequePrintDart>('PrintDeque');
  late final dequeAt =
      _library.lookupFunction<DequeAtC, DequeAtDart>('DequeAt');
  late final dequeFinalizer =
      _library.lookup<ffi.NativeFunction<DequeFinalizerC>>('DequeFinalizer');
  late final deleteDeque = dequeFinalizer.asFunction<DequeFinalizerDart>();
}

const dequeSize = 10;

// gets killed... dart doesn't gc the objects
const dequeCount1 = 1000000;

// we see the objects getting freed
const dequeCount2 = 1000;

final lib = new DequeLib(ffi.DynamicLibrary.open('./deque.so'));

void main(List<String> args) {
  DequeFin dq = DequeFin.new(dequeSize);
  for (int i = 0; i < dequeSize; i++) {
    dq.pushBack(i);
  }
  dq.print();
  print("dq.at(0) = ${dq.at(0)}");
  print("dq.popBack() = ${dq.popBack()}");
  dq.print();

  for (int i = 0; i < dequeCount2; i++) {
    final dq = DequeFin.new(dequeSize);
    for (int i = 0; i < dequeSize; i++) {
      dq.pushBack(i);
    }
  }
}
