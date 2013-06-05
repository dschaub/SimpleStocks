//
//  SSController.h
//  SimpleStocks
//
//  Created by Daniel Schaub on 6/2/13.
//  Copyright (c) 2013 Daniel Schaub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHCSVParser.h"

#define API_URL @"http://finance.yahoo.com/d/quotes.csv?s=%@&f=nl1c1p2"
#define SP500 @"%5EGSPC"
#define STATUS_FORMAT @"{name} {last} | {change} ({percent})"

#define NAME_INDEX 0
#define LAST_INDEX 1
#define CHANGE_INDEX 2
#define PERCENT_INDEX 3

@interface SSController : NSObject <NSURLConnectionDelegate, CHCSVParserDelegate>

@property NSStatusItem *statusItem;
@property NSMutableData *receivedData;
@property NSString *lastData;
@property (assign) BOOL blocking;
@property NSTimer *timer;
@property NSArray *requestFormat;
@property NSString *statusFormat;

- (void)start;
- (void)makeRequest:(NSTimer*)timer;
- (void)parseAndRender;
- (BOOL)isMarketHours;
- (NSString*)parseFormat:(NSString*)format withDict:(NSDictionary*)data;
- (void)wakeupNotification:(NSNotification*)notification;
- (void)sleepNotification:(NSNotification*)notification;

@end
