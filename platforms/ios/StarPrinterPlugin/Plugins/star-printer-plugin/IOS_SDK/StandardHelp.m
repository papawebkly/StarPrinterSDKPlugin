//
//  StandardHelp.m
//  IOS_SDK
//
//  Created by Tzvi on 8/19/11.
//  Copyright 2011 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import "StandardHelp.h"
#import "AppDelegate.h"

@implementation StandardHelp

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)dealloc
{
    [uilabel_helptitle release];
    [uiwebview_helptext release];
    [buttonClose release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [AppDelegate setButtonArrayAsOldStyle:@[buttonClose]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setHelpTitle:(NSString*)helpTitle
{
    uilabel_helptitle.text = helpTitle;
}

- (void)closeCommand
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setHelpText:(NSString*)helpText
{
    [uiwebview_helptext loadHTMLString:helpText baseURL:nil];
}

- (void)setWebViewScaling:(BOOL)scaling
{
    uiwebview_helptext.scalesPageToFit = scaling;
}

@end
