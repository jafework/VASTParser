//
//  VASTParser.m
//  VASTParser
//
//  Created by Joseph Afework on 12/28/13.
//  Copyright (c) 2013 Joseph Afework. All rights reserved.
//

#import "VASTParser.h"

@interface VASTParser ()<NSXMLParserDelegate>

@property (nonatomic, strong) NSXMLParser *parser;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSMutableString *node;

@end

@implementation VASTParser
#pragma mark - Init Methods
-(id)initWithVASTUrl:(NSURL*)url{
    self = [super init];
    if(self){
        self.queue = [[NSOperationQueue alloc] init];
        self.parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        self.parser.delegate = self;
    }
    return self;
}

#pragma mark - Parser Methods
-(void)start{
    [self.queue addOperationWithBlock:^{
        [self.parser parse];
    }];
}

-(void)abort{
    
}

#pragma mark - NSXMLParser Delegate
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    //Reset node string
    self.node = [[NSMutableString alloc] initWithString:@""];
    NSLog(@"Found: %@", elementName);
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    [self.node appendString:string];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
}

#pragma mark - VASTParser Delegate
-(void)parserDidFinish{
    if([[NSOperationQueue mainQueue] isMainThread] == NO){
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self parserDidFinish];
        }];
    }
    else{
        if([self.delegate respondsToSelector:@selector(parserDidFinish)]){
            [self.delegate parserDidFinish];
        }
    }
}

@end
