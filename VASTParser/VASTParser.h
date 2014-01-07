//
//  VASTParser.h
//  VASTParser
//
//  Created by Joseph Afework on 12/28/13.
//  Copyright (c) 2013 Joseph Afework. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VASTParserDelegate.h"

@interface VASTParser : NSObject<VASTParserDelegate>
@property (nonatomic, weak) id<VASTParserDelegate> delegate;

-(id)initWithVASTUrl:(NSURL*)url;
-(void)start;
@end
