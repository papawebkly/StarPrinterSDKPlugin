//
//  QRCode.h
//  IOS_SDK
//
//  Created by Tzvi on 8/9/11.
//  Copyright 2011 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface QRCode : UIViewController <UITextFieldDelegate> {
    IBOutlet UIView *uiview_block;
    
    IBOutlet UIImageView *uiimageview_barcode;

    IBOutlet UITextField *uitextfield_data;
    
    IBOutlet UILabel *uilabel_cellsize;
    IBOutlet UILabel *uilabel_model;

    IBOutlet UIButton *buttonCorrection;
    IBOutlet UIButton *buttonModel;
    IBOutlet UIButton *buttonCell;
    IBOutlet UIButton *buttonBack;
    IBOutlet UIButton *buttonHelp;
    IBOutlet UIButton *buttonPrint;

    NSInteger selectedCorrection;
    NSInteger selectedModel;
    NSInteger selectedCell;

    NSArray *array_correction;
    NSArray *array_model;
    NSArray *array_cell;
}

@property(assign, nonatomic) SMPrinterType printerType;

- (IBAction)selectCorrection:(id)sender;
- (IBAction)selectModel:(id)sender;
- (IBAction)selectCell:(id)sender;

- (IBAction)backQrcode;
- (IBAction)showHelp;
- (IBAction)printQrcode;

@end
