//
//  VASTParser.m
//  VASTParser
//
//  Created by Joseph Afework on 12/28/13.
//  Copyright (c) 2013 Joseph Afework. All rights reserved.
//

#import "VASTParser.h"
#import "VASTCreative.h"
#import "VASTLinearCreative.h"
#import "VASTMediaFile.h"
#import "VASTAdPod.h"
#import "VASTInLineAdPod.h"
#import "VASTWrapperAdPod.h"

@interface VASTParser ()<NSXMLParserDelegate>

@property (nonatomic, strong) NSXMLParser *parser;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSMutableString *node;
@property (nonatomic, strong) NSMutableArray *ads;
@property (nonatomic, strong) NSString *trackingEvent;
@property (nonatomic, strong) VASTWrapperAdPod *wrapper;
@end

@implementation VASTParser
#pragma mark - Init Methods (Public)
-(id)initWithVASTUrl:(NSURL*)url{
    self = [super init];
    if(self){
        self.queue = [[NSOperationQueue alloc] init];
        self.parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        self.parser.delegate = self;
        self.wrapper = nil;
    }
    return self;
}

#pragma mark - Init Methods (Private)
-(id)initWithVASTWrapperAdPod:(VASTWrapperAdPod *)wrapper{
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

#pragma mark - Parser Methods (Public)
-(void)start{
    if(self.wrapper == nil){
        [self.queue addOperationWithBlock:^{
            [self.parser parse];
        }];
    }
    else{
        //Only Used when expanding Wrappers, (Task is already backgrounded)
        [self.parser parse];
    }
}

#pragma mark - Parser Methods (Private)

-(void)mergeAds{
    // Merge the wrapper and self.ads data here
    
    for(VASTAdPod *ad in self.ads){
        [ad.Impressions addObjectsFromArray:self.wrapper.Impressions];
        [ad.Errors addObjectsFromArray:self.wrapper.Errors];
    }
    
}

-(void)sortAds{
    [self.ads sortUsingComparator:^NSComparisonResult(VASTAdPod *ad1, VASTAdPod *ad2) {
        return [ad1.sequence compare:ad2.sequence];
    }];
}

-(void)followWrappers{
    
    for(VASTAdPod *ad in self.ads){
        if([ad isKindOfClass:[VASTWrapperAdPod class]] == YES){
            self.wrapper = (VASTWrapperAdPod*)ad;
            break;
        }
        else{
            self.wrapper = nil;
        }
    }
    
    if(self.wrapper == nil){
        //All Wrappers have been parsed
        [self filterAds];
        [self parserDidFinish:self.ads];
    }
    else{
        VASTParser *wrapperParser = [[VASTParser alloc] initWithVASTWrapperAdPod:self.wrapper];
        wrapperParser.delegate = self;
        [wrapperParser start];
    }
}

-(void)filterAds{
    //This is temporary until companion ads and non-linear support is added
    //This method will filter out all ads except for linear ads
    
    for (VASTAdPod *ad in self.ads) {
        NSMutableArray *filteredCreatives = [[NSMutableArray alloc] init];
        for(VASTCreative *creative in ad.VASTCreatives){
            if([creative isKindOfClass:[VASTLinearCreative class]]){
                [filteredCreatives addObject:creative];
            }
        }
        ad.VASTCreatives = filteredCreatives;
    }
}

#pragma mark - NSXMLParser Delegate
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    
    //Reset node string
    self.node = [[NSMutableString alloc] initWithString:@""];
    NSLog(@"Found: %@", elementName);
    
    VASTAdPod *currentAd = [self.ads lastObject];
    
    if([elementName isEqualToString:@"Ad"]){
        VASTAdPod *newAd = [[VASTAdPod alloc] init];
        newAd.adID = attributeDict[@"id"];
        newAd.sequence = [NSNumber numberWithInteger:[attributeDict[@"sequence"] integerValue]];
        [self.ads addObject:newAd];
    }
    
    else if ([elementName isEqualToString:@"Creative"]){
        VASTCreative *newCreative = [[VASTCreative alloc] init];
        newCreative.creativeID = attributeDict[@"AdID"];
        [currentAd.VASTCreatives addObject:newCreative];
        //TODO Append other attributes
    }
    
    else if ([elementName isEqualToString:@"Linear"]){
        VASTLinearCreative *newLinearCreative = [[VASTLinearCreative alloc] initWithVASTCreative:[currentAd.VASTCreatives lastObject]];
        [currentAd.VASTCreatives addObject:newLinearCreative];
    }
    
    else if([elementName isEqualToString:@"InLine"]){
        [self.ads removeLastObject];
        currentAd = [[VASTInLineAdPod alloc] initWithVASTAdPod:currentAd];
        [self.ads addObject:currentAd];
    }
    
    else if ([elementName isEqualToString:@"Wrapper"]){
        [self.ads removeLastObject];
        currentAd = [[VASTWrapperAdPod alloc] initWithVASTAdPod:currentAd];
        [self.ads addObject:currentAd];
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
    VASTAdPod *currentAd = [self.ads lastObject];
    
    if([elementName isEqualToString:@"AdSystem"]){
        currentAd.adSystem = [self.node copy];
    }
    else if ([elementName isEqualToString:@"AdTitle"]){
        ((VASTInLineAdPod*)currentAd).adTitle = [self.node copy];
    }
    else if ([elementName isEqualToString:@"Description"]){
        ((VASTInLineAdPod*)currentAd).description = [self.node copy];
    }
    else if ([elementName isEqualToString:@"Survey"]){
        // TODO
    }
    else if ([elementName isEqualToString:@"Error"]){
        NSString *url = [[self.node copy] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] ];
        [currentAd.Errors addObject:[NSURL URLWithString:url]];
        
    }
    else if ([elementName isEqualToString:@"Impression"]){
        NSString *url = [[self.node copy] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] ];
        
        [currentAd.Impressions addObject:[NSURL URLWithString:url]];
    }
    
    else if ([elementName isEqualToString:@"VASTAdTagURI"]){
        ((VASTWrapperAdPod*)currentAd).adTagURL = [NSURL URLWithString:[self.node copy]];
    }
    
    if([[currentAd.VASTCreatives lastObject] isKindOfClass:[VASTLinearCreative class]] && [currentAd isKindOfClass:[VASTWrapperAdPod class]] == NO){
    
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
        [self sortAds];
        
        //should check to make sure delegate is a type of VASTParser before calling
        [(VASTParser*)self.delegate wrapperDidFinish:self.ads];
    }
    else{
        [self sortAds];
        [self followWrappers];
    }
}

#pragma mark - VASTParser Delegate
-(void)parserDidFinish:(NSMutableArray*)ads{
    if([NSThread isMainThread] == NO){
        NSLog(@"Not on main thread, dispatching now");
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if([self.delegate respondsToSelector:@selector(parserDidFinish:)]){
                [self.delegate parserDidFinish:ads];
            }
        }];
    }
}

-(void)wrapperDidFinish:(NSMutableArray*)ads{
    int index = (int)[self.ads indexOfObject:self.wrapper];
    [self.ads removeObject:self.wrapper];
    //Set the sequence ID to match the wrapper nodes and insert the nodes starting at the node where the wrapper
    for (VASTAdPod *ad in ads) {
        ad.sequence = [self.wrapper.sequence copy];
        [self.ads insertObject:ad atIndex:index];
        index++;
    }
    self.wrapper = nil;
    [self followWrappers];
}

@end
