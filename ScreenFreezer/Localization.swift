//
//  Localization.swift
//  ScreenFreezer
//
//  Created by Oliver Huang on 2019/4/21.
//  Copyright © 2019 Oliver Huang. All rights reserved.
//

import Cocoa

protocol Localizable {
	var localized: String { get }
}

extension String : Localizable {
	var localized: String {
		return NSLocalizedString(self, comment: "")
	}
}

extension NSWindow {
	@IBInspectable var titleLocKey: String? {
		get { return nil }
		set(key) {
			guard let key = key else { return }
			self.title = key.localized
		}
	}
}

extension NSTextField {
	@IBInspectable var textLocKey: String? {
		get { return nil }
		set(key) {
			guard let key = key else { return }
			self.stringValue = key.localized
		}
	}
}

extension NSButton {
	@IBInspectable var titleLocKey: String? {
		get { return nil }
		set(key) {
			guard let key = key else { return }
			self.title = key.localized
		}
	}
}

extension NSMenu {
	@IBInspectable var titleLocKey: String? {
		get { return nil }
		set(key) {
			guard let key = key else { return }
			self.title = key.localized
		}
	}
}

extension NSMenuItem {
	@IBInspectable var titleLocKey: String? {
		get { return nil }
		set(key) {
			guard let key = key else { return }
			self.title = key.localized
		}
	}
}

extension KeyboardShortcutView {
	@IBInspectable var placeholderLocKey: String? {
		get { return nil }
		set(key) {
			guard let key = key else { return }
			self.placeholderString = key.localized
		}
	}
}
