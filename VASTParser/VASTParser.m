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
@property (nonatomic, strong) VASTAd *wrapper;
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

-(id)initWithVASTAd:(VASTAd *)wrapper{
    self = [super init];
    if(self){
        self.parser = [[NSXMLParser alloc] initWithContentsOfURL:wrapper.adTagURL];
        self.parser.delegate = self;
        self.wrapper = wrapper;
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
    if(self.wrapper == nil){
        [self.queue addOperationWithBlock:^{
            [self.parser parse];
        }];
    }
    else{
        //Only Used when expanding Wrappers, (Thread is already backgrounded)
        [self.parser parse];
    }
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
    
    else if([elementName isEqualToString:@"InLine"]){
        currentAd.isWrapper = NO;
        currentAd.adTagURL = nil;
    }
    
    else if ([elementName isEqualToString:@"Wrapper"]){
        currentAd.isWrapper = YES;
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
        currentAd.Errors = [currentAd.Errors arrayByAddingObject:[NSURL URLWithString:[[self.node copy] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];
        
    }
    else if ([elementName isEqualToString:@"Impression"]){
        currentAd.Impressions = [currentAd.Impressions arrayByAddingObject:[NSURL URLWithString:[[self.node copy] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];
    }
    
    else if ([elementName isEqualToString:@"VASTAdTagURI"]){
        currentAd.adTagURL = [NSURL URLWithString:[self.node copy]];
    }
    
    if([[currentAd.VASTCreatives lastObject] isKindOfClass:[VASTLinearCreative class]] && currentAd.isWrapper == NO){
    
        VASTLinearCreative *currentLinearCreative = [currentAd.VASTCreatives lastObject];
            
        if ([elementName isEqualToString:@"Duration"]){
             currentLinearCreative.duration = [self.node copy];
        }
        
        else if ([elementName isEqualToString:@"Tracking"]){
            
            if([currentLinearCreative.VASTTrackingEvents objectForKey:self.trackingEvent] == nil){
                [currentLinearCreative.VASTTrackingEvents setObject:[[NSMutableArray alloc] init] forKey:self.trackingEvent];
            }
            
            [currentLinearCreative.VASTTrackingEvents[self.trackingEvent] addObject:[NSURL URLWithString:[[self.node copy] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];
        }
        
        else if ([elementName isEqualToString:@"ClickThrough"] || [elementName isEqualToString:@"ClickTracking"] || [elementName isEqualToString:@"CustomClick"]){
            [currentLinearCreative.VASTVideoClicks[elementName] addObject:[NSURL URLWithString:[[self.node copy] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];
        }
        
        else if ([elementName isEqualToString:@"MediaFile"]){
            VASTMediaFile *currentMediaFile = [currentLinearCreative.VASTMediaFiles lastObject];
            currentMediaFile.url = [NSURL URLWithString:[[self.node copy] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        }
    }
    
}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    
    if(self.wrapper){
        //self.ads contains the result behind the wrapper need to merge the wrapper results into self.ads
        [self mergeAds];
        [self.delegate wrapperDidFinish:self.ads];
    }
    else{
        [self followWrappers];
    }
}

-(void)mergeAds{
    // Merge the wrapper and self.ads data here
    
    for(VASTAd *ad in self.ads){
        ad.Impressions = [ad.Impressions arrayByAddingObjectsFromArray:self.wrapper.Impressions];
        ad.Errors = [ad.Errors arrayByAddingObjectsFromArray:self.wrapper.Errors];
    }
    
}

-(void)followWrappers{
    
    for(VASTAd *ad in self.ads){
        if(ad.isWrapper == YES){
            self.wrapper = ad;
            break;
        }
        else{
            self.wrapper = nil;
        }
    }
    
    if(self.wrapper == nil){
        [self filterAds];
        [self parserDidFinish:self.ads];
    }
    else{
        VASTParser *wrapperParser = [[VASTParser alloc] initWithVASTAd:self.wrapper];
        wrapperParser.delegate = self;
        [wrapperParser start];
    }
}

-(void)filterAds{
    //This is temporary until companion ads and non-linear support is added
    //This method will filter out all ads except for linear ads
    
    for (VASTAd *ad in self.ads) {
        NSMutableArray *filteredCreatives = [[NSMutableArray alloc] init];
        for(VASTCreative *creative in ad.VASTCreatives){
            if([creative isKindOfClass:[VASTLinearCreative class]]){
                [filteredCreatives addObject:creative];
            }
        }
        ad.VASTCreatives = filteredCreatives;
    }
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

-(void)wrapperDidFinish:(NSMutableArray*)ads{
    [self.ads removeObject:self.wrapper];
    self.wrapper = nil;
    [self.ads addObjectsFromArray:ads];
    [self followWrappers];
}

@end
