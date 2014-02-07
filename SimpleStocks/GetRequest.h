//
//  RequestManager.h
//  SimpleStocks
//
//  Created by Daniel Schaub on 2/6/14.
//  Copyright (c) 2014 Daniel Schaub. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GetRequestDelegate <NSObject>

- (void)success: (NSString*)result;
- (void)fail: (NSError*)error;

@end

@interface GetRequest : NSObject <NSURLConnectionDelegate>

@property id <GetRequestDelegate> delegate;

+ (NSURLConnection*)getUrl: (NSString*)url delegate: (id<GetRequestDelegate>)delegate;

@end