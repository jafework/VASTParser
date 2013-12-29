//
//  VASTViewController.m
//  VASTParser
//
//  Created by Joseph Afework on 12/28/13.
//  Copyright (c) 2013 Joseph Afework. All rights reserved.
//

#import "VASTViewController.h"
#import "VASTParser.h"

@interface VASTViewController ()<VASTParserDelegate>
@property (nonatomic, strong) VASTParser *parser;
@end

@implementation VASTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSURL *url = [NSURL URLWithString:@"http://demo.tremorvideo.com/proddev/vast/vast_inline_linear.xml"];
    self.parser = [[VASTParser alloc] initWithVASTUrl:url];
    self.parser.delegate = self;
    [self.parser start];
}

-(void)parserDidFinish:(NSMutableArray*)ads{
    NSLog(@"Parser Finished");
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
