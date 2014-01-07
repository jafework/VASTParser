//
//  VASTWrapperAdPod.m
//  VASTParser
//
//  Created by Joseph Afework on 1/6/14.
//  Copyright (c) 2014 Joseph Afework. All rights reserved.
//

#import "VASTWrapperAdPod.h"

@implementation VASTWrapperAdPod
-(id)initWithVASTAdPod:(VASTAdPod*)adPod{
    self = [super init];
    if(self){
        self.adID = [adPod.adID copy];
        self.sequence = [adPod.sequence copy];
        self.adSystem = [adPod.adSystem copy];
        self.version = [adPod.version copy];
        self.Impressions = [adPod.Impressions mutableCopy];
        self.Errors = [adPod.Errors mutableCopy];
        self.VASTCreatives = [adPod.VASTCreatives mutableCopy];
    }
    return self;
}
@end
