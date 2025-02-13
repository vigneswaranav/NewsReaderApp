//
//  SynchronizedDictionary.swift
//  NewsReader
//
//  Created by Vigneswaran on 13/02/25.
//

import Foundation

/* dictionary that allows thread safe concurrent access */
class SynchronizedDictionary<KeyType:Hashable,ValueType> : NSObject, ExpressibleByDictionaryLiteral {
    /* internal dictionary */
    private var internalDictionary : [KeyType:ValueType]
    /* queue modfications using a barrier and allow concurrent read operations */
    private let queue = DispatchQueue(label: "dictionary.access", attributes: .concurrent)
    private let rwProvider: AtomicRWScopeProvider
    /* count of key-value pairs in this dicitionary */
    
    var count : Int {
        return rwProvider.performRead {
            return self.internalDictionary.count
        }
    }
    // safely get or set a copy of the internal dictionary value
    var dictionary : [KeyType:ValueType] {
        get {
            return rwProvider.performRead {
                return self.internalDictionary
            }
        }
        set {
            let dictionaryCopy = newValue
            self.rwProvider.performWrite {
                self.internalDictionary = dictionaryCopy
            }
        }
    }
    
    var keys : Dictionary<KeyType,ValueType>.Keys {
        get {
            return rwProvider.performRead {
                return self.internalDictionary.keys
            }
        }
    }
    
    
    var values : Dictionary<KeyType,ValueType>.Values {
        return rwProvider.performRead {
            return self.internalDictionary.values
        }
    }
    /* initialize a concurrent dictionary from a copy of a standard dictionary */
    init(dictionary: [KeyType:ValueType], synchronizationType: AtomicRWScopeProviderType = .default) {
        self.internalDictionary = dictionary
        self.rwProvider = synchronizationType.create()
    }
    
    /* initialize an empty dictionary */
    override convenience init() {
        self.init(dictionary: [KeyType:ValueType]() )
    }
    /* allow a concurrent dictionary to be initialized using a dictionary literal of form: [key1:value1, key2:value2, ...] */
    convenience required init(dictionaryLiteral elements: (KeyType, ValueType)...) {
        var dictionary = Dictionary<KeyType,ValueType>()
        for (key,value) in elements {
            dictionary[key] = value
        }
        self.init(dictionary: dictionary)
    }
    
    
    /* provide subscript accessors */
    subscript(key: KeyType) -> ValueType? {
        get {
            return rwProvider.performRead {
                return self.internalDictionary[key]
            }
        }
        set {
            self.rwProvider.performWrite {
                self.internalDictionary[key] = newValue
            }
        }
    }
    
    /* remove the value associated with the specified key and return its value if any */
    @discardableResult
    func removeValue(forKey key: KeyType) -> ValueType? {
        var oldValue : ValueType? = nil
        // need to synchronize removal for consistent modifications
        self.rwProvider.performWrite {
            oldValue = self.internalDictionary.removeValue(forKey: key)
        }
        return oldValue
    }
    
    func removeAll() {
        self.rwProvider.performWrite {
            self.internalDictionary.removeAll()
        }
    }

    var isEmpty: Bool {
        return dictionary.isEmpty
    }
   
}
