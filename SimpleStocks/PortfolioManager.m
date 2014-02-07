//
//  Portfolio.m
//  SimpleStocks
//
//  Created by Daniel Schaub on 2/3/14.
//  Copyright (c) 2014 Daniel Schaub. All rights reserved.
//

#import "PortfolioManager.h"

@implementation PortfolioManager

+ (NSDictionary*)portfolio: (int)allocation {
    NSDictionary* portfolios = @{
        @"70": @{
            @"VTI": @0.1291,
            @"VTIP": @0.0000,
            @"IWS": @0.0414,
            @"VEA": @0.3010,
            @"IWN": @0.0362,
            @"LQD": @0.0517,
            @"VWOB": @0.0417,
            @"AGG": @0.1037,
            @"IVE": @0.1292,
            @"VWO": @0.0630,
            @"BNDX": @0.1030,
            @"SHV": @0.0000
        }
    };
    
    return [portfolios valueForKey:[NSString stringWithFormat:@"%d", allocation]];
}

@end
