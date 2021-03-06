//
//  AppDelegate.m
//  SimpleStocks
//
//  Created by Daniel Schaub on 6/2/13.
//  Copyright (c) 2013 Daniel Schaub. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize statusItem;
@synthesize statusMenu;
@synthesize settingsWindow;
@synthesize controller;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setHighlightMode:YES];
    [statusItem setTitle:@"Loading"];
    [statusItem setMenu:statusMenu];
    
    controller = [[SSController alloc] init];
    controller.statusItem = statusItem;
    controller.statusMenu = statusMenu;
    
    [controller start];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter]
        addObserver:controller
        selector:@selector(sleepNotification:)
        name:NSWorkspaceWillSleepNotification
        object:nil];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter]
        addObserver:controller
        selector:@selector(wakeupNotification:)
        name:NSWorkspaceDidWakeNotification
        object:nil];
}

- (IBAction)refreshNow:(id)sender {
    [controller start];
}

- (IBAction)openSettings:(id)sender {
    if (!settingsWindow) {
        settingsWindow = [[SettingsWindow alloc] initWithWindowNibName:@"SettingsWindow"];
    }
    [settingsWindow.window makeKeyAndOrderFront:sender];
}

@end
