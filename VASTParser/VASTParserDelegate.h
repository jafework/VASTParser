//
//  VASTParserDelegate.h
//  VASTParser
//
//  Created by Joseph Afework on 1/6/14.
//  Copyright (c) 2014 Joseph Afework. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VASTParserDelegate <NSObject>

@required
-(void)parserDidFinish:(NSMutableArray*)ads;
@end