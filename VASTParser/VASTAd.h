//
//  VASTAd.h
//  VASTParser
//
//  Created by Joseph Afework on 12/28/13.
//  Copyright (c) 2013 Joseph Afework. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VASTAd : NSObject
@property (nonatomic) BOOL isWrapper;
@property (nonatomic, strong) NSURL *adTagURL;
@property (nonatomic, strong) NSString *adID;
@property (nonatomic, strong) NSNumber *sequence;
@property (nonatomic, strong) NSString *adSystem;
@property (nonatomic, strong) NSString *adTitle;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *advertiser;
@property (nonatomic, strong) NSString *pricing;
@property (nonatomic, strong) NSString *model;
@property (nonatomic, strong) NSString *currency;
@property (nonatomic, strong) NSArray *Impressions;
@property (nonatomic, strong) NSArray *Errors;
@property (nonatomic, strong) NSArray *VASTCreatives;
    // of VASTCreative (VASTLinearCreative, VASTNonLinearCreative, VASTCompanionAdCreative)
@end
