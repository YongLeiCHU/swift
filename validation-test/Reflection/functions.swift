// RUN: rm -rf %t && mkdir -p %t
// RUN: %target-build-swift -lswiftSwiftReflectionTest %s -o %t/functions
// RUN: %target-run %target-swift-reflection-test %t/functions | FileCheck %s --check-prefix=CHECK --check-prefix=CHECK-%target-ptrsize

// FIXME: Should not require objc_interop -- please put Objective-C-specific
// testcases in functions_objc.swift

// REQUIRES: objc_interop
// REQUIRES: executable_test
// REQUIRES: rdar26561954

/*
   This file pokes at the swift_reflection_infoForInstance() API
   of the SwiftRemoteMirror library.

   It tests introspection of function closure contexts.

   - See also: SwiftReflectionTest.reflect(function:)
*/

import SwiftReflectionTest

func concrete(x: Int, y: Any) {
  reflect(function: {print(x)})
// CHECK:         Type reference:
// CHECK-NEXT:    (builtin Builtin.NativeObject)

// CHECK-32:      Type info:
// CHECK-32-NEXT: (closure_context size=16 alignment=4 stride=16 num_extra_inhabitants=0
// CHECK-32-NEXT:   (field offset=12
// CHECK-32-NEXT:     (struct size=4 alignment=4 stride=4 num_extra_inhabitants=0
// CHECK-32-NEXT:       (field name=_value offset=0
// CHECK-32-NEXT:         (builtin size=4 alignment=4 stride=4 num_extra_inhabitants=0)))))

// CHECK-64:      Type info:
// CHECK-64-NEXT: (closure_context size=24 alignment=8 stride=24 num_extra_inhabitants=0
// CHECK-64-NEXT:   (field offset=16
// CHECK-64-NEXT:     (struct size=8 alignment=8 stride=8 num_extra_inhabitants=0
// CHECK-64-NEXT:       (field name=_value offset=0
// CHECK-64-NEXT:         (builtin size=8 alignment=8 stride=8 num_extra_inhabitants=0)))))

  // Here the context is a single boxed value
  reflect(function: {print(y)})
// CHECK:         Type reference:
// CHECK-NEXT:    (builtin Builtin.NativeObject)

// CHECK-32:      Type info:
// CHECK-32-NEXT: (closure_context size=28 alignment=4 stride=28 num_extra_inhabitants=0
// CHECK-32-NEXT:   (field offset=12
// CHECK-32-NEXT:     (opaque_existential size=16 alignment=4 stride=16 num_extra_inhabitants=0
// CHECK-32-NEXT:       (field name=value offset=0
// CHECK-32-NEXT:         (builtin size=4 alignment=4 stride=4 num_extra_inhabitants=1))
// CHECK-32-NEXT:       (field name=value offset=4
// CHECK-32-NEXT:         (builtin size=4 alignment=4 stride=4 num_extra_inhabitants=1))
// CHECK-32-NEXT:       (field name=value offset=8
// CHECK-32-NEXT:         (builtin size=4 alignment=4 stride=4 num_extra_inhabitants=1))
// CHECK-32-NEXT:       (field name=metadata offset=12
// CHECK-32-NEXT:         (builtin size=4 alignment=4 stride=4 num_extra_inhabitants=1)))))

// CHECK-64:      Type info:
// CHECK-64-NEXT: (closure_context size=48 alignment=8 stride=48 num_extra_inhabitants=0
// CHECK-64-NEXT:   (field offset=16
// CHECK-64-NEXT:     (opaque_existential size=32 alignment=8 stride=32 num_extra_inhabitants=0
// CHECK-64-NEXT:       (field name=value offset=0
// CHECK-64-NEXT:         (builtin size=8 alignment=8 stride=8 num_extra_inhabitants=1))
// CHECK-64-NEXT:       (field name=value offset=8
// CHECK-64-NEXT:         (builtin size=8 alignment=8 stride=8 num_extra_inhabitants=1))
// CHECK-64-NEXT:       (field name=value offset=16
// CHECK-64-NEXT:         (builtin size=8 alignment=8 stride=8 num_extra_inhabitants=1))
// CHECK-64-NEXT:       (field name=metadata offset=24
// CHECK-64-NEXT:         (builtin size=8 alignment=8 stride=8 num_extra_inhabitants=1)))))
}

concrete(x: 10, y: true)

protocol P {}
extension Int : P {}

class C {}

func generic<T : P, U, V : C>(x: T, y: U, z: V, i: Int) {
  reflect(function: {print(i)})
// CHECK:         Type reference:
// CHECK-NEXT:    (builtin Builtin.NativeObject)

// CHECK-32:      Type info:
// CHECK-32-NEXT: (closure_context size=16 alignment=4 stride=16 num_extra_inhabitants=0
// CHECK-32-NEXT:   (field offset=12
// CHECK-32-NEXT:     (struct size=4 alignment=4 stride=4 num_extra_inhabitants=0
// CHECK-32-NEXT:       (field name=_value offset=0
// CHECK-32-NEXT:         (builtin size=4 alignment=4 stride=4 num_extra_inhabitants=0)))))

// CHECK-64:      Type info:
// CHECK-64-NEXT: (closure_context size=24 alignment=8 stride=24 num_extra_inhabitants=0
// CHECK-64-NEXT:   (field offset=16
// CHECK-64-NEXT:     (struct size=8 alignment=8 stride=8 num_extra_inhabitants=0
// CHECK-64-NEXT:       (field name=_value offset=0
// CHECK-64-NEXT:         (builtin size=8 alignment=8 stride=8 num_extra_inhabitants=0)))))

  reflect(function: {print(x); print(y); print(z)})
// CHECK:         Type reference:
// CHECK-NEXT:    (builtin Builtin.NativeObject)

// CHECK-32:      Type info:
// CHECK-32-NEXT: (closure_context size=40 alignment=4 stride=40 num_extra_inhabitants=0
// CHECK-32-NEXT:   (field offset=28
// CHECK-32-NEXT:     (reference kind=strong refcounting=native))
// CHECK-32-NEXT:   (field offset=32
// CHECK-32-NEXT:     (reference kind=strong refcounting=native))
// CHECK-32-NEXT:   (field offset=36
// CHECK-32-NEXT:     (reference kind=strong refcounting=native)))

// CHECK-64:      Type info:
// CHECK-64-NEXT: (closure_context size=72 alignment=8 stride=72 num_extra_inhabitants=0
// CHECK-64-NEXT:   (field offset=48
// CHECK-64-NEXT:     (reference kind=strong refcounting=native))
// CHECK-64-NEXT:   (field offset=56
// CHECK-64-NEXT:     (reference kind=strong refcounting=native))
// CHECK-64-NEXT:   (field offset=64
// CHECK-64-NEXT:     (reference kind=strong refcounting=native)))
}

generic(x: 10, y: "", z: C(), i: 101)

class GC<A, B, C> {}

func genericWithSources<A, B, C>(a: A, b: B, c: C, gc: GC<A, B, C>) {
  reflect(function: {print(a); print(b); print(c); print(gc)})
// CHECK:         Type reference:
// CHECK-NEXT:    (builtin Builtin.NativeObject)

// CHECK-32:      Type info:
// CHECK-32-NEXT: (closure_context size=28 alignment=4 stride=28 num_extra_inhabitants=0
// CHECK-32-NEXT:   (field offset=12
// CHECK-32-NEXT:     (reference kind=strong refcounting=native))
// CHECK-32-NEXT:   (field offset=16
// CHECK-32-NEXT:     (reference kind=strong refcounting=native))
// CHECK-32-NEXT:   (field offset=20
// CHECK-32-NEXT:     (reference kind=strong refcounting=native))
// CHECK-32-NEXT:   (field offset=24
// CHECK-32-NEXT:     (reference kind=strong refcounting=native)))

// CHECK-64:      Type info:
// CHECK-64-NEXT: (closure_context size=48 alignment=8 stride=48 num_extra_inhabitants=0
// CHECK-64-NEXT:   (field offset=16
// CHECK-64-NEXT:     (reference kind=strong refcounting=native))
// CHECK-64-NEXT:   (field offset=24
// CHECK-64-NEXT:     (reference kind=strong refcounting=native))
// CHECK-64-NEXT:   (field offset=32
// CHECK-64-NEXT:     (reference kind=strong refcounting=native))
// CHECK-64-NEXT:   (field offset=40
// CHECK-64-NEXT:     (reference kind=strong refcounting=native)))
}

genericWithSources(a: (), b: ((), ()), c: ((), (), ()), gc: GC<(), ((), ()), ((), (), ())>())


class CapturingClass {

  // CHECK-64: Reflecting an object.
  // CHECK-64: Type reference:
  // CHECK-64: (class functions.CapturingClass)
 
  // CHECK-64: Type info:
  // CHECK-64: (class_instance size=16 alignment=16 stride=16 num_extra_inhabitants=0)
  
  // CHECK-32: Reflecting an object.
  // CHECK-32: Type reference:
  // CHECK-32: (class functions.CapturingClass)
  
  // CHECK-32: Type info:
  // CHECK-32: (class_instance size=12 alignment=16 stride=16 num_extra_inhabitants=0)
  func arity0Capture1() -> () -> () {
    let closure = {
      // Captures a single retainable reference.
      print(self)
    }
    reflect(function: closure)
    return closure
  }

  // CHECK-64: Reflecting an object.
  // CHECK-64: Type reference:
  // CHECK-64: (builtin Builtin.NativeObject)
  
  // CHECK-64:        Type info:
  // CHECK-64:        (closure_context size=32 alignment=8 stride=32 num_extra_inhabitants=0
  // CHECK-64-NEXT:   (field offset=16
  // CHECK-64-NEXT:     (tuple size=16 alignment=8 stride=16 num_extra_inhabitants=0
  // CHECK-64-NEXT:       (field offset=0
  // CHECK-64-NEXT:         (struct size=8 alignment=8 stride=8 num_extra_inhabitants=0
  // CHECK-64-NEXT:           (field name=_value offset=0
  // CHECK-64-NEXT:             (builtin size=8 alignment=8 stride=8 num_extra_inhabitants=0))))
  // CHECK-64-NEXT:       (field offset=8
  // CHECK-64-NEXT:         (struct size=8 alignment=8 stride=8 num_extra_inhabitants=0
  // CHECK-64-NEXT:           (field name=_value offset=0
  // CHECK-64-NEXT:             (builtin size=8 alignment=8 stride=8 num_extra_inhabitants=0)))))))

  // CHECK-32: Reflecting an object.
  // CHECK-32: Type reference:
  // CHECK-32: (builtin Builtin.NativeObject)

  // CHECK-32:        Type info:
  // CHECK-32:        (closure_context size=32 alignment=8 stride=32 num_extra_inhabitants=0
  // CHECK-32-NEXT:   (field offset=16
  // CHECK-32-NEXT:     (tuple size=16 alignment=8 stride=16 num_extra_inhabitants=0
  // CHECK-32-NEXT:       (field offset=0
  // CHECK-32-NEXT:         (struct size=4 alignment=4 stride=4 num_extra_inhabitants=0
  // CHECK-32-NEXT:           (field name=_value offset=0
  // CHECK-32-NEXT:             (builtin size=4 alignment=4 stride=4 num_extra_inhabitants=0))))
  // CHECK-32-NEXT:       (field offset=8
  // CHECK-32-NEXT:         (struct size=8 alignment=8 stride=8 num_extra_inhabitants=0
  // CHECK-32-NEXT:           (field name=_value offset=0
  // CHECK-32-NEXT:             (builtin size=8 alignment=8 stride=8 num_extra_inhabitants=0)))))))
  func arity1Capture1() -> (Int) -> () {
    let pair = (2, 333.0)
    let closure = { (i: Int) in
      print(pair)
    }
    reflect(function: closure)
    return closure
  }

  // CHECK-64: Reflecting an object.
  // CHECK-64: Type reference:
  // CHECK-64: (builtin Builtin.NativeObject)

  // CHECK-64:      Type info:
  // CHECK-64:      (closure_context size=32 alignment=8 stride=32 num_extra_inhabitants=0
  // CHECK-64-NEXT: (field offset=16
  // CHECK-64-NEXT:   (tuple size=16 alignment=8 stride=16 num_extra_inhabitants=0
  // CHECK-64-NEXT:     (field offset=0
  // CHECK-64-NEXT:       (struct size=8 alignment=8 stride=8 num_extra_inhabitants=0
  // CHECK-64-NEXT:         (field name=_value offset=0
  // CHECK-64-NEXT:           (builtin size=8 alignment=8 stride=8 num_extra_inhabitants=0))))
  // CHECK-64-NEXT:     (field offset=8
  // CHECK-64-NEXT:       (reference kind=strong refcounting=native)))))

  // CHECK-32: Reflecting an object.
  // CHECK-32: Type reference:
  // CHECK-32: (builtin Builtin.NativeObject)
  
  // CHECK-32:        Type info:
  // CHECK-32:        (closure_context size=20 alignment=4 stride=20 num_extra_inhabitants=0
  // CHECK-32-NEXT:   (field offset=12
  // CHECK-32-NEXT:     (tuple size=8 alignment=4 stride=8 num_extra_inhabitants=0
  // CHECK-32-NEXT:       (field offset=0
  // CHECK-32-NEXT:         (struct size=4 alignment=4 stride=4 num_extra_inhabitants=0
  // CHECK-32-NEXT:           (field name=_value offset=0
  // CHECK-32-NEXT:             (builtin size=4 alignment=4 stride=4 num_extra_inhabitants=0))))
  // CHECK-32-NEXT:       (field offset=4
  // CHECK-32-NEXT:         (reference kind=strong refcounting=native)))))
  func arity2Capture1() -> (Int, String) -> () {
   let pair = (999, C())
   let closure = { (i: Int, s: String) in
     print(pair)
   }

   reflect(function: closure)
   return closure
  }

  // CHECK-64: Reflecting an object.
  // CHECK-64: Type reference:
  // CHECK-64: (builtin Builtin.NativeObject)
  
  // CHECK-64:        Type info:
  // CHECK-64:        (closure_context size=24 alignment=8 stride=24 num_extra_inhabitants=0
  // CHECK-64-NEXT:   (field offset=16
  // CHECK-64-NEXT:     (class_existential size=8 alignment=8 stride=8 num_extra_inhabitants=2147483647
  // CHECK-64-NEXT:       (field name=object offset=0
  // CHECK-64-NEXT:         (reference kind=strong refcounting=unknown)))))

  // CHECK-32: Reflecting an object.
  // CHECK-32: Type reference:
  // CHECK-32: (builtin Builtin.NativeObject)
  
  // CHECK-32:        Type info:
  // CHECK-32:        (closure_context size=16 alignment=4 stride=16 num_extra_inhabitants=0
  // CHECK-32-NEXT:   (field offset=12
  // CHECK-32-NEXT:     (class_existential size=4 alignment=4 stride=4 num_extra_inhabitants=4096
  // CHECK-32-NEXT:       (field name=object offset=0
  // CHECK-32-NEXT:         (reference kind=strong refcounting=unknown)))))
  func arity3Capture1() -> (Int, String, AnyObject?) -> () {
    let c = Optional<AnyObject>.some(C() as AnyObject)
    let closure = { (i: Int, s: String, a: AnyObject?) in
      print(c)
    }
  
    reflect(function: closure)
    return closure
  }


  // CHECK-64: Reflecting an object.
  // CHECK-64: Type reference:
  // CHECK-64: (builtin Builtin.NativeObject)
  // CHECK-64:        Type info:
  // CHECK-64:        (closure_context size=40 alignment=8 stride=40 num_extra_inhabitants=0
  // CHECK-64-NEXT:   (field offset=16
  // CHECK-64-NEXT:     (reference kind=strong refcounting=native))
  // CHECK-64-NEXT:   (field offset=24
  // CHECK-64-NEXT:     (tuple size=16 alignment=8 stride=16 num_extra_inhabitants=0
  // CHECK-64-NEXT:       (field offset=0
  // CHECK-64-NEXT:         (struct size=8 alignment=8 stride=8 num_extra_inhabitants=0
  // CHECK-64-NEXT:           (field name=_value offset=0
  // CHECK-64-NEXT:             (builtin size=8 alignment=8 stride=8 num_extra_inhabitants=0))))
  // CHECK-64-NEXT:       (field offset=8
  // CHECK-64-NEXT:         (struct size=8 alignment=8 stride=8 num_extra_inhabitants=0
  // CHECK-64-NEXT:           (field name=_value offset=0
  // CHECK-64-NEXT:             (builtin size=8 alignment=8 stride=8 num_extra_inhabitants=0)))))))

  // CHECK-32: Reflecting an object.
  // CHECK-32: Type reference:
  // CHECK-32: (builtin Builtin.NativeObject)

  // CHECK-32:        Type info:
  // CHECK-32:        (closure_context size=32 alignment=8 stride=32 num_extra_inhabitants=0
  // CHECK-32-NEXT:   (field offset=12
  // CHECK-32-NEXT:     (reference kind=strong refcounting=native))
  // CHECK-32-NEXT:   (field offset=16
  // CHECK-32-NEXT:     (tuple size=16 alignment=8 stride=16 num_extra_inhabitants=0
  // CHECK-32-NEXT:       (field offset=0
  // CHECK-32-NEXT:         (struct size=4 alignment=4 stride=4 num_extra_inhabitants=0
  // CHECK-32-NEXT:           (field name=_value offset=0
  // CHECK-32-NEXT:             (builtin size=4 alignment=4 stride=4 num_extra_inhabitants=0))))
  // CHECK-32-NEXT:       (field offset=8
  // CHECK-32-NEXT:         (struct size=8 alignment=8 stride=8 num_extra_inhabitants=0
  // CHECK-32-NEXT:           (field name=_value offset=0
  // CHECK-32-NEXT:             (builtin size=8 alignment=8 stride=8 num_extra_inhabitants=0)))))))
  func arity0Capture2() -> () -> () {
   let pair = (999, 1010.2)
    let closure = {
      print(self)
      print(pair)
    }
    reflect(function: closure)
    return closure
  }

  // CHECK-64: Reflecting an object.
  // CHECK-64: Type reference:
  // CHECK-64: (builtin Builtin.NativeObject)
  
  // CHECK-64:        Type info:
  // CHECK-64:        (closure_context size=32 alignment=8 stride=32 num_extra_inhabitants=0
  // CHECK-64-NEXT:   (field offset=16
  // CHECK-64-NEXT:     (reference kind=strong refcounting=native))
  // CHECK-64-NEXT:   (field offset=24
  // CHECK-64-NEXT:     (reference kind=strong refcounting=native)))

  // CHECK-32: Reflecting an object.
  // CHECK-32: Type reference:
  // CHECK-32: (builtin Builtin.NativeObject)
  
  // CHECK-32: Type info:
  // CHECK-32: (closure_context size=20 alignment=4 stride=20 num_extra_inhabitants=0
  // CHECK-32:   (field offset=12
  // CHECK-32:     (reference kind=strong refcounting=native))
  // CHECK-32:   (field offset=16
  // CHECK-32:     (reference kind=strong refcounting=native)))
  func arity1Capture2() -> (Int) -> () {
   let x = Optional.some(C())
   let closure = { (i: Int) in 
     print(self)
     print(x)
   }
   reflect(function: closure)
   return closure
  }

  // CHECK-64: Reflecting an object.
  // CHECK-64: Type reference:
  // CHECK-64: (builtin Builtin.NativeObject)
  
  // CHECK-64: Type info:
  // CHECK-64: (closure_context size=40 alignment=8 stride=40 num_extra_inhabitants=0
  // CHECK-64:   (field offset=16
  // CHECK-64:     (reference kind=strong refcounting=native))
  // CHECK-64:   (field offset=24
  // CHECK-64:     (tuple size=16 alignment=8 stride=16 num_extra_inhabitants=0
  // CHECK-64:       (field offset=0
  // CHECK-64:         (struct size=8 alignment=8 stride=8 num_extra_inhabitants=0
  // CHECK-64:           (field name=_value offset=0
  // CHECK-64:             (builtin size=8 alignment=8 stride=8 num_extra_inhabitants=0))))
  // CHECK-64:       (field offset=8
  // CHECK-64:         (struct size=8 alignment=8 stride=8 num_extra_inhabitants=0
  // CHECK-64:           (field name=_value offset=0
  // CHECK-64:             (builtin size=8 alignment=8 stride=8 num_extra_inhabitants=0)))))))

  // CHECK-32: Reflecting an object.
  // CHECK-32: Type reference:
  // CHECK-32: (builtin Builtin.NativeObject)
  
  // CHECK-32: Type info:
  // CHECK-32: (closure_context size=32 alignment=8 stride=32 num_extra_inhabitants=0
  // CHECK-32:   (field offset=12
  // CHECK-32:     (reference kind=strong refcounting=native))
  // CHECK-32:   (field offset=16
  // CHECK-32:     (tuple size=16 alignment=8 stride=16 num_extra_inhabitants=0
  // CHECK-32:       (field offset=0
  // CHECK-32:         (struct size=4 alignment=4 stride=4 num_extra_inhabitants=0
  // CHECK-32:           (field name=_value offset=0
  // CHECK-32:             (builtin size=4 alignment=4 stride=4 num_extra_inhabitants=0))))
  // CHECK-32:       (field offset=8
  // CHECK-32:         (struct size=8 alignment=8 stride=8 num_extra_inhabitants=0
  // CHECK-32:           (field name=_value offset=0
  // CHECK-32:             (builtin size=8 alignment=8 stride=8 num_extra_inhabitants=0)))))))
  func arity2Capture2() -> (Int, String) -> () {
   let pair = (999, 1010.2)
   let closure = { (i: Int, s: String) in
     print(self)
     print(pair)
   }

   reflect(function: closure)
   return closure
  }

  // CHECK-64: Reflecting an object.
  // CHECK-64: Type reference:
  // CHECK-64: (builtin Builtin.NativeObject)
 
  // CHECK-64: Type info:
  // CHECK-64: (closure_context size=40 alignment=8 stride=40 num_extra_inhabitants=0
  // CHECK-64:   (field offset=16
  // CHECK-64:     (reference kind=strong refcounting=native))
  // CHECK-64:   (field offset=24
  // CHECK-64:     (tuple size=16 alignment=8 stride=16 num_extra_inhabitants=0
  // CHECK-64:       (field offset=0
  // CHECK-64:         (struct size=8 alignment=8 stride=8 num_extra_inhabitants=0
  // CHECK-64:           (field name=_value offset=0
  // CHECK-64:             (builtin size=8 alignment=8 stride=8 num_extra_inhabitants=0))))
  // CHECK-64:       (field offset=8
  // CHECK-64:         (struct size=8 alignment=8 stride=8 num_extra_inhabitants=0
  // CHECK-64:           (field name=_value offset=0
  // CHECK-64:             (builtin size=8 alignment=8 stride=8 num_extra_inhabitants=0)))))))

  // CHECK-32: Reflecting an object.
  // CHECK-32: Type reference:
  // CHECK-32: (builtin Builtin.NativeObject)
  
  // CHECK-32: Type info:
  // CHECK-32: (closure_context size=32 alignment=8 stride=32 num_extra_inhabitants=0
  // CHECK-32:   (field offset=12
  // CHECK-32:     (reference kind=strong refcounting=native))
  // CHECK-32:   (field offset=16
  // CHECK-32:     (tuple size=16 alignment=8 stride=16 num_extra_inhabitants=0
  // CHECK-32:       (field offset=0
  // CHECK-32:         (struct size=4 alignment=4 stride=4 num_extra_inhabitants=0
  // CHECK-32:           (field name=_value offset=0
  // CHECK-32:             (builtin size=4 alignment=4 stride=4 num_extra_inhabitants=0))))
  // CHECK-32:       (field offset=8
  // CHECK-32:         (struct size=8 alignment=8 stride=8 num_extra_inhabitants=0
  // CHECK-32:           (field name=_value offset=0
  // CHECK-32:             (builtin size=8 alignment=8 stride=8 num_extra_inhabitants=0)))))))
  func arity3Capture2() -> (Int, String, AnyObject?) -> () {
   let pair = (999, 1010.2)
   let closure = { (i: Int, s: String, a: AnyObject?) in
     print(self)
     print(pair)
   }

   reflect(function: closure)
   return closure
  }
}

let cc = CapturingClass()
_ = cc.arity0Capture1()
_ = cc.arity1Capture1()
_ = cc.arity2Capture1()
_ = cc.arity3Capture1()

_ = cc.arity0Capture2()
_ = cc.arity1Capture2()
_ = cc.arity2Capture2()
_ = cc.arity3Capture2()

doneReflecting()
