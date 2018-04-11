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

import BxUtility

/// The structure holds a JSON object. It may hold simple values
/// that do not represent valid JSON (like strings, numbers, etc.)
/// or objects with keys and values that make up valid JSON.
///
/// It provides many ways to work with JSON on a very high level.
public struct Json: FileElement {
    
    public var value: FileValue<Json>
    
    /// Reads JSON from a file at the specified URL.
    ///
    /// - parameter url: The URL to read from.
    ///
    /// - returns: Returns `nil` in case there couldn't be
    ///            read any JSON from the specified URL,
    ///            a newly initialized JSON object otherwise.
    public init(readingFrom url: URL) {
        guard let data = try? Data(contentsOf: url) else {
            self.init()
            self.value = .null
            return
        }
        self.init(reading: data)
    }
    
    /// Reads JSON from the data.
    ///
    /// - parameter data: The data to read from.
    ///
    /// - returns: Returns `nil` in case the data does not
    ///            represent valid JSON, a newly initialized
    ///            JSON object otherwise.
    public init(reading data: Data) {
        guard let object = try? JSONSerialization.jsonObject(with: data, options: []) else {
            self.init()
            self.value = .null
            return
        }
        self.init(object)
    }
    
    /// Reads JSON from a string.
    ///
    /// - parameter string: The string to read from.
    ///
    /// - returns: Returns `nil` in case the string does not
    ///            represent valid JSON, a newly initialized
    ///            JSON object otherwise.
    public init(reading string: String) {
        guard let data = string.data(using: .utf8) else {
            self.init()
            self.value = .null
            return
        }
        self.init(reading: data)
    }
    
    public init(_ any: Any) {
        if let json = any as? Json {
            value = json.value
            return
        }
        value = FileValue(object: any)
    }
    
    /// Initializes a JSON object with the specified properties.
    ///
    /// - parameter properties: The properties for the JSON object.
    ///
    /// - returns: A newly initialized JSON object.
    public init(_ properties: [String: Json] = [:]) {
        value = .object(properties)
    }
    
    /// Initializes a JSON object for the string.
    ///
    /// - parameter string: The string for the JSON object.
    ///
    /// - returns: A newly initialized JSON object.
    public init(_ string: String) {
        value = .string(string)
    }
    
    /// Initializes a JSON object for the boolean.
    ///
    /// - parameter boolean: The boolean for the JSON object.
    ///
    /// - returns: A newly initialized JSON object.
    public init(_ boolean: Bool) {
        value = .boolean(boolean)
    }
    
    /// Initializes a JSON object for the number.
    ///
    /// - parameter number: The number for the JSON obejct.
    ///
    /// - returns: A newly initialized JSON object.
    public init(_ number: NSNumber) {
        value = .number(number)
    }
    
    /// Initializes a JSON object as array with.
    ///
    /// - parameter array: The values to add to the array.
    ///
    /// - returns: A newly initialized JSON object.
    public init(_ array: [Json]) {
        value = .array(array)
    }
    
    public init(value: FileValue<Json>) {
        self.value = value
    }
    
    // MARK: Public methods
    /// The JSON object's description encoded using the specified
    /// encoding. The encoded string is not meant to be human
    /// readable but only to be as small as possible.
    ///
    /// - parameter encoding: The encoding to encode the object with.
    ///                       Default is `.uft8`.
    ///
    /// - returns: The encoded description of `self`.
    public func data(using encoding: String.Encoding = .utf8) -> Data? {
        return description(prettyPrinted: false).data(using: encoding)
    }
    
    public func description(forOffset offset: String = "",
                            prettyPrinted: Bool = true,
                            truncatesStrings: Bool = false) -> String {
        return self.description(forOffset: offset, prettyPrinted: prettyPrinted,
                                truncatesStrings: truncatesStrings, offsetsInitialValue: true)
    }
    
    private func description(forOffset offset: String = "",
                             prettyPrinted: Bool = true,
                             truncatesStrings: Bool = false,
                             offsetsInitialValue: Bool) -> String {
        switch value {
        case .string(var string):
            string = string.replacingOccurrences(of: "\n", with: "\\n")
            return (offsetsInitialValue ? offset : "") + "\"\(truncatesStrings ? string.truncated(to: 80) : string)\""
        case .boolean(let bool): return (offsetsInitialValue ? offset : "") + String(describing: bool)
        case .number(let double): return (offsetsInitialValue ? offset : "") + String(describing: double)
        case .array(_): return arrayDescription(forOffset: offset,
                                                prettyPrinted: prettyPrinted,
                                                truncatesStrings: truncatesStrings,
                                                offsetsInitialValue: offsetsInitialValue)
        case .object(_): return objectDescription(forOffset: offset,
                                                  prettyPrinted: prettyPrinted,
                                                  truncatesStrings: truncatesStrings,
                                                  offsetsInitialValue: offsetsInitialValue)
        case .null: return (offsetsInitialValue ? offset : "") + "null"
        }
    }
    
    private func arrayDescription(forOffset offset: String, prettyPrinted: Bool = true,
                                  truncatesStrings: Bool, offsetsInitialValue: Bool) -> String {
        switch value {
        case .array(let array):
            if prettyPrinted {
                if array.isEmpty {
                    return "[]"
                }
                var result = (offsetsInitialValue ? offset : "") + "[\n"
                for (index, element) in array.enumerated() {
                    let elementDescription = element.description(forOffset: offset + "\t", prettyPrinted: true,
                                                                 truncatesStrings: truncatesStrings, offsetsInitialValue: false)
                    result += "\(offset)\t\(elementDescription)\(index == array.count - 1 ? "" : ",")\n"
                }
                result += offset + "]"
                return result
            } else {
                return "[" +
                    array.lazy.map
                        { $0.description(forOffset: "", prettyPrinted: false,
                                         truncatesStrings: truncatesStrings, offsetsInitialValue: false) }
                        .joined(separator: ",")
                    + "]"
            }
        default:
            fatalError()
        }
    }
    
    private func objectDescription(forOffset offset: String, prettyPrinted: Bool = true,
                                   truncatesStrings: Bool, offsetsInitialValue: Bool) -> String {
        switch value {
        case .object(let object):
            if prettyPrinted {
                // +1 for the colon when displaying and +2 for the quotes and +1 for a space
                let maxTabs = ceil(object.keys.lazy.map { $0.count + 4 }.max() ?? 0, to: 4) / 4
                var result = (offsetsInitialValue ? offset : "") + "{\n"
                for (index, element) in object.enumerated() {
                    let tabs = String(repeating: "\t",
                                      count: maxTabs - floor(element.key.count + 3, to: 4) / 4)
                    let elementDescription = element.value.description(forOffset: offset + "\t", prettyPrinted: true,
                                                                       truncatesStrings: truncatesStrings, offsetsInitialValue: false)
                    result += "\(offset)\t\"\(element.key)\":\(tabs)\(elementDescription)\(index == object.count - 1 ? "" : ",")\n"
                }
                result += offset + "}"
                return result
            } else {
                return "{" +
                    object.lazy.map { """
                        \"\($0.key)\":\($0.value.description(forOffset: "",prettyPrinted: false, truncatesStrings: truncatesStrings, offsetsInitialValue: false))
                        """ }.joined(separator: ",") + "}"
            }
        default:
            fatalError()
        }
    }
}


extension Json: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self.init(value as NSNumber)
    }
}

extension Json: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(value as NSNumber)
    }
}

extension Json: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension Json: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self.init(value)
    }
}

extension Json: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Json...) {
        self.init(elements)
    }
}

extension Json: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, Json)...) {
        let dictionary = Dictionary<String, Json>(elements) { _, rhs in rhs }
        self.init(dictionary)
    }
}
