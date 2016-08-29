//
//  SelectEmulationViewController.m
//  IOS_SDK
//
//  Created by u3237 on 2014/10/28.
//
//

#import "SelectEmulationViewController.h"
#import "AppDelegate.h"
#import "IOS_SDKViewControllerPortable.h"
#import "IOS_SDKViewControllerPortableStarLine.h"
#import "IOS_SDKViewControllerPortableStarRaster.h"

@interface SelectEmulationViewController ()

@property (retain, nonatomic) IBOutlet UIButton *lineModeButton;
@property (retain, nonatomic) IBOutlet UIButton *rasterModeButton;
@property (retain, nonatomic) IBOutlet UIButton *escposModeButton;
@property (retain, nonatomic) IBOutlet UIButton *backButton;

@end

@implementation SelectEmulationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [AppDelegate setButtonArrayAsOldStyle:@[_lineModeButton, _rasterModeButton, _escposModeButton, _backButton]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showStarLineView:(id)sender {
    IOS_SDKViewControllerPortableStarLine *vc = [[[IOS_SDKViewControllerPortableStarLine alloc] initWithNibName:@"IOS_SDKViewControllerPortable" bundle:nil] autorelease];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)showStarRasterView:(id)sender {
    IOS_SDKViewControllerPortableStarRaster *vc = [[[IOS_SDKViewControllerPortableStarRaster alloc] initWithNibName:@"IOS_SDKViewControllerPortable" bundle:nil] autorelease];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)showESCPOSView:(id)sender {
    IOS_SDKViewControllerPortable *vc = [[[IOS_SDKViewControllerPortable alloc] initWithNibName:@"IOS_SDKViewControllerPortable" bundle:nil] autorelease];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)dealloc {
    [_lineModeButton release];
    [_rasterModeButton release];
    [_escposModeButton release];
    [_backButton release];
    [super dealloc];
}

@end
