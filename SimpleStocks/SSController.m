//
//  SSController.m
//  SimpleStocks
//
//  Created by Daniel Schaub on 6/2/13.
//  Copyright (c) 2013 Daniel Schaub. All rights reserved.
//

#import "SSController.h"
#import "AppDelegate.h"

#define TICKER_MENU_ITEM_TAG 42

#define RED_COLOR ([NSColor colorWithSRGBRed:0.7 green:0.0 blue:0.0 alpha:1.0])
#define GREEN_COLOR ([NSColor colorWithSRGBRed:0.0 green:0.4 blue:0.0 alpha:1.0])

@implementation SSController

@synthesize blocking, statusItem, statusMenu, timer, isFirstRun;

- (void)start {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    if (![settings objectForKey:@"allocationDataSource"] || ![settings objectForKey:@"allocation"]) {
        AppDelegate* appDelegate = [NSApp delegate];
        [appDelegate openSettings:nil];
        return;
    }
    [PortfolioManager loadDataAndCallback:self selector:@selector(startRequestCycle)];
}

- (void)start:(NSTimer*)timer {
    [self startRequestCycle];
}

- (void)startRequestCycle {
    isFirstRun = YES;
    [self makeRequest:nil];
    if (timer) {
        [timer invalidate];
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(makeRequest:) userInfo:nil repeats:YES];
}

- (NSDictionary*)getPortfolio {
    return [PortfolioManager currentPortfolio];
}

- (void)makeRequest:(NSTimer*)timer {
    NSLog(@"Called makeRequest");
    if (!blocking && ([self isMarketHours] || isFirstRun)) {
        blocking = YES;
        isFirstRun = NO;
        
        NSString *tickers = nil;
        
        for (NSString *ticker in [self getPortfolio]) {
            if (tickers == nil) {
                tickers = ticker;
            } else {
                tickers = [NSString stringWithFormat:@"%@,%@", tickers, ticker];
            }
        }
        
        NSString *formattedUrl = [NSString stringWithFormat:API_URL, tickers];
        
        [GetRequest getUrl:formattedUrl delegate:self];
    }
}

- (void)success: (NSString*)result {
    blocking = NO;
    [self parseAndRender: result];
}

- (void)fail: (NSError*)error {
    blocking = NO;
    
    [statusItem setTitle:@"Loading..."];
    
    [timer invalidate];
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(start:) userInfo:nil repeats:NO];
}

- (void)parseAndRender: (NSString*)result {
    NSArray *lines = [result CSVComponentsWithOptions:CHCSVParserOptionsSanitizesFields];
    [self clearQuotes];
    
    NSDictionary *portfolio = [self getPortfolio];
    float indexPrevious = 0.0f;
    float indexLast = 0.0f;
    
    for (int i = 0; i < [lines count]; i++) {
        NSArray *row = [lines objectAtIndex:i];
    
        if ([row count] == EXPECTED_COLUMNS) {
            [self addQuote:row];
            
            NSString *symbol = [row objectAtIndex:SYMBOL_INDEX];
            float last = [[row objectAtIndex:LAST_INDEX] floatValue];
            float previousClose = [[row objectAtIndex:PREVIOUS_CLOSE_INDEX] floatValue];
            
            float allocation = [[portfolio objectForKey:symbol] floatValue];
            
            indexPrevious += allocation * previousClose;
            indexLast += allocation * last;
        }
    }
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    double allocation = [[settings objectForKey:@"allocation"] doubleValue] * 100;
    
    NSString *name = [NSString stringWithFormat:@"Betterment %d%%", (int)allocation];
    NSString *last = [NSString stringWithFormat:@"%.2f", indexLast];
    
    double changeValue = indexLast - indexPrevious;
    NSString *plus = changeValue > 0 ? @"+" : @"";
    NSString *change = [NSString stringWithFormat:@"%@%.2f", plus, changeValue];
    NSString *percent = [NSString stringWithFormat:@"%@%.2f%%", plus, ((indexLast - indexPrevious) / indexPrevious) * 100.0];
    
    NSDictionary *pieces = [NSDictionary dictionaryWithObjectsAndKeys:
                                name, @"name",
                                last, @"last",
                                change, @"change",
                                percent, @"percent",
                                nil];
    
    [statusItem setAttributedTitle: [self render:pieces]];
}

- (NSAttributedString*)render:(NSDictionary*)data {
    NSColor *color;
    if ([[data objectForKey:@"change"] hasPrefix:@"-"]) {
        color = RED_COLOR;
    } else {
        color = GREEN_COLOR;
    }

    NSString *display = [self parseFormat:STATUS_FORMAT withDict:data];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    NSAttributedString *attributedDisplay = [[NSAttributedString alloc] initWithString:display attributes:attributes];
    
    return attributedDisplay;
}

- (void)clearQuotes {
    for (NSMenuItem *item in [statusMenu itemArray]) {
        if ([item tag] == TICKER_MENU_ITEM_TAG) {
            [statusMenu removeItem:item];
        }
    }
    
    NSMenuItem *separator = [NSMenuItem separatorItem];
    [separator setTag: TICKER_MENU_ITEM_TAG];
    [statusMenu insertItem:separator atIndex:0];
}

- (void)addQuote: (NSArray*)row {
    NSMenuItem *item = [[NSMenuItem alloc] init];
    [item setTag:TICKER_MENU_ITEM_TAG];
    
    NSString *symbol = [row objectAtIndex:SYMBOL_INDEX];
    double allocation = [[[PortfolioManager currentPortfolio] objectForKey:symbol] doubleValue];
    
    if (allocation > 0) {
        NSString *name = [NSString stringWithFormat:@"%@ (%.1f%%)", symbol, allocation * 100];
        
        NSDictionary *pieces = [NSDictionary dictionaryWithObjectsAndKeys:
                                name, @"name",
                                [row objectAtIndex:LAST_INDEX], @"last",
                                [row objectAtIndex:CHANGE_INDEX], @"change",
                                [row objectAtIndex:PERCENT_INDEX], @"percent",
                                nil];
        
        [item setAttributedTitle:[self render:pieces]];
        
        [statusMenu insertItem:item atIndex:0];
    }
}

- (BOOL)isMarketHours {
    NSDate *now = [[NSDate alloc] init];
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSUInteger units = NSHourCalendarUnit | NSMinuteCalendarUnit | NSWeekdayCalendarUnit;
    NSDateComponents *time = [cal components:units fromDate:now];
    
    float hours = (float)[time hour] + (float)[time minute] / 60.0;
    return [time weekday] > 1 && [time weekday] < 7 &&
           hours > 9.5 && hours < 16.0;
}

- (NSString*)parseFormat:(NSString*)format withDict:(NSDictionary*)data {
    NSString *output = [NSString stringWithString:format];
    for (NSString *key in [data keyEnumerator]) {
        NSString *formattedKey = [NSString stringWithFormat:@"{%@}", key];
        output = [output stringByReplacingOccurrencesOfString:formattedKey withString:[data objectForKey:key]];
    }
    return output;
}


#pragma mark -

- (void)sleepNotification:(NSNotification *)notification {
    [timer invalidate];
}

- (void)wakeupNotification:(NSNotification *)notification {
    [self start];
}

- (void)dealloc {
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver: self];
}

@end
