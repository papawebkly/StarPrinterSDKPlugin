//
//  AllReceiptsViewController.h
//  IOS_SDK
//
//  Created by u3237 on 2016/02/22.
//
//

#import <UIKit/UIKit.h>
#import "SelectLanguageViewController.h"
#import <StarIO_Extension/StarIoExt.h>

@interface AllReceiptsViewController : SelectLanguageViewController <UIAlertViewDelegate>

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
                      emulation:(StarIoExtEmulation)emulation
                    printerType:(SMPrinterType)printerType;

@end
