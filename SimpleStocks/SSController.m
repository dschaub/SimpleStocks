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

- (void)start {
    [self makeRequest:nil];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(makeRequest:) userInfo:nil repeats:YES];
}

- (void)makeRequest:(NSTimer*)timer {
    static BOOL isFirstRun = YES;
    if (!self.blocking && ([self isMarketHours] || isFirstRun)) {
        blocking = YES;
        isFirstRun = NO;
        
        NSString *formattedUrl = [NSString stringWithFormat:API_URL, SP500];
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
    NSMutableArray *firstRow = [lines objectAtIndex:0];
    NSString *name = [firstRow objectAtIndex:NAME_INDEX];
    NSString *last = [firstRow objectAtIndex:LAST_INDEX];
    NSString *change = [firstRow objectAtIndex:CHANGE_INDEX];
    NSString *percent = [firstRow objectAtIndex:PERCENT_INDEX];
    
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
    if ([[data objectForKey:@"change"] hasPrefix:@"+"]) {
        color = [NSColor colorWithSRGBRed:0.0 green:0.4 blue:0.0 alpha:1.0];
    } else {
        color = [NSColor colorWithSRGBRed:0.7 green:0.0 blue:0.0 alpha:1.0];
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
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
    [statusItem setTitle:@"Error"];
    NSLog(@"Connection failed: %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
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
