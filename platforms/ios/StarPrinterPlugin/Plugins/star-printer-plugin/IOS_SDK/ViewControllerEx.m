//
//  ViewControllerEx.m
//  IOS_SDK
//
//  Created by satsuki on 12/07/13.
//  Copyright 2012 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewControllerEx.h"
#import "IOS_SDKViewControllerLineMode.h"
#import "IOS_SDKViewControllerRasterMode.h"

@implementation ViewControllerEx

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [AppDelegate setButtonArrayAsOldStyle:@[button1, button2, buttonBack]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [button1 release];
    [button2 release];
    [buttonBack release];
    [super dealloc];
}

- (IBAction)pushButton1:(id)sender {
    IOS_SDKViewControllerLineMode *viewController = [[[IOS_SDKViewControllerLineMode alloc] initWithNibName:@"IOS_SDKViewControllerLineMode" bundle:nil] autorelease];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)pushButton2:(id)sender {
    IOS_SDKViewControllerRasterMode *viewController = [[[IOS_SDKViewControllerRasterMode alloc] initWithNibName:@"IOS_SDKViewControllerRasterMode" bundle:nil] autorelease];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)pushButtonBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
