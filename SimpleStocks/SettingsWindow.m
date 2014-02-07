//
//  Settings.m
//  SimpleStocks
//
//  Created by Daniel Schaub on 2/6/14.
//  Copyright (c) 2014 Daniel Schaub. All rights reserved.
//

#import "SettingsWindow.h"
#import "AppDelegate.h"
#import <math.h>

#define ALLOCATION_KEY @"allocation"
#define DATA_SOURCE_KEY @"allocationDataSource"

@interface SettingsWindow ()
@end

@implementation SettingsWindow

@synthesize allocationSlider, allocationDataSource, allocationLabel;
@synthesize okButton, cancelButton;

- (IBAction)sliderMoved:(NSSlider*)sender {
    double value = [sender doubleValue];
    [allocationLabel setStringValue:[NSString stringWithFormat:@"%d%% stocks", (int)round(value)]];
}

- (IBAction)clickedOK:(id)sender {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    double allocation = [allocationSlider doubleValue];
    
    [settings setObject:[NSString stringWithFormat:@"0.%d", (int)round(allocation)] forKey:ALLOCATION_KEY];
    [settings setObject:[allocationDataSource stringValue] forKey:DATA_SOURCE_KEY];
    
    AppDelegate* delegate = [NSApp delegate];
    [delegate refreshNow:sender];
    
    [self.window close];
}

- (IBAction)clickedCancel:(id)sender {
    [self.window close];
}

- (void)windowDidLoad {
    [super windowDidLoad];

    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    NSString *allocationSetting = [settings objectForKey:ALLOCATION_KEY];
    NSString *dataSourceSetting = [settings objectForKey:DATA_SOURCE_KEY];
    
    if (dataSourceSetting) {
        [allocationDataSource setStringValue:dataSourceSetting];
    }
    
    if (allocationSetting) {
        [allocationSlider setDoubleValue:[allocationSetting doubleValue]*100];
        [self sliderMoved:allocationSlider];
    }
}

@end
