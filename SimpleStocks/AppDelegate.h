//
//  AppDelegate.h
//  SimpleStocks
//
//  Created by Daniel Schaub on 6/2/13.
//  Copyright (c) 2013 Daniel Schaub. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SSController.h"
#import "SettingsWindow.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property SSController *controller;
@property NSStatusItem *statusItem;

@property (weak) IBOutlet NSMenu *statusMenu;
@property (strong) IBOutlet SettingsWindow *settingsWindow;

- (IBAction)refreshNow:(id)sender;
- (IBAction)openSettings:(id)sender;

@end
