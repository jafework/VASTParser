//
//  VASTLinearCreative.h
//  VASTParser
//
//  Created by Joseph Afework on 12/29/13.
//  Copyright (c) 2013 Joseph Afework. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VASTCreative.h"
@interface VASTLinearCreative : VASTCreative

@property (nonatomic, strong) NSString *skipOffset;
@property (nonatomic, strong) NSString *duration;
@property (nonatomic, strong) NSArray *VASTMediaFilesArray;
    // of VASTMediaFile
@property (nonatomic, strong) NSMutableDictionary *VASTTrackingEvents;
	//NSDictionary ("EventName"-> NSArray(NSURL)) -  VASTTrackingEvents
@property (nonatomic, strong) NSDictionary *VASTVideoClicks;
	//NSDictionary ("ClickType"-> NSArray(NSURL)) -  VASTVideoClicks
@property (nonatomic, strong) NSArray *VASTMediaFiles;
    //of VASTMediaFile
-(id)initWithVASTCreative:(VASTCreative*)creative;
@end
