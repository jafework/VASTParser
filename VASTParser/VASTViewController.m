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

@end

@implementation VASTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSURL *url = [NSURL URLWithString:@"http://demo.tremorvideo.com/proddev/vast/vast_inline_linear.xml"];
    VASTParser *parser = [[VASTParser alloc] initWithVASTUrl:url];
    parser.delegate = self;
    [parser start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
