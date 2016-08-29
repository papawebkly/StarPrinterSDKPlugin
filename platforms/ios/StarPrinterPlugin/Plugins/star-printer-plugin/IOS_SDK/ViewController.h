//
//  ViewController.h
//  IOS_SDK
//
//  Created by satsuki on 12/07/13.
//  Copyright 2012 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StarIO/SMProxiPRNTManager.h>

@interface ViewController : UIViewController <SMProxiPRNTManagerDelegate, CBCentralManagerDelegate> {
    IBOutlet UIButton *button1;
    IBOutlet UIButton *button2;
    IBOutlet UIButton *button3;
    IBOutlet UIButton *showDotPrinterViewButton;
    IBOutlet UIButton *proxiPRNTButton;
    
    SMProxiPRNTManager *manager;
}

- (IBAction)pushButton1:(id)sender;
- (IBAction)pushButton2:(id)sender;
- (IBAction)pushButton3:(id)sender;
- (IBAction)showImpactDotMatrixPrintersView:(id)sender;
- (IBAction)showProxiPRNTView:(id)sender;
- (IBAction)showAbout:(id)sender;

@end
