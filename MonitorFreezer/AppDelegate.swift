//
//  AppDelegate.swift
//  MonitorFreezer
//
//  Created by Oliver Huang on 2019/1/5.
//  Copyright © 2019年 Oliver Huang. All rights reserved.
//

import Cocoa

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
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		self.window.level = .screenSaver
		self.window.performSelector(inBackground: Selector(("_setPreventsActivation:")), with: true)
		self.freezeWindow.level = .screenSaver
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
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

