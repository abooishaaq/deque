package main

/*
#include <stdlib.h>
*/
import "C"

import (
	"encoding/binary"
	"fmt"
	"reflect"
	"unsafe"

	"github.com/gammazero/deque"
)

// this is wrapper for deque

func goint_to_csize_t(i int) C.size_t {
	s := make([]byte, 8)
	binary.LittleEndian.PutUint32(s, uint32(i))
	return C.size_t(binary.LittleEndian.Uint64(s))
}

//export NewDeque1
func NewDeque1(size int) unsafe.Pointer {
	fmt.Println("NewDeque with size", size)
	d := deque.New[int64](size)
	r := reflect.ValueOf(*d)
	s := binary.Size(r)
	mem := C.malloc(goint_to_csize_t(s))
	*(*deque.Deque[int64])(mem) = *d
	return (unsafe.Pointer)(mem)
}

//export NewDeque2
func NewDeque2(size int, mincap int) unsafe.Pointer {
	d := deque.New[int64](size, mincap)
	r := reflect.ValueOf(*d)
	s := binary.Size(r)
	mem := C.malloc(goint_to_csize_t(s))
	*(*deque.Deque[int64])(mem) = *d
	return (unsafe.Pointer)(mem)
}

//export DequePushBack
func DequePushBack(d unsafe.Pointer, v int64) {
	(*deque.Deque[int64])(d).PushBack(v)
}

//export DequePushFront
func DequePushFront(d unsafe.Pointer, v int64) {
	(*deque.Deque[int64])(d).PushFront(v)
}

//export DequePopBack
func DequePopBack(d unsafe.Pointer) int64 {
	return (*deque.Deque[int64])(d).PopBack()
}

//export DequePopFront
func DequePopFront(d unsafe.Pointer) int64 {
	return (*deque.Deque[int64])(d).PopFront()
}

//export PrintDeque
func PrintDeque(ptr unsafe.Pointer) {
	d := (*deque.Deque[int64])(ptr)
	for i := 0; i < d.Len(); i++ {
		fmt.Print(d.At(i), " ")
	}
	fmt.Println()
}

//export DequeAt
func DequeAt(ptr unsafe.Pointer, i int) int64 {
	d := (*deque.Deque[int64])(ptr)
	return d.At(i)
}

//export DequeFinalizer
func DequeFinalizer(d unsafe.Pointer) {
	dque := (*deque.Deque[int64])(d)
	dque.Clear()
	C.free(d)
	fmt.Println("freed")
}

func main() {
	fmt.Println("main")
}
