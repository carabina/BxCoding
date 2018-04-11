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

public struct Plist: FileElement {
    
    public var value: FileValue<Plist>
    
    private init() {
        value = .null
    }
    
    public init(value: FileValue<Plist>) {
        self.value = value
    }
    
    public init(_ any: Any) {
        value = FileValue(object: any)
    }
    
    public init(reading data: Data) {
        guard let object = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) else {
            self.init()
            return
        }
        self.init(object)
    }
    
    public init(reading url: URL) {
        do {
            self.init(reading: try Data(contentsOf: url))
        } catch {
            self.init()
        }
    }
    
    public init(reading plist: String, from bundle: Bundle = .main) {
        do {
            self.init(reading: try bundle.url(forResource: plist, withExtension: ".plist").unwrap())
        } catch {
            self.init()
        }
    }
    
    public func description(forOffset offset: String, prettyPrinted: Bool, truncatesStrings: Bool) -> String {
        fatalError("not implemented")
    }
}
