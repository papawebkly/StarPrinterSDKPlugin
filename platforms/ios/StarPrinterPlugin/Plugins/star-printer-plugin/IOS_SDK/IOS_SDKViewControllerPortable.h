//
//  IOS_SDKViewControllerPortable.h
//  IOS_SDK
//
//  Created by Tzvi on 8/2/11.
//  Copyright 2011 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MiniPrinterFunctions.h"
#import "SearchPrinterViewController.h"

typedef enum _SMActionType {
    SMActionTypeSearch,
    SMActionTypePrint
} SMActionType;

@interface IOS_SDKViewControllerPortable : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, ReturnSelectedCellTextDelegate> {
    NSArray *arrayFunction;

    MiniPrinterFunctions *miniPrinterFunctions;
    SearchPrinterViewController *searchView;
    
    IBOutlet UIView *uiview_block;
    
    IBOutlet UITextField *uitextfield_portname;
    IBOutlet UITableView *tableviewFunction;
    IBOutlet UIButton *buttonSearch;
    IBOutlet UIButton *buttonBack;
    IBOutlet UIButton *buttonHelp;

    NSInteger selectIndex;
}

- (IBAction)showHelp;
- (void)setPortInfo;
- (id)init;

- (IBAction)pushButtonSearch:(id)sender;
- (IBAction)pushButtonBack:(id)sender;

@end
