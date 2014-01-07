//
//  VASTWrapperAdPod.h
//  VASTParser
//
//  Created by Joseph Afework on 1/6/14.
//  Copyright (c) 2014 Joseph Afework. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VASTAdPod.h"
@interface VASTWrapperAdPod : VASTAdPod
@property (nonatomic, strong) NSURL *adTagURL;
-(id)initWithVASTAdPod:(VASTAdPod*)adPod;
@end
