//
//  DropdownOptionElement.swift
//  AVPlayer1
//
//  Created by Vu Minh Tam on 4/22/21.
//

import SwiftUI
import Combine

protocol DropdownOptionElementDelegate {
    func onSelect(key: String)
}

struct DropdownOptionElement: View {
    var val: String
    var key: String
    var onSelect: ((_ key: String) -> Void)?
    
    var delegate: DropdownOptionElementDelegate?
    
    var body: some View {
        Button(action: {
            self.delegate?.onSelect(key: self.key)
            if let onSelect = self.onSelect {
                onSelect(self.key)
                
            }
        }) {
            Text(self.val)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 5)
    }
    init(val: String, key: String, onSelect: ((_ key: String) -> Void)?,  delegate: DropdownOptionElementDelegate? ) {
        self.val = val
        self.key = key
        self.onSelect = onSelect
        self.delegate = delegate
    }
}
struct DropdownOptionElement_Previews: PreviewProvider {
    static var previews: some View {
        DropdownOptionElement(val: "", key: "", onSelect: nil, delegate: nil)
    }
}

