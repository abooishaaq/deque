# gammazero/deque bindings for dart

provides a [gammazero/deque](https://github.com/gammazero/deque) bindings for dart.
This is to show how [GOgen](https://github.com/dart-lang/sdk/wiki/Dart-GSoC-2023-Project-Ideas#idea-gogen-or-rustgen-or-) generated dart bindings for go packages would look like.

## usage

- `go get github.com/gammazero/deque`
- `go build -buildmode=c-shared -o deque.so deque.go`
- `dart run deque.dart`

## issue

dart doesn't gc `DequeFin` until the program exits hence if we allocate a lot of `DequeFin` objects, the program will crash.
