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

/// The enum describes one of several possible types for a value.
///
/// - string:    If the value is a string.
/// - boolean:   If the value is a boolean value.
/// - number:    If the value is a number as JavaScript doesn't
///              distinguish between integers and real numbers.
/// - object:    If the value is an object, that is represented
///              by a simple dictionary.
/// - array:     If the value is an array holding 0 to * other
///              values.
/// - null:      If the value is specified as null.
/// - undefined: This option is only settable by this module and
///              a Json value cannot have this type when building
///              a Json document. A value is of type `undefined`
///              in case during reading of the Json, a
///              value is requested that does not exist.
///              Consequently, this option carries an error
///              message as string.
///
///              Suppose a subscript from an object `object["xy"]`
///              that doesn't have a property named `xy`. The
///              result is a value of type `unavailable` carrying
///              the error message "Property 'xy' doesn't exist on
///              object."
public enum FileValue<Element: FileElement> {
    
    case string(String)
    case boolean(Bool)
    case number(NSNumber)
    case object([String: Element])
    case array([Element])
    case null
    
    init(object: Any) {
        if let string = object as? String {
            self = .string(string)
        } else if let number = object as? NSNumber {
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                self = .boolean(number.boolValue)
            } else {
                self = .number(number)
            }
        } else if let array = object as? [Any] {
            var result = [Element]()
            result.reserveCapacity(array.count)
            for item in array {
                result.append(Element(item))
            }
            self = .array(result)
        } else if let dictionary = object as? [String: Any] {
            var result = [String: Element]()
            result.reserveCapacity(dictionary.count)
            for item in dictionary {
                result[item.key] = Element(item.value)
            }
            self = .object(result)
        } else {
            self = .null
        }
    }
    
}
