//
//  Dropdown.swift
//  AVPlayer1
//
//  Created by Vu Minh Tam on 4/22/21.
//

import SwiftUI

protocol DropdownDelegate {
    func onSelect(key: String)
}

struct Dropdown: View {
    var options: [DropdownOption]
    var onSelect: ((_ key: String) -> Void)?
    var delegate: DropdownDelegate?
    
    
    var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(self.options, id: \.self) { option in
                    DropdownOptionElement(val: option.val, key: option.key, onSelect: self.onSelect, delegate: self)
                }
            }

            .background(Color.white)
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray, lineWidth: 1)
            )
    }
    init(options: [DropdownOption], onSelect: ((_ key: String) -> Void)?, delegate: DropdownDelegate?) {
        self.options = options
        self.onSelect = onSelect
        self.delegate = delegate
    }
}

extension Dropdown: DropdownOptionElementDelegate {
    func onSelect(key: String) {
        print(key)
        delegate?.onSelect(key: key)
    }
    
    
}

struct Dropdown_Previews: PreviewProvider {
    static var previews: some View {
        Dropdown(options: [], onSelect: nil, delegate: nil)
    }
}
