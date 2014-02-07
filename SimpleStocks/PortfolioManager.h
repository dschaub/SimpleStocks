//
//  Portfolio.h
//  SimpleStocks
//
//  Created by Daniel Schaub on 2/3/14.
//  Copyright (c) 2014 Daniel Schaub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GetRequest.h"

@interface PortfolioManager : NSObject <GetRequestDelegate>

+ (PortfolioManager*)getInstance;
+ (void)loadDataAndCallback:(id)delegate selector:(SEL)selector;
+ (NSDictionary*)currentPortfolio;

@end
