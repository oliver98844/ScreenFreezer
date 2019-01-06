//
//  AppDelegate.swift
//  MonitorFreezer
//
//  Created by Oliver Huang on 2019/1/5.
//  Copyright © 2019年 Oliver Huang. All rights reserved.
//

import Cocoa
import Carbon.HIToolbox.Events

extension NSButton {
	var titleTextColor : NSColor {
		get {
			let attrTitle = self.attributedTitle
			return attrTitle.attribute(.foregroundColor, at: 0, effectiveRange: nil) as! NSColor
		}
		
		set(newColor) {
			let attrTitle = NSMutableAttributedString(attributedString: self.attributedTitle)
			let titleRange = NSMakeRange(0, self.title.count)
			
			attrTitle.addAttributes([.foregroundColor: newColor], range: titleRange)
			self.attributedTitle = attrTitle
		}
	}
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var window: NSWindow!
	@IBOutlet weak var freezeWindow: NSWindow!
	@IBOutlet weak var imageView: NSImageView!
	@IBOutlet weak var freezeButton: NSButton!
	var shortcutRecognizer: PressShortcutRecognizer!
	var shortcutHolder: Any?
	
	private func setupUI() {
		self.window.level = .screenSaver
		self.window.performSelector(inBackground: Selector(("_setPreventsActivation:")), with: true)
		self.freezeWindow.level = .screenSaver
		self.freezeWindow.performSelector(inBackground: Selector(("_setPreventsActivation:")), with: true)
		self.freezeWindow.contentView?.wantsLayer = true
		self.freezeWindow.contentView?.layer?.backgroundColor = NSColor.black.cgColor
		Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.bringWindowFront(_:)), userInfo: nil, repeats: true)
	}
	
	private func setupKeyboardShortcut() {
		self.shortcutRecognizer = PressShortcutRecognizer { [weak self] in
			self?._toggleFreeze()
		}
		guard let shortcut = try? CGSKeyboardShortcut(identifier: CGSKeyboardShortcut.Identifier(0xE0000001), keyCode: UInt16(kVK_ANSI_F), modifierFlags: [.maskShift, .maskControl]) else {
			NSLog("Failed to create shortcut")
			return
		}
		self.shortcutHolder = self.shortcutRecognizer.bind(to: shortcut)
	}
	
	@objc private func _toggleFreeze() {
		self.freezeButton.state = (self.freezeButton.state == .off) ? .on : .off
		self.toggle(self.freezeButton)
	}
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		self.setupUI()
		self.setupKeyboardShortcut()
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}
	
	@objc func bringWindowFront(_ sender: Any?) {
		if self.freezeButton.state == .on {
			self.freezeWindow.setFrame(NSScreen.screens.last?.frame ?? CGRect.zero, display: false)
			self.freezeWindow.orderFrontRegardless()
		}
		self.window.orderFrontRegardless()
	}
	
	@IBAction func toggleFreeze(_ sender: Any?) {
		self.perform(#selector(self._toggleFreeze), with: nil, afterDelay: 0.0)
	}
	
	@IBAction func toggle(_ button: NSButton) {
		button.titleTextColor = button.state == .on ? .red : .black
		if button.state == .off {
			self.freezeWindow.orderOut(self)
			return
		}
		guard let image = screensShot() else {
			button.state = .off
			button.titleTextColor = .black
			return
		}
		self.imageView.image = image
		self.freezeWindow.setFrame(NSScreen.screens.last?.frame ?? CGRect.zero, display: false) 
		self.freezeWindow.orderFrontRegardless()
		self.window.orderFrontRegardless()
	}
	
	func screensShot() -> NSImage? {
		
		var displayCount: UInt32 = 0;
		var result = CGGetActiveDisplayList(0, nil, &displayCount)
		if (result != CGError.success) {
			print("error: \(result)")
			return nil
		}
		let allocated = Int(displayCount)
		let activeDisplays = UnsafeMutablePointer<CGDirectDisplayID>.allocate(capacity: allocated)
		result = CGGetActiveDisplayList(displayCount, activeDisplays, &displayCount)
		
		if (result != CGError.success) {
			print("error: \(result)")
			return nil
		}
		
		if displayCount < 1 {
			return nil
		}
		
		let index = Int(displayCount) - 1
		
		let screenShot:CGImage = CGDisplayCreateImage(activeDisplays[index])!
		let bitmapRep = NSBitmapImageRep(cgImage: screenShot)
		guard let data = bitmapRep.representation(using: NSBitmapImageRep.FileType.png, properties: [NSBitmapImageRep.PropertyKey : Any]()) else {
			return nil
		}
		return NSImage(data: data)
	}
}

