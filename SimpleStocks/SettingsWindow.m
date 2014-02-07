//
//  Settings.m
//  SimpleStocks
//
//  Created by Daniel Schaub on 2/6/14.
//  Copyright (c) 2014 Daniel Schaub. All rights reserved.
//

#import "SettingsWindow.h"
#import <math.h>

@interface SettingsWindow ()

@end

@implementation SettingsWindow

@synthesize allocationSlider, allocationDataSource, allocationLabel;
@synthesize okButton, cancelButton;

- (IBAction)sliderMoved:(NSSlider*)sender {
    double value = [sender doubleValue];
    [allocationLabel setStringValue:[NSString stringWithFormat:@"%d%% stocks", (int)round(value)]];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
