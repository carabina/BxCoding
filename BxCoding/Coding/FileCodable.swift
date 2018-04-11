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

public typealias FileCodable = FileEncodable & FileDecodable

public protocol FileEncodable {
    /// Converts the information stored in the type to a
    /// JSON or XML object using the specified encoder.
    ///
    /// - parameter encoder: The encoder used for creating JSON and XML files.
    func encode<Encoder: FileEncoder>(to encoder: Encoder) throws
}

/// The `FileCodable` protocol should be adapted by types
/// that can be encoded as JSON or XML. The methods needing
/// to be adopted are used for reading and writing.
public protocol FileDecodable {
    /// Initializes an instance of the type by a decoder
    /// carrying the information from a JSON or XML object.
    ///
    /// - parameter decoder: The decoder used for reading
    ///                      all values.
    ///
    /// - returns: A newly initialized instance of the type.
    init<Decoder: FileDecoder>(from decoder: Decoder) throws
}
