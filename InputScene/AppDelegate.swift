import Cocoa
import Carbon

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(24)
    var keyMonitor: AnyObject?
    var imes: [TISInputSource] = []


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let filter: CFDictionary = [kTISPropertyInputSourceCategory as String: kTISCategoryKeyboardInputSource as String]
        imes = TISCreateInputSourceList(filter, false).takeRetainedValue() as NSArray as! [TISInputSource]
        
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarImage")
            
            let menu = NSMenu()
            
            menu.addItem(NSMenuItem(title: "Chinese / English", action: Selector("startZhMode:"), keyEquivalent: "C"))
            menu.addItem(NSMenuItem(title: "Japanese / English", action: Selector("startJaMode:"), keyEquivalent: "J"))
            menu.addItem(NSMenuItem.separatorItem())
            menu.addItem(NSMenuItem(title: "Quit", action: Selector("terminate:"), keyEquivalent: "q"))
            
            statusItem.menu = menu
        }
        
        if !AXIsProcessTrusted() {
            NSLog("Not trusted")
        }
        
        keyMonitor = NSEvent.addGlobalMonitorForEventsMatchingMask(NSEventMask.KeyDownMask, handler: {(ev: NSEvent) -> Void in
            NSLog("Key down")
            NSLog("%d", ev.keyCode)
            if ev.keyCode == 102 {
                // 英数
                self.startZhMode(nil)
            } else if ev.keyCode == 104 {
                // かな
                self.startJaMode(nil)
            }
        })
    }

    
    func startZhMode(sender: AnyObject?) {
        switchToChinese()
        switchToEnglish()
    }
    
    func startJaMode(sender: AnyObject?) {
        switchToJapanese()
        switchToEnglish()
    }
    
    func switchToChinese() {
        TISSelectInputSource(getIME("Pinyin - Simplified"))
    }
    
    func switchToJapanese() {
        TISSelectInputSource(getIME("Hiragana"))
    }
    
    func switchToEnglish() {
        TISSelectInputSource(getIME("Romaji"))
    }
    
    func getIME(imeName: String) -> TISInputSourceRef? {
        for ime in imes {
            let name: String = Unmanaged<NSString>.fromOpaque(COpaquePointer(TISGetInputSourceProperty(ime, kTISPropertyLocalizedName))).takeRetainedValue() as String
            if name == imeName {
                return ime
            }
        }
        
        return nil
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        if let monitor: AnyObject = keyMonitor {
            NSEvent.removeMonitor(monitor)
            keyMonitor = nil
        }
    }
    
}

