//
//  AppConfig.swift
//  ScreenFreezer
//
//  Created by Oliver Huang on 2019/4/21.
//  Copyright © 2019 Oliver Huang. All rights reserved.
//

import Foundation
import Carbon.HIToolbox.Events

fileprivate let shortcutKey = "shortcutKey"

extension KeyboardShortcutView {
	var shortcutStruct: Shortcut? {
		guard let pair = self.shortcut else { return nil }
		return Shortcut(keyCode: pair.keyCode, modifierFlags: pair.modifierFlags)
	}
}

struct Shortcut: Codable {
	let keyCode: CGKeyCode
	let modifierFlags: CGEventFlags
	
	var shortcutViewPair: KeyboardShortcutView.Pair {
		return (keyCode: keyCode, modifierFlags: modifierFlags)
	}
	
	var keyboardShortcut: CGSKeyboardShortcut? {
		return try? CGSKeyboardShortcut(identifier: CGSKeyboardShortcut.Identifier(0xE0000001), keyCode: keyCode, modifierFlags: modifierFlags)
	}
}

class AppConfig {
	static let shared = AppConfig()
	
	var shortcut: Shortcut {
		get {
			let defaultShortcut = Shortcut(keyCode: UInt16(kVK_ANSI_F), modifierFlags: [.maskShift, .maskControl])
			guard let data = UserDefaults.standard.value(forKey: shortcutKey) as? Data else {
				return defaultShortcut
			}
			
			do {
				return try PropertyListDecoder().decode(Shortcut.self, from: data)
			}
			catch {
				NSLog("Failed to read shortcut from UserDefaults: \(error)")
				return defaultShortcut
			}
		}
		set(value) {
			do {
				let data = try PropertyListEncoder().encode(value)
				UserDefaults.standard.set(data, forKey: shortcutKey)
			}
			catch {
				NSLog("Failed to write shortcut into UserDefaults: \(error)")
			}
		}
	}
}
