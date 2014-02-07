//
//  Settings.h
//  SimpleStocks
//
//  Created by Daniel Schaub on 2/6/14.
//  Copyright (c) 2014 Daniel Schaub. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SettingsWindow : NSWindowController

@property IBOutlet NSSlider *allocationSlider;
@property IBOutlet NSTextField *allocationDataSource;
@property IBOutlet NSTextField *allocationLabel;
@property IBOutlet NSButton *okButton;
@property IBOutlet NSButton *cancelButton;

- (IBAction)sliderMoved:(id)sender;

@end
