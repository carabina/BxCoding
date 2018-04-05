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

import RxSwift

extension ObservableType where E == Data {
    
    public func decode<T: FileDecodable, D: FileDecoder>(type: T.Type = T.self,
                                                         using decoder: D.Type) -> Observable<T> {
        return self.serialize(to: D.Element.self).decode(using: D.self)
    }
    
    public func serialize<E: FileElement>(to element: E.Type = E.self) -> Observable<E> {
        return self.map { E(reading: $0) }
    }
}

extension ObservableType where E: FileElement {
    
    public func decode<T: FileDecodable, D: FileDecoder>(type: T.Type = T.self,
                                                         using decoder: D.Type) -> Observable<T> where D.Element == E {
        return self.map { try D.decode($0) }
    }
    
}
