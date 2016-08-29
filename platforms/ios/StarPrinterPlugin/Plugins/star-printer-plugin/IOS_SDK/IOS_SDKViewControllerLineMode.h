//
//  IOS_SDKViewControllerLineMode.h
//  IOS_SDK
//
//  Created by Tzvi on 8/2/11.
//  Copyright 2011 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ReturnSelectedCellText.h"
#import "SearchPrinterViewController.h"

@class CommonTableView;

@interface IOS_SDKViewControllerLineMode : UIViewController <UIAlertViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, ReturnSelectedCellTextDelegate> {
    IBOutlet UIView *blockView;
    IBOutlet UITextField *uitextfield_portname;
    IBOutlet UITableView *tableviewFunction;
    IBOutlet UIButton *buttonBack;
    IBOutlet UIButton *buttonHelp;

    SearchPrinterViewController *searchView;
    CommonTableView *commonTableView;
    NSInteger selectIndex;

    IBOutlet UIButton *buttonPort;
    IBOutlet UIButton *buttonSensorActive;
    IBOutlet UIButton *buttonSearch;

    NSInteger selectedPort;
    NSInteger selectedSensorActive;
    
    NSArray *arrayFunction;
    NSArray *array_port;
    NSArray *array_sensorActive;
    NSArray *array_sensorActivePickerContents;
}

- (IBAction)selectPort:(id)sender;
- (IBAction)selectSensorActive:(id)sender;

- (IBAction)showHelp;
- (void)setPortInfo;
- (id)init;

- (IBAction)pushButtonSearch:(id)sender;
- (IBAction)pushButtonBack:(id)sender;

@end
