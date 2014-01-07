//
//  VASTAdPod.m
//  VASTParser
//
//  Created by Joseph Afework on 1/6/14.
//  Copyright (c) 2014 Joseph Afework. All rights reserved.
//

#import "VASTAdPod.h"

@implementation VASTAdPod
-(NSArray*)Impressions{
    if(_Impressions == nil){
        _Impressions = [[NSMutableArray alloc] init];
    }
    return _Impressions;
}

-(NSArray*)Errors{
    if(_Errors == nil){
        _Errors = [[NSMutableArray alloc] init];
    }
    return _Errors;
}

-(NSArray*)VASTCreatives{
    if(_VASTCreatives == nil){
        _VASTCreatives = [[NSMutableArray alloc] init];
    }
    return _VASTCreatives;
}
@end
