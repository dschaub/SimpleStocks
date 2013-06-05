//
//  AppDelegate.h
//  SimpleStocks
//
//  Created by Daniel Schaub on 6/2/13.
//  Copyright (c) 2013 Daniel Schaub. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SSController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property SSController *controller;
@property NSStatusItem *statusItem;
@property (weak) IBOutlet NSMenu *statusMenu;

- (IBAction)refreshNow:(id)sender;

@end
