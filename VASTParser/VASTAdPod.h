//
//  VASTAdPod.h
//  VASTParser
//
//  Created by Joseph Afework on 1/6/14.
//  Copyright (c) 2014 Joseph Afework. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VASTAdPod : NSObject
@property (nonatomic, strong) NSString *adID;
@property (nonatomic, strong) NSNumber *sequence;
@property (nonatomic, strong) NSString *adSystem;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSMutableArray *Impressions;
@property (nonatomic, strong) NSMutableArray *Errors;
@property (nonatomic, strong) NSMutableArray *VASTCreatives;
@end
