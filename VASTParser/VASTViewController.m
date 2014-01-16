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
    self.progressIndicator.hidesWhenStopped = YES;
    [self.progressIndicator startAnimating];
    self.progressLabel.text = @"Parsing Data...";
    
	// Do any additional setup after loading the view, typically from a nib.
    
    NSURL *url = [NSURL URLWithString:@"http://share.onescreen.co/homes/slee/fishy.xml"];
    
    //NSURL *url = [NSURL URLWithString:@"http://demo.tremorvideo.com/proddev/vast/vast_inline_linear.xml"];
    //NSURL *url = [NSURL URLWithString:@"http://share.onescreen.co/homes/jafework/bac/2-0_tests/VAST_3_test_wrapper_multi.xml"];
    self.parser = [[VASTParser alloc] initWithVASTUrl:url];
    self.parser.delegate = self;
    [self.parser start];
}

-(void)parserDidFinish:(NSMutableArray*)ads{
    [self.progressIndicator stopAnimating];
    self.progressLabel.text = [NSString stringWithFormat:@"%lu Ads Parsed", ads.count];
    NSLog(@"Parser Finished");
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
