//
//  DropdownButton.swift
//  AVPlayer1
//
//  Created by Vu Minh Tam on 4/22/21.
//

import SwiftUI

protocol DropdownButtonDelegate {
    func onSelect(key: String)
}

struct DropdownButton: View {
    @State var shouldShowDropdown = false
    @Binding var displayText: String?
    var options: [DropdownOption]
    var onSelect: ((_ key: String) -> Void)?

    let buttonHeight: CGFloat = 30
    
    var delegate: DropdownButtonDelegate?
    
    
    var body: some View {
        GeometryReader { geometry in
            Button(action: {
                self.shouldShowDropdown.toggle()
            }) {
                HStack {
                    Text(displayText ?? "")
                    Spacer()
                        .frame(width: 20)
                    Image(systemName: self.shouldShowDropdown ? "chevron.up" : "chevron.down")
                }
            }
            .cornerRadius(5)
            .frame(width: geometry.size.width / 2, height: self.buttonHeight, alignment: .center)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .overlay(
                VStack {
                    if self.shouldShowDropdown {
                        Spacer(minLength: buttonHeight + 5)
                        Dropdown(options: self.options, onSelect: self.onSelect, delegate: self)
                    }
                }, alignment: .topLeading
            )
            .background(
                RoundedRectangle(cornerRadius: 5).fill(Color.white)
            )
            .padding([.leading, .trailing], geometry.size.width / 4)
        }
    }
    
    init(shouldShowDropdown: Bool, displayText: Binding<String?>, options: [DropdownOption], onSelect: ((_ key: String) -> Void)?, delegate: DropdownButtonDelegate?) {
        self._shouldShowDropdown = State(initialValue: shouldShowDropdown)
        self._displayText = displayText
        self.options = options
        self.onSelect = onSelect
        self.delegate = delegate
    }
    
}

extension DropdownButton: DropdownDelegate {
    func onSelect(key: String) {
        delegate?.onSelect(key: key)
    }
}

struct DropdownButton_Previews: PreviewProvider {
    static let options = [
        DropdownOption(key: "week", val: "This week"), DropdownOption(key: "month", val: "This month"), DropdownOption(key: "year", val: "This year")
    ]

    static let onSelect = { key in
        print(key)
    }

    static var previews: some View {
        Group {
            VStack(alignment: .leading) {
                DropdownButton(shouldShowDropdown: false, displayText: .constant(""), options: options, onSelect: onSelect, delegate: nil )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray)
            .foregroundColor(Color.black)

            VStack(alignment: .leading) {
                DropdownButton(shouldShowDropdown: true, displayText: .constant(""), options: options, onSelect: onSelect, delegate: nil)
                Dropdown(options: options, onSelect: onSelect, delegate: nil)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray)
            .foregroundColor(Color.black)
        }
    }
}
