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
    self.timer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(makeRequest:) userInfo:nil repeats:YES];
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
    NSString *symbol = [firstRow objectAtIndex:1];
    NSString *last = [firstRow objectAtIndex:2];
    NSString *percent = [firstRow objectAtIndex:3];
    
    NSColor *color;
    if ([percent hasPrefix:@"+"]) {
        color = [NSColor colorWithSRGBRed:0.0 green:0.4 blue:0.0 alpha:1.0];
    } else {
        color = [NSColor colorWithSRGBRed:0.7 green:0.0 blue:0.0 alpha:1.0];
    }
    
    NSString *display = [NSString stringWithFormat:@"%@ %@ %@", symbol, last, percent];
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

@end
