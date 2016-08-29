//
//  BluetoothSettingViewController.h
//  IOS_SDK
//
//  Created by u3237 on 2013/10/24.
//
//

#import <UIKit/UIKit.h>

@class SMBluetoothManager;

@interface BluetoothSettingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate> {
    BOOL changePINcode;
    NSArray *functions;
    
    UITapGestureRecognizer *singleTap;
    
    UITextField *deviceNameField;
    UITextField *iOSPortNameField;
    UITextField *pinCodeField;
}
@property (retain, nonatomic) IBOutlet UIButton *applyButton;

@property (retain, nonatomic) SMBluetoothManager *bluetoothManager;
@property (retain, nonatomic) IBOutlet UITableView *mainTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil bluetoothManager:(SMBluetoothManager *)manager;

@end
