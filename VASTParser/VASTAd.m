//
//  VASTAd.m
//  VASTParser
//
//  Created by Joseph Afework on 12/28/13.
//  Copyright (c) 2013 Joseph Afework. All rights reserved.
//

#import "VASTAd.h"

@implementation VASTAd

-(NSArray*)Impressions{
    if(_Impressions == nil){
        _Impressions = [[NSArray alloc] init];
    }
    return _Impressions;
}

-(NSArray*)Errors{
    if(_Errors == nil){
        _Errors = [[NSArray alloc] init];
    }
    return _Errors;
}

-(NSArray*)VASTCreatives{
    if(_VASTCreatives == nil){
        _VASTCreatives = [[NSArray alloc] init];
    }
    return _VASTCreatives;
}

-(NSString*)debugDescription{
    NSMutableString *debug = [[NSMutableString alloc] init];
    [debug appendFormat:@"Ad ID: %@\n", self.adID];
    [debug appendFormat:@"AdSystem: %@\n", self.adSystem];
    [debug appendFormat:@"AdTitle: %@\n", self.adTitle];
    [debug appendFormat:@"Version: %@\n", self.version];
    [debug appendFormat:@"Description: %@\n", self.description];
    [debug appendFormat:@"Advertiser: %@\n", self.advertiser];
    [debug appendFormat:@"Pricing: %@\n", self.pricing];
    [debug appendFormat:@"Model: %@\n", self.model];
    [debug appendFormat:@"Currency: %@\n", self.currency];
    [debug appendFormat:@"Impressions: %@\n", self.Impressions];
    [debug appendFormat:@"Errors: %@\n", self.Errors];
    
    [debug appendFormat:@"%@",[self.VASTCreatives debugDescription]];
    return debug;
}

@end
