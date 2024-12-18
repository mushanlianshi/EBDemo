//
//  BLTReverseSequence.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2022/12/7.
//

import Foundation

///一个反转的迭代器
public class BLTReverseIterator<T>: IteratorProtocol {
    public typealias BLTElement = T
    var array: [BLTElement]
    var currentIndex = 0
    init(array: [BLTElement]){
        self.array = array
        currentIndex = array.count - 1
    }
    
    ///实现迭代器的next方法  可以查找next元素
    public func next() -> BLTElement? {
        if currentIndex < 0 {
            return nil
        }
        let element = array[currentIndex]
        currentIndex -= 1
        return element
    }
}


///  自己实现一个翻转的sequence
///    模拟forIn 实现就是根据迭代器的next 是否存在
///    public func forIn(){
//        let list = [Int]()
//        var iterator = list.makeIterator()
//        while let obj = iterator.next() {
//            print("LBLog obj is \(obj)")
//        }
//    }
public struct BLTReverseSequence<T>: Sequence {
    public typealias Iterator = BLTReverseIterator
    
    public typealias BLTElement = T
    
    var array: [T]
    public init(array: [T]){
        self.array = array
    }
    
    ///实现方法 返回一个反转迭代器
    public func makeIterator() -> Iterator<T> {
        return BLTReverseIterator(array: self.array)
    }
    
}



