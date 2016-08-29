//
//  ViewControllerEx.h
//  IOS_SDK
//
//  Created by satsuki on 12/07/13.
//  Copyright 2012 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewControllerEx : UIViewController {
    IBOutlet UIButton *button1;
    IBOutlet UIButton *button2;
    IBOutlet UIButton *buttonBack;
}

- (IBAction)pushButton1:(id)sender;
- (IBAction)pushButton2:(id)sender;
- (IBAction)pushButtonBack:(id)sender;
@end
