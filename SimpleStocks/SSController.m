//
//  SSController.m
//  SimpleStocks
//
//  Created by Daniel Schaub on 6/2/13.
//  Copyright (c) 2013 Daniel Schaub. All rights reserved.
//

#import "SSController.h"

@implementation SSController

@synthesize statusItem;
@synthesize receivedData;
@synthesize blocking;
@synthesize lastData;
@synthesize timer;
@synthesize isFirstRun;

- (void)start {
    isFirstRun = YES;
    [self makeRequest:nil];
    if (timer) {
        [timer invalidate];
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(makeRequest:) userInfo:nil repeats:YES];
}

- (void)start:(NSTimer*)timer {
    [self start];
}

- (NSDictionary*)getPortfolio {
    return [Portfolio portfolio: 70];
}

- (void)makeRequest:(NSTimer*)timer {
    NSLog(@"Called makeRequest");
    if (!blocking && ([self isMarketHours] || isFirstRun)) {
        blocking = YES;
        isFirstRun = NO;
        
        NSString *tickers = @"";
        
        for (NSString *ticker in [self getPortfolio]) {
            tickers = [NSString stringWithFormat:@"%@,%@", tickers, ticker];
        }
        
        NSString *formattedUrl = [NSString stringWithFormat:API_URL, tickers];
        NSURL *url = [NSURL URLWithString:formattedUrl];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60.0];
        
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
        
        if (connection) {
            receivedData = [[NSMutableData alloc] init];
        }
    }
}

- (void)parseAndRender {
    NSArray *lines = [lastData CSVComponentsWithOptions:CHCSVParserOptionsSanitizesFields];
    
    NSDictionary *portfolio = [self getPortfolio];
    float indexPrevious = 0.0f;
    float indexLast = 0.0f;
    
    for (int i = 0; i < [lines count]; i++) {
        NSArray *row = [lines objectAtIndex:i];
        
        if ([row count] > 1) {
            NSString *symbol = [row objectAtIndex:SYMBOL_INDEX];
            float last = [[row objectAtIndex:LAST_INDEX] floatValue];
            float previousClose = [[row objectAtIndex:PREVIOUS_CLOSE_INDEX] floatValue];
            
            float allocation = [[portfolio objectForKey:symbol] floatValue];
            
            indexPrevious += allocation * previousClose;
            indexLast += allocation * last;
        }
    }
    
    NSString *name = @"Betterment 70/30";
    NSString *last = [NSString stringWithFormat:@"%.2f", indexLast];
    NSString *change = [NSString stringWithFormat:@"%.2f", indexLast - indexPrevious];
    NSString *percent = [NSString stringWithFormat:@"%.2f%%", ((indexLast - indexPrevious) / indexPrevious) * 100.0];
    
    NSDictionary *pieces = [NSDictionary dictionaryWithObjectsAndKeys:
                                name, @"name",
                                last, @"last",
                                change, @"change",
                                percent, @"percent",
                                nil];
    
    [self render:pieces];
}

- (void)render:(NSDictionary*)data {
    NSColor *color;
    if ([[data objectForKey:@"change"] hasPrefix:@"-"]) {
        color = [NSColor colorWithSRGBRed:0.7 green:0.0 blue:0.0 alpha:1.0];
    } else {
        color = [NSColor colorWithSRGBRed:0.0 green:0.4 blue:0.0 alpha:1.0];
    }

    NSString *display = [self parseFormat:STATUS_FORMAT withDict:data];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    NSAttributedString *attributedDisplay = [[NSAttributedString alloc] initWithString:display attributes:attributes];
    [statusItem setAttributedTitle:attributedDisplay];
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

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response {
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection {
    lastData = [[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding];
    [self parseAndRender];
    blocking = NO;
    NSLog(@"Connection finished successfully");
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
    blocking = NO;
    
    [statusItem setTitle:@"Loading..."];
    NSLog(@"Connection failed: %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    [timer invalidate];
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(start:) userInfo:nil repeats:NO];
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
