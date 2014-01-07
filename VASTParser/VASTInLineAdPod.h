//
//  VASTInLineAdPod.h
//  VASTParser
//
//  Created by Joseph Afework on 1/6/14.
//  Copyright (c) 2014 Joseph Afework. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VASTAdPod.h"
@interface VASTInLineAdPod : VASTAdPod
@property (nonatomic, strong) NSString *adTitle;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *advertiser;
@property (nonatomic, strong) NSString *pricing;
@property (nonatomic, strong) NSString *model;
@property (nonatomic, strong) NSString *currency;
-(id)initWithVASTAdPod:(VASTAdPod*)adPod;
@end
