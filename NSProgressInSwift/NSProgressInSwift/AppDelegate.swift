//
//  AppDelegate.swift
//  NSProgressInSwift
//
//  Created by Daniel Pink on 2/07/2014.
//  Copyright (c) 2014 Electronic Innovations. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
                            
    @IBOutlet var window: NSWindow!
    
    @IBOutlet var progressIndicator : NSProgressIndicator!
    @IBOutlet var progressDescriptionLabel : NSTextField!
    @IBOutlet var startButton : NSButton!
    @IBOutlet var pauseButton : NSButton!
    @IBOutlet var cancelButton : NSButton!
    
    var parentProgress: Progress?
    var queue: DispatchQueue = DispatchQueue(label: "My Queue", attributes: [])

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        pauseButton.isEnabled = false
        cancelButton.isHidden = true
        //self.queue = dispatch_queue_create("My Queue", DISPATCH_QUEUE_SERIAL)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    //override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafePointer<()>) {
    override func observeValue(forKeyPath keyPath: String?,
                                        of object: Any?,
                                           change: [NSKeyValueChangeKey : Any]?,
                                          context: UnsafeMutableRawPointer?) {
        print("Observed Something")
        
        if let theKeyPath = keyPath {
            switch theKeyPath {
            case "fractionCompleted":
                OperationQueue.main.addOperation {
                    let progress = object as! Progress
                    self.progressIndicator.doubleValue = progress.fractionCompleted
                }
            case "localizedDescription":
                OperationQueue.main.addOperation {
                    let progress = object as! Progress
                    self.progressDescriptionLabel.stringValue = progress.localizedDescription
                }
            default:
                print("Unknown Observed value")
            }
        }
        
        
    }

    @IBAction func startTask(_ sender : AnyObject) {
        parentProgress = Progress(totalUnitCount: 10)
        //let options : NSKeyValueObservingOptions = .new | .old | .initial | .prior
        let options : NSKeyValueObservingOptions = [.new, .old, .initial, .prior]
        parentProgress!.addObserver(self, forKeyPath: "fractionCompleted", options: options, context: nil)
        parentProgress!.addObserver(self, forKeyPath: "localizedDescription", options: options, context: nil)
        
        
        cancelButton.isHidden = false
        startButton.isEnabled = false
        
        self.parentProgress!.becomeCurrent(withPendingUnitCount: 4)
        self.task1() { print("Task 1 complete") }
        self.parentProgress!.resignCurrent()
        
        self.parentProgress!.becomeCurrent(withPendingUnitCount: 6)
        self.task2() {
            self.cancelButton.isHidden = true
            self.startButton.isEnabled = true
            self.parentProgress!.removeObserver(self, forKeyPath: "fractionCompleted")
            self.parentProgress!.removeObserver(self, forKeyPath: "localizedDescription")
            print("Task 2 complete")
        }
        self.parentProgress!.resignCurrent()
    }

    @IBAction func pauseTask(_ sender : AnyObject) {
        if let progress = self.parentProgress {
            if progress.isPaused {
                //progress.resume???
                // How do you resume a paused NSProgress?
                //self.pauseButton.title = "Pause"
            } else {
                progress.pause()
                self.pauseButton.title = "Resume"
            }
        }
    }
    
    @IBAction func cancelTask(_ sender : AnyObject) {
        if let progress = self.parentProgress {
            progress.cancel()
            self.pauseButton.title = "Pause"
        }
    }
    
    func task1(_ completionHandler: @escaping () -> ()) {
        let totalUnitCount: Int64 = 8
        let child1Progress: Progress = Progress(totalUnitCount: totalUnitCount)
        
        queue.async {
            outerLoop: for _ in 1...totalUnitCount {
                for _ in 1 ..< 100 {
                    while child1Progress.isPaused {
                        if child1Progress.isCancelled {
                            child1Progress.completedUnitCount = totalUnitCount
                            break outerLoop
                        } // Don't for get to check for a cancellation
                        usleep(500000) // Check every half a second
                    }
                    if child1Progress.isCancelled {
                        child1Progress.completedUnitCount = totalUnitCount
                        break outerLoop
                    }
                    // Perform your task here. I've just used the sleep function to waste some time
                    usleep(3200)
                }
                child1Progress.completedUnitCount += 1 // Increment the progress instance
            }
            DispatchQueue.main.async(execute: completionHandler)
        }
        
    }
    
    func task2(_ completionHandler: @escaping () -> ()) {
        let totalUnitCount: Int64 = 100
        let child2Progress: Progress = Progress(totalUnitCount: totalUnitCount)
        
        queue.async {
            for _ in 1...totalUnitCount {
                if child2Progress.isCancelled {
                    child2Progress.completedUnitCount = totalUnitCount
                    break
                } else {
                    // Perform your task here. I've just used the sleep function to waste some time
                    usleep(12800)
                    child2Progress.completedUnitCount += 1 // Increment the progress instance
                }
            }
            DispatchQueue.main.async(execute: completionHandler)
        }
    }
}


