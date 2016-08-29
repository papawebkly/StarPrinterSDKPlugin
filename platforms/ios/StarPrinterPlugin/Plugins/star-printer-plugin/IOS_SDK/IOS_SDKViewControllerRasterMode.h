//
//  IOS_SDKViewControllerRasterMode.h
//  IOS_SDK
//
//  Created by Tzvi on 8/2/11.
//  Copyright 2011 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ReturnSelectedCellText.h"
#import "SearchPrinterViewController.h"

@class CommonTableView;

@interface IOS_SDKViewControllerRasterMode : UIViewController <UIAlertViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, ReturnSelectedCellTextDelegate> {
    NSArray *arrayFunction;
    
    IBOutlet UIView *uiview_block;

    IBOutlet UITextField *uitextfield_portname;
    IBOutlet UITableView *tableviewFunction;
    IBOutlet UIButton *buttonBack;
    IBOutlet UIButton *buttonHelp;

    SearchPrinterViewController *searchView;
    CommonTableView *commonTableView;
    NSInteger selectIndex;

    IBOutlet UIButton *buttonSearch;
    IBOutlet UIButton *buttonPort;
    IBOutlet UIButton *buttonSensorActive;

    NSInteger selectedPort;
    NSInteger selectedSensorActive;

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
