//
//  PomodoroApp.swift
//  Pomodoro
//
//  Created by Gian Luca Brandolese on 23/07/2025.
//

import SwiftUI
import AppKit

@main
struct PomodoroApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var timerState = TimerState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(timerState)
                .onAppear {
                    appDelegate.timerState = timerState
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var timerState = TimerState()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Crea l'elemento della status bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.title = "🍅"
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        // Crea il popover
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 400, height: 600)
        popover?.behavior = .transient
        
        // Avvia il timer per aggiornare la status bar
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.updateStatusBar()
        }
    }
    
    func updateStatusBar() {
        guard let button = statusItem?.button else { return }
        
        if timerState.isRunning {
            let timeString = timerState.formatTime()
            button.title = "🍅 \(timeString)"
        } else {
            button.title = "🍅"
        }
    }
    
    @objc func togglePopover() {
        if let popover = popover {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                if let button = statusItem?.button {
                    // Crea una nuova istanza di ContentView con il timerState condiviso
                    popover.contentViewController = NSHostingController(rootView: ContentView().environmentObject(timerState))
                    popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                }
            }
        }
    }
}
