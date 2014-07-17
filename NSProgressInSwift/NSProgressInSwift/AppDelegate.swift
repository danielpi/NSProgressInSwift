//
//  AppDelegate.swift
//  NSProgressInSwift
//
//  Created by Daniel Pink on 2/07/2014.
//  Copyright (c) 2014 Electronic Innovations. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
                            
    @IBOutlet var window: NSWindow
    
    @IBOutlet var progressIndicator : NSProgressIndicator
    @IBOutlet var progressDescriptionLabel : NSTextField
    @IBOutlet var startButton : NSButton
    @IBOutlet var pauseButton : NSButton
    @IBOutlet var cancelButton : NSButton
    
    var parentProgress: NSProgress?


    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        // Insert code here to initialize your application
        pauseButton.enabled = false
        cancelButton.hidden = true
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }
    
    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafePointer<()>) {
        //println("Observed Something")
        
        if let theKeyPath = keyPath {
            switch theKeyPath {
            case "fractionCompleted":
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    let progress = object as NSProgress
                    self.progressIndicator.doubleValue = progress.fractionCompleted
                }
            case "localizedDescription":
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    let progress = object as NSProgress
                    self.progressDescriptionLabel.stringValue = progress.localizedDescription
                }
            default:
                println("Unknown Observed value")
            }
        }
        
        
    }

    @IBAction func startTask(sender : AnyObject) {
        parentProgress = NSProgress(totalUnitCount: 10)
        let options : NSKeyValueObservingOptions = .New | .Old | .Initial | .Prior
        parentProgress!.addObserver(self, forKeyPath: "fractionCompleted", options: options, context: nil)
        parentProgress!.addObserver(self, forKeyPath: "localizedDescription", options: options, context: nil)
        
        let queue: dispatch_queue_t = dispatch_queue_create("My Queue", DISPATCH_QUEUE_SERIAL)
        cancelButton.hidden = false
        startButton.enabled = false
        dispatch_async(queue) {
            self.parentProgress!.becomeCurrentWithPendingUnitCount(4)
            self.task1()
            self.parentProgress!.resignCurrent()
            
            if !self.parentProgress!.cancelled {
                sleep(1)
            }
            self.parentProgress!.completedUnitCount++
            
            self.parentProgress!.becomeCurrentWithPendingUnitCount(5)
            self.task2()
            self.parentProgress!.resignCurrent()
            
            self.parentProgress!.removeObserver(self, forKeyPath: "fractionCompleted")
            self.parentProgress!.removeObserver(self, forKeyPath: "localizedDescription")
        }
    }

    @IBAction func pauseTask(sender : AnyObject) {
        if let progress = self.parentProgress {
            if progress.paused {
                //progress.resume???
                // How do you resume a paused NSProgress?
                //self.pauseButton.title = "Pause"
            } else {
                progress.pause()
                self.pauseButton.title = "Resume"
            }
        }
    }
    
    @IBAction func cancelTask(sender : AnyObject) {
        if let progress = self.parentProgress {
            progress.cancel()
            self.pauseButton.title = "Pause"
        }
    }
    
    func task1() {
        let totalUnitCount: Int64 = 8
        var child1Progress: NSProgress = NSProgress(totalUnitCount: totalUnitCount)
        
        outerLoop: for majorStep in 1...totalUnitCount {
            for minorStep in 1 ..< 100 {
                while child1Progress.paused {
                    if child1Progress.cancelled {
                        child1Progress.completedUnitCount = totalUnitCount
                        break outerLoop
                    } // Don't for get to check for a cancellation
                    usleep(500000) // Check every half a second
                }
                if child1Progress.cancelled {
                    child1Progress.completedUnitCount = totalUnitCount
                    break outerLoop
                }
                // Perform your task here. I've just used the sleep function to waste some time
                usleep(3200)
            }
            child1Progress.completedUnitCount++ // Increment the progress instance
        }
    }
    func task2() {
        let totalUnitCount: Int64 = 100
        var child2Progress: NSProgress = NSProgress(totalUnitCount: totalUnitCount)
        
        for majorStep in 1...totalUnitCount {
            if child2Progress.cancelled {
                child2Progress.completedUnitCount = totalUnitCount
                break
            } else {
                // Perform your task here. I've just used the sleep function to waste some time
                usleep(12800)
                child2Progress.completedUnitCount++ // Increment the progress instance
            }
        }
        cancelButton.hidden = true
        startButton.enabled = true
    }
}


