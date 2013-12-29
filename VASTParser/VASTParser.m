//
//  VASTParser.m
//  VASTParser
//
//  Created by Joseph Afework on 12/28/13.
//  Copyright (c) 2013 Joseph Afework. All rights reserved.
//

#import "VASTParser.h"
#import "VASTAd.h"
#import "VASTCreative.h"
#import "VASTLinearCreative.h"
#import "VASTMediaFile.h"

@interface VASTParser ()<NSXMLParserDelegate>

@property (nonatomic, strong) NSXMLParser *parser;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSMutableString *node;
@property (nonatomic, strong) NSMutableArray *ads;
@property (nonatomic, strong) NSString *trackingEvent;
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

#pragma mark - Lazy Load Instance Variables
-(NSMutableArray *)ads{
    if(_ads == nil){
        _ads = [[NSMutableArray alloc] init];
    }
    return _ads;
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
    VASTAd *currentAd = [self.ads lastObject];
    
    if([elementName isEqualToString:@"Ad"]){
        VASTAd *newAd = [[VASTAd alloc] init];
        newAd.adID = attributeDict[@"id"];
        [self.ads addObject:newAd];
    }
    
    else if ([elementName isEqualToString:@"Creative"]){
        VASTCreative *newCreative = [[VASTCreative alloc] init];
        newCreative.creativeID = attributeDict[@"AdID"];
        currentAd.VASTCreatives = [currentAd.VASTCreatives arrayByAddingObject:newCreative];
        
        // Todo Append other attributes
    }
    
    else if ([elementName isEqualToString:@"Linear"]){
        VASTLinearCreative *newLinearCreative = [[VASTLinearCreative alloc] initWithVASTCreative:[currentAd.VASTCreatives lastObject]];
        
        currentAd.VASTCreatives = [[currentAd.VASTCreatives objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, currentAd.VASTCreatives.count-1) ]] arrayByAddingObject:newLinearCreative];
    }
    
    else if ([elementName isEqualToString:@"Tracking"]){
       self.trackingEvent = attributeDict[@"event"];
    }
    
    else if ([elementName isEqualToString:@"MediaFile"]){
        VASTMediaFile *newMediaFile = [[VASTMediaFile alloc] init];
        newMediaFile.delivery = attributeDict[@"delivery"];
        newMediaFile.type = attributeDict[@"type"];
        newMediaFile.bitrate = attributeDict[@"bitrate"];
        newMediaFile.width = attributeDict[@"width"];
        newMediaFile.height = attributeDict[@"height"];
        newMediaFile.scalable = attributeDict[@"scalable"];
        newMediaFile.maintainAspectRatio = attributeDict[@"maintainAspectRatio"];
        
        VASTLinearCreative *currentLinearCreative = [currentAd.VASTCreatives lastObject];
        currentLinearCreative.VASTMediaFiles = [currentLinearCreative.VASTMediaFiles arrayByAddingObject:newMediaFile];
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    [self.node appendString:string];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    VASTAd *currentAd = [self.ads lastObject];
    
    if([elementName isEqualToString:@"AdSystem"]){
        currentAd.adSystem = [self.node copy];
    }
    else if ([elementName isEqualToString:@"AdTitle"]){
        currentAd.adTitle = [self.node copy];
    }
    else if ([elementName isEqualToString:@"Description"]){
        currentAd.description = [self.node copy];
    }
    else if ([elementName isEqualToString:@"Survey"]){
        currentAd.description = [self.node copy];
    }
    else if ([elementName isEqualToString:@"Error"]){
        currentAd.Errors = [currentAd.Errors arrayByAddingObject:[NSURL URLWithString:[self.node copy]]];
    }
    else if ([elementName isEqualToString:@"Impression"]){
        currentAd.Impressions = [currentAd.Impressions arrayByAddingObject:[NSURL URLWithString:[self.node copy]]];
    }
    
    if([[currentAd.VASTCreatives lastObject] isKindOfClass:[VASTLinearCreative class]]){
    
        VASTLinearCreative *currentLinearCreative = [currentAd.VASTCreatives lastObject];
            
        if ([elementName isEqualToString:@"Duration"]){
             currentLinearCreative.duration = [self.node copy];
        }
        
        else if ([elementName isEqualToString:@"Tracking"]){
            
            if([currentLinearCreative.VASTTrackingEvents objectForKey:self.trackingEvent] == nil){
                [currentLinearCreative.VASTTrackingEvents setObject:[[NSMutableArray alloc] init] forKey:self.trackingEvent];
            }
            
            [currentLinearCreative.VASTTrackingEvents[self.trackingEvent] addObject:[NSURL URLWithString:[self.node copy]]];
        }
        
        else if ([elementName isEqualToString:@"ClickThrough"] || [elementName isEqualToString:@"ClickTracking"] || [elementName isEqualToString:@"CustomClick"]){
            [currentLinearCreative.VASTVideoClicks[elementName] addObject:[NSURL URLWithString:[self.node copy]]];
        }
        
        else if ([elementName isEqualToString:@"MediaFile"]){
            VASTMediaFile *currentMediaFile = [currentLinearCreative.VASTMediaFiles lastObject];
            currentMediaFile.url = [NSURL URLWithString:[self.node copy]];
        }
    }
    
}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    [self parserDidFinish:self.ads];
}

#pragma mark - VASTParser Delegate
-(void)parserDidFinish:(NSMutableArray*)ads{
    if([NSThread isMainThread] == NO){
        NSLog(@"Not on main queue, dispatching now");
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            [self parserDidFinish:ads];
        }];
    }
    else{
        if([self.delegate respondsToSelector:@selector(parserDidFinish:)]){
            [self.delegate parserDidFinish:ads];
        }
    }
}

@end
