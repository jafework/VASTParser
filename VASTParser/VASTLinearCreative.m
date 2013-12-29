//
//  VASTLinearCreative.m
//  VASTParser
//
//  Created by Joseph Afework on 12/29/13.
//  Copyright (c) 2013 Joseph Afework. All rights reserved.
//

#import "VASTLinearCreative.h"

@implementation VASTLinearCreative

-(id)initWithVASTCreative:(VASTCreative*)creative{
    self = [super init];
    if(self){
        self.adID = creative.adID;
        self.creativeID = creative.creativeID;
        self.sequence = creative.sequence;
        self.apiFramework = creative.apiFramework;
    }
    return self;
}

-(NSMutableDictionary*)VASTTrackingEvents{
    if(_VASTTrackingEvents == nil){
        _VASTTrackingEvents = [[NSMutableDictionary alloc] init];
    }
    return _VASTTrackingEvents;
}


-(NSDictionary*)VASTVideoClicks{
    if(_VASTVideoClicks == nil){
        _VASTVideoClicks = [[NSDictionary alloc]
        initWithObjects:
            @[[[NSMutableArray alloc] init], [[NSMutableArray alloc] init], [[NSMutableArray alloc] init]]
        forKeys:@[@"ClickThrough",@"ClickTracking",@"CustomClick"]];
    }
    return _VASTVideoClicks;
}

@end
