//
//  StructClassActorExamples.swift
//  SwiftConcurrency
//
//  Created by Sakshi Shrivastava on 3/4/26.
//

import SwiftUI

struct StructClassActorExamples: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .onAppear {
                runTest()
            }
    }
}

#Preview {
    StructClassActorExamples()
}

struct MyStruct {
    var title: String
}

extension StructClassActorExamples {
    
    private func runTest() {
        print("Test Started!")
//        printDivider()
//        structTest1()
//        printDivider()
//        classTest1()
        structTest2()
        classTest2()
    }
    
    private func printDivider() {
        print("""

        ------------------------------------
        
        """)
    }
    
    private func structTest1() {
        print("Struct test 1")
        let object1 = MyStruct(title: "Struct 1")
        print("Object1: \(object1.title)")
        
        print("We pass the VALUES of Object1 to Object2")
        var object2 = object1
        print("Object2: \(object2.title)")
        
        object2.title = "Struct 2"
        print("Object2 title changed!")
        
        print("Object1: \(object1.title)")
        print("Object2: \(object2.title)")
    }
    
    private func classTest1() {
        print("Class test 1")
        let classObject1 = MyClass(title: "Class 1")
        print("classObject1: \(classObject1.title)")
        
        print("We pass the REFERENCE of classObject1 to classObject2")
        let classObject2 = classObject1
        print("classObject2: \(classObject2.title)")
        
        classObject2.title = "Class 2"
        print("classObject2 title changed!")
        
        print("classObject1: \(classObject1.title)")
        print("classObject2: \(classObject2.title)")
    }
}

// Immutable struct
struct CustomStruct {
    let title: String
    
    func updateTitle(title: String) -> CustomStruct {
        return CustomStruct(title: title)
    }
}

// Mutating Struct
struct MutatingStruct {
    private(set) var title: String
    
    init(title: String) {
        self.title = title
    }
    
    mutating func updateTitle(newTitle: String) {
        title = newTitle
    }
}

extension StructClassActorExamples {
    
    private func structTest2(){
        
        printDivider()
        print("Struct Test 2")
        var struct1 = MyStruct(title: "Struct 1")
        print("Struct 1: \(struct1.title)")
        
        struct1.title = "New Title"
        print("Struct 1: \(struct1.title)")
        
        var struct2 = CustomStruct(title: "Struct 2")
        print("Struct 2: \(struct2.title)")
        
        struct2 = CustomStruct(title: "New Title")
        print("Struct 2: \(struct2.title)")
        
        var struct3 = CustomStruct(title: "Struct 3")
        print("Struct 3: \(struct3.title)")
        
        struct3 = struct3.updateTitle(title: "New title")
        print("Struct 3: \(struct3.title)")
        
        var struct4 = MutatingStruct(title: "Struct 4")
        print("Struct 4: \(struct4.title)")
        
        struct4.updateTitle(newTitle: "New title")
        print("Struct 4: \(struct4.title)")
    }
}

class MyClass {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    func updateTitle(newTitle: String) {
        title = newTitle
    }
}

extension StructClassActorExamples {
    
    private func classTest2(){
        
        printDivider()
        print("Class Test 2")
        let class1 = MyClass(title: "Class 1")
        print("Class 1: \(class1.title)")
        
        class1.title = "New Title"
        print("class 1: \(class1.title)")
        
        class1.updateTitle(newTitle: "New title 2")
        print("class 1: \(class1.title)")
    }
}
