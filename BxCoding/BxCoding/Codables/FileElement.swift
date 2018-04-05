// Copyright 2018 Oliver Borchert
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import BxUtility

public protocol FileElement: CustomStringConvertible {
    
    /// Initializes a `FileElement` with type `Any`. In fact, this is not really
    /// type `Any` but just used for internal simplicity and generic
    /// programming. **It should not be used outside of this module.**
    ///
    /// - parameter any: The value to initialize the element with.
    ///
    /// - returns: A newly initialized instance.
    init(_ any: Any)
    
    init(reading: Data)
    
    /// Initializes a `FileElement` with a specified value. **This initializer
    /// should not be used outside of this module.** Use the convenience
    /// initializers for simple Swift types instead.
    ///
    /// - parameter value: The value to initialize the element with.
    ///
    /// - returns: A newly initialized instacne.
    init(value: FileValue<Self>)
    
    /// The value the current element is wrapping.
    var value: FileValue<Self> { get set }
    
    /// Returns a description for the element.
    ///
    /// - parameter offset:        Shouldn't be used publicly, just for
    ///                            printing objects and arrays prettily.
    /// - parameter prettyPrinted: `true` if the description should be read
    ///                            by a human, `false` if it should just be
    ///                            as small as possible.
    ///
    /// - returns: The description as `String`.
    func description(forOffset offset: String, prettyPrinted: Bool, truncatesStrings: Bool) -> String
    
}

extension FileElement {
    
    public static var array: Self {
        return Self(value: .array([]))
    }
    
    public static var dictionary: Self {
        return Self(value: .object([:]))
    }
    
    public static var null: Self {
        return Self(value: .null)
    }
    
    internal func simpleDescription() -> String {
        switch value {
        case .string(let string):
            return string
        case .null:
            return "nil"
        case .number(let number):
            return "\(number)"
        case .boolean(let bool):
            return "\(bool)"
        case .array(let array):
            return "[\(array.map { "\($0.simpleDescription())" }.joined(separator: ",\n"))]"
        case .object(let dictionary):
            return "[\(dictionary.map { "\($0.0): \($0.1.simpleDescription())" }.joined(separator: ",\n"))]"
        }
    }
    
    // MARK: Computed properties
    public func anyValue() throws -> Any {
        switch value {
        case .string(let string):
            return string
        case .number(let number):
            return number
        case .boolean(let bool):
            return bool
        case .array(let array):
            return try array.map { try $0.anyValue() }
        case .object(let dictionary):
            return try dictionary.mapValues { try $0.anyValue() }
        case .null:
            throw MorphError.anyIncompatibleValue
        }
    }
    
    public func anyDictionary() throws -> [String: Any] {
        return try (anyValue() as? [String: Any]).unwrap()
    }
    
    /// The keys of all subelements in case `self` wraps an object.
    public var propertyKeys: Set<String>? {
        switch value {
        case .object(let object): return Set(object.keys)
        default: return nil
        }
    }
    
    /// Returns the number of subelements in case `self` is either
    /// an array or an object (equals dictionary in this case).
    public var count: Int {
        switch value {
        case .array(let array): return array.count
        case .object(let dictionary): return dictionary.count
        default: return 0
        }
    }
    
    // MARK: Check access
    /// Returns if `self` wraps a string.
    public var isString: Bool {
        if case .string = value {
            return true
        }
        return false
    }
    
    /// Returns if `self` wraps a boolean.
    public var isBoolean: Bool {
        if case .boolean = value {
            return true
        }
        return false
    }
    
    /// Returns if `self` wraps a number.
    public var isNumber: Bool {
        if case .number = value {
            return true
        }
        return false
    }
    
    /// Returns if `self` wraps an object (dictionary).
    public var isDictionary: Bool {
        if case .object = value {
            return true
        }
        return false
    }
    
    /// Returns if `self` wraps an array.
    public var isArray: Bool {
        if case .array = value {
            return true
        }
        return false
    }
    
    public var isCollection: Bool {
        switch value {
        case .array, .object: return true
        default: return false
        }
    }
    
    /// Returns if `self` is neither `nil` nor `undefined`.
    public var isValue: Bool {
        switch value {
        case .null: return false
        default: return true
        }
    }
    
    /// Returns if `self` wraps `nil`.
    public var isNull: Bool {
        if case .null = value {
            return true
        }
        return false
    }
    
    // MARK: Access and manipulation
    /// The string in case `self` wraps a string, `nil` otherwise.
    public var stringValue: String? {
        switch value {
        case .string(let string): return string
        default: return nil
        }
    }
    
    /// The boolean in case `self` wraps a boolean, `nil` otherwise.
    public var boolValue: Bool? {
        switch value {
        case .boolean(let bool): return bool
        default: return nil
        }
    }
    
    /// The double in case `self` wraps a double, `nil` otherwise.
    public var doubleValue: Double? {
        switch value {
        case .number(let number): return number.doubleValue
        default: return nil
        }
    }
    
    /// The string in case `self` wraps a string, `nil` otherwise.
    public var intValue: Int? {
        switch value {
        case .number(let number): return number.intValue
        default: return nil
        }
    }
    
    public var int64Value: Int64? {
        switch value {
        case .number(let number): return number.int64Value
        default: return nil
        }
    }
    
    public var int32Value: Int32? {
        switch value {
        case .number(let number): return number.int32Value
        default: return nil
        }
    }
    
    public var int16Value: Int16? {
        switch value {
        case .number(let number): return number.int16Value
        default: return nil
        }
    }
    
    public var int8Value: Int8? {
        switch value {
        case .number(let number): return number.int8Value
        default: return nil
        }
    }
    
    public var uintValue: UInt? {
        switch value {
        case .number(let number): return number.uintValue
        default: return nil
        }
    }
    
    public var uint64Value: UInt64? {
        switch value {
        case .number(let number): return number.uint64Value
        default: return nil
        }
    }
    
    public var uint32Value: UInt32? {
        switch value {
        case .number(let number): return number.uint32Value
        default: return nil
        }
    }
    
    public var uint16Value: UInt16? {
        switch value {
        case .number(let number): return number.uint16Value
        default: return nil
        }
    }
    
    public var uint8Value: UInt8? {
        switch value {
        case .number(let number): return number.uint8Value
        default: return nil
        }
    }
    
    public var decimalValue: Decimal? {
        switch value {
        case .number(let number): return number.decimalValue
        default: return nil
        }
    }
    
    public var arrayValue: [Self]? {
        switch value {
        case .array(let array): return array
        default: return nil
        }
    }
    
    public var dictionaryValue: [String: Self]? {
        switch value {
        case .object(let object): return object
        default: return nil
        }
    }
    
    /// The subscript may be used on objects to access properties by name.
    /// Both accessing and setting a property of an element that is no
    /// object won't quit the application. When accessing, an `unvailable`
    /// value is returned, when setting, the function simply does nothing
    /// except for printing an error message to the console.
    ///
    /// - parameter key: The key is the name of the property. When there
    ///                  is no property that is named like that, an
    ///                  `unavailable` value with a helpful error message
    ///                  is returned. When setting the value, all prior
    ///                  values are silently overridden or a new property
    ///                  is created.
    ///
    /// - returns: The subscript returns the element that was accessed by
    ///            the property.
    public subscript(key: String) -> Self {
        get {
            switch value {
            case .object(let object):
                return object[key] ?? Self.null
            default:
                return Self.null
            }
        } set {
            switch value {
            case .object(var object):
                object[key] = newValue
                value = .object(object)
            default:
                print("Setting a property is only allowed on objects.")
            }
        }
    }
    
    /// If `self` wraps an array, this subscript returns the value at
    /// the specified index. If the index is out of bounds, an `undefined`
    /// value is returned. If `self` is anything else (except for `undefined`)
    /// and `index` is zero, the element itself is returned. The reason for
    /// this is: when using XML, there can't be distinguished between an
    /// array and a simple value when there only exists a single value. Yet,
    /// the code should still work, if it's supposed to be an array but only
    /// holds one value making it being stored as simple value internally.
    ///
    /// When setting an index, a simple error message is printed to the
    /// in case `self` wraps an array, the program is not terminated. When
    /// having values apart from `undefined`, they can be set using index 0
    /// as well (same reason as above). When the index is not equal to 0,
    /// an error message is printed and the program continues to run.
    ///
    /// - parameter index: The index to subscript for.
    ///
    /// - returns: The element that was accessed by the specified index.
    public subscript(index: Int) -> Self {
        get {
            switch value {
            case .array(let array):
                return array.get(at: index) ?? Self.null
            case .string, .boolean, .number, .null, .object:
                if index == 0 {
                    return self
                }
                fallthrough
            default:
                return Self.null
            }
        } set {
            switch value {
            case .array(var array):
                guard array.indices.contains(index) ||
                    array.count == index else {
                        print("Index is out of range.")
                        return
                }
                array[index] = newValue
                self.value = .array(array)
            case .string, .boolean, .number, .null, .object:
                if index == 0 {
                    self = newValue
                } else {
                    fallthrough
                }
            default:
                print("Setting an index is not allowed on type undefined and" +
                    "indices not equal 0 may only be used on arrays.")
            }
        }
    }
    
    /// Appends a value to `self` in case it wraps an array.
    /// In case `self` is not an array, `self` is made an
    /// array and the element is appended to this array. The
    /// original `self` value is the first element of the
    /// newly created array. If `self` is `undefined`, it
    /// is the first element of the array as well.
    ///
    /// - parameter element: The element to append.
    public mutating func append(_ element: Self) {
        switch value {
        case .array(var array):
            array.append(element)
            value = .array(array)
        default:
            let value = self
            self.value = .array([value, element])
        }
    }
    
    /// Removes a value from `self` in case it wraps an array.
    /// Index 0 can always be removed. If `self` is not an array,
    /// `self` deletes itself and replaces itself by an empty
    /// array. The reason for doing this is, XML single values
    /// should be treated as arrays as well. In all other cases
    /// (including `self` is `undefined`), nothing is done and
    /// `nil` is returned.
    ///
    /// - parameter index: The index to remove the element at.
    ///
    /// - returns: The element that has been removed or `nil`
    ///            if there was no element removed.
    public mutating func remove(at index: Int) -> Self? {
        switch value {
        case .array(var array):
            let removed = array.remove(at: index)
            value = .array(array)
            return removed
        default:
            if index == 0 {
                let removed = self
                self.value = .array([])
                return removed
            }
            return nil
        }
    }
    
    /// A human readable description of `self`.
    public var description: String {
        return description(forOffset: "", prettyPrinted: true, truncatesStrings: true)
    }
}
