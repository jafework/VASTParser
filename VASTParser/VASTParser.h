//
//  VASTParser.h
//  VASTParser
//
//  Created by Joseph Afework on 12/28/13.
//  Copyright (c) 2013 Joseph Afework. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VASTParserDelegate <NSObject>
@required
-(void)parserDidFinish:(NSMutableArray*)ads;
@optional
-(void)wrapperDidFinish:(NSMutableArray*)ads;
@end

@interface VASTParser : NSObject<VASTParserDelegate>
@property (nonatomic, weak) id<VASTParserDelegate> delegate;

-(id)initWithVASTUrl:(NSURL*)url;
-(void)start;
-(void)abort;
@end
