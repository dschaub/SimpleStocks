//
//  Portfolio.m
//  SimpleStocks
//
//  Created by Daniel Schaub on 2/3/14.
//  Copyright (c) 2014 Daniel Schaub. All rights reserved.
//

#import "PortfolioManager.h"

static PortfolioManager *instance;

@interface PortfolioManager ()
@property id requestDelegate;
@property (assign) SEL requestSelector;
@property NSDictionary *allocationData;
@end

@implementation PortfolioManager

@synthesize requestDelegate, requestSelector, allocationData;

+ (PortfolioManager*)getInstance {
    if (instance == nil) {
        instance = [[PortfolioManager alloc] init];
    }
    return instance;
}

+ (void)loadDataAndCallback:(id)delegate selector:(SEL)selector {
    PortfolioManager *manager = [PortfolioManager getInstance];
    manager.requestDelegate = delegate;
    manager.requestSelector = selector;
    
    if ([self currentPortfolio] == nil) {
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        NSString *url = [settings objectForKey:@"allocationDataSource"];
        if (url == nil) {
            return;
        }
        
        NSLog(@"Portfolio set URL is %@", url);
        
        [GetRequest getUrl:url delegate:(id <GetRequestDelegate>)manager];
    } else {
        [manager finishedLoadingPortfolioData];
    }
}

+ (NSDictionary*)currentPortfolio {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *allocation = [settings objectForKey:@"allocation"];

    return [[PortfolioManager getInstance] componentsForAllocation:allocation];
}

- (NSDictionary*)componentsForAllocation: (NSString*)allocation {
    if (allocationData) {
        return [allocationData objectForKey:allocation];
    }
    NSLog(@"Tried to get components without initializing allocation data");
    return nil;
}

- (void)finishedLoadingPortfolioData {
    IMP method = [requestDelegate methodForSelector:requestSelector];
    void (*func)(id, SEL) = (void*) method;
    func(requestDelegate, requestSelector);
}

- (void)success: (NSString*)result {
    NSLog(@"Finished loading portfolio set data");
    
    NSData *data = [result dataUsingEncoding:NSASCIIStringEncoding];
    NSError *error = nil;
    NSDictionary* portfolioSet = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (error) {
        NSLog(@"Could not derialize JSON data");
        return;
    }
    
    allocationData = [portfolioSet objectForKey:@"componentAllocations"];
    
    [self finishedLoadingPortfolioData];
}

- (void)fail: (NSError*)error {
    NSLog(@"Failed to load portfolio set data");
}

@end
