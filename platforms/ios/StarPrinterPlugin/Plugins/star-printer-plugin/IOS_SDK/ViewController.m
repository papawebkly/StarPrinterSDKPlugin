//
//  ViewController.m
//  IOS_SDK
//
//  Created by satsuki on 12/07/13.
//  Copyright 2012 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "ViewControllerEx.h"
#import "IOS_SDKViewControllerPortable.h"
#import "IOS_SDKViewControllerDKAirCash.h"
#import "IOS_SDKViewControllerImpactDotMatrix.h"
#import "SelectEmulationViewController.h"
#import "IOS_SDKViewControllerProxiPRNT.h"

@interface ViewController() {
    CBCentralManager *p_bleManager;
}
@end

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set button style
    [AppDelegate setButtonArrayAsOldStyle:@[button1, button2, button3, showDotPrinterViewButton, proxiPRNTButton]];
    
    // Hide navigation bar
    self.navigationController.navigationBarHidden = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if ([self isProxiPRNTCapableHardware] == NO) {
        proxiPRNTButton.hidden = YES;
    }
}

- (BOOL)isProxiPRNTCapableHardware
{
    switch (p_bleManager.state) {
        case CBCentralManagerStateUnsupported:
            //NSLog(@"Unsupported");
            return NO;
        case CBCentralManagerStatePoweredOff:
            //NSLog(@"Power OFF");
            break;
        case CBCentralManagerStatePoweredOn:
            //NSLog(@"Power ON");
            break;
        case CBCentralManagerStateResetting:
            //NSLog(@"Resetting");
            break;
        case CBCentralManagerStateUnauthorized:
            //NSLog(@"Unauthorized");
            break;
        case CBCentralManagerStateUnknown:
            //NSLog(@"Unknown");
            break;
    }
    
    return YES;
}

- (void)viewDidUnload
{
    [proxiPRNTButton release];
    proxiPRNTButton = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    p_bleManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [p_bleManager release];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)dealloc
{
    [button1 release];
    [button2 release];
    [button3 release];
    [showDotPrinterViewButton release];
    [proxiPRNTButton release];

    [super dealloc];
}

- (IBAction)pushButton1:(id)sender
{
    ViewControllerEx *viewController = [[[ViewControllerEx alloc] initWithNibName:@"ViewControllerEx" bundle:nil] autorelease];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)pushButton2:(id)sender
{
    UIViewController *vc = [[[SelectEmulationViewController alloc] initWithNibName:@"SelectEmulationViewController" bundle:nil] autorelease];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)pushButton3:(id)sender
{
    IOS_SDKViewControllerDKAirCash *viewController = [[[IOS_SDKViewControllerDKAirCash alloc] initWithNibName:@"IOS_SDKViewControllerDKAirCash" bundle:nil] autorelease];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)showImpactDotMatrixPrintersView:(id)sender
{
    IOS_SDKViewControllerImpactDotMatrix *viewController = [[[IOS_SDKViewControllerImpactDotMatrix alloc] initWithNibName:@"IOS_SDKViewControllerImpactDotMatrix" bundle:nil] autorelease];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)showProxiPRNTView:(id)sender
{
    IOS_SDKViewControllerProxiPRNT *viewController = [[[IOS_SDKViewControllerProxiPRNT alloc] initWithNibName:@"IOS_SDKViewControllerProxiPRNT" bundle:nil] autorelease];
    //[self presentViewController:viewController animated:YES completion:nil];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showAbout:(id)sender
{
    NSString *sdkVersion = [NSString stringWithFormat:@"Version Number: %@",[NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    NSString *starIOVersion = [NSString stringWithFormat:@"StarIO Version: %@", SMPort.StarIOVersion];
    
    NSString *message = [NSString stringWithFormat:@"%@\n%@\nCopyright 2016(C) Star Micronics Co., Ltd.", sdkVersion, starIOVersion];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Version Information"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
    [alert show];
    [alert release];
}
@end
