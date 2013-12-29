//
//  VASTMediaFile.h
//  VASTParser
//
//  Created by Joseph Afework on 12/29/13.
//  Copyright (c) 2013 Joseph Afework. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VASTMediaFile : NSObject

@property (nonatomic, strong) NSString *mediaFileID;
@property (nonatomic, strong) NSString *delivery;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *bitrate;
@property (nonatomic, strong) NSString *minBitrate;
@property (nonatomic, strong) NSString *maxBitrate;
@property (nonatomic, strong) NSString *width;
@property (nonatomic, strong) NSString *height;
@property (nonatomic, strong) NSString *scalable;
@property (nonatomic, strong) NSString *maintainAspectRatio;
@property (nonatomic, strong) NSString *codec;
@property (nonatomic, strong) NSString *apiFramework;

@end
