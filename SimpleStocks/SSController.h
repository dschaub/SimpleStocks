//
//  SSController.h
//  SimpleStocks
//
//  Created by Daniel Schaub on 6/2/13.
//  Copyright (c) 2013 Daniel Schaub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHCSVParser.h"

#define API_URL @"http://finance.yahoo.com/d/quotes.csv?s=%@&f=snl1p2"
#define SP500 @"%5EGSPC"

@interface SSController : NSObject <NSURLConnectionDelegate, CHCSVParserDelegate>

@property NSStatusItem *statusItem;
@property NSMutableData *receivedData;
@property NSString *lastData;
@property (assign) BOOL blocking;
@property NSTimer *timer;

- (void)start;
- (void)makeRequest:(NSTimer*)timer;
- (void)parseAndRender;

@end
