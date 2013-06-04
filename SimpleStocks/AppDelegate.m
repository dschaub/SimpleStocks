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
@synthesize controller;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setHighlightMode:YES];
    [statusItem setTitle:@"Status"];
    [statusItem setMenu:statusMenu];
    
    controller = [[SSController alloc] init];
    controller.statusItem = statusItem;
    
    [controller start];
}

@end
