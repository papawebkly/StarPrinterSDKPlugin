//
//  IOS_SDKViewControllerImpactDotMatrix.h
//  IOS_SDK
//
//  Copyright 2011 - 2016 STAR MICRONICS CO., LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ReturnSelectedCellText.h"
#import "SearchPrinterViewController.h"

@class CommonTableView;

@interface IOS_SDKViewControllerImpactDotMatrix : UIViewController <UIAlertViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, ReturnSelectedCellTextDelegate> {
    IBOutlet UIView* blockView;
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
