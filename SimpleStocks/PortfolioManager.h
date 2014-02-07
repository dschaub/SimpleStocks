//
//  Portfolio.h
//  SimpleStocks
//
//  Created by Daniel Schaub on 2/3/14.
//  Copyright (c) 2014 Daniel Schaub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PortfolioManager : NSObject

+ (NSDictionary*)portfolio: (int)allocation;

@end
