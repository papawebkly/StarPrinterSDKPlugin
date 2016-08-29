//
//  ThresholdSettingViewController.h
//  IOS_SDK
//
//  Created by u3237 on 2014/02/05.
//
//

#import <UIKit/UIKit.h>
#import <StarIO/SMProxiPRNTManager.h>

@interface ThresholdSettingViewController : UIViewController <UIActionSheetDelegate, UIAlertViewDelegate, UITextFieldDelegate, SMProxiPRNTManagerDelegate> {

    IBOutlet UILabel *portNameLabel;
    IBOutlet UITextField *portNameField;
    IBOutlet UILabel *portSettingsLabel;
    IBOutlet UIButton *portSettingsButton;
    IBOutlet UILabel *nickNameLabel;
    IBOutlet UITextField *nickNameField;
    IBOutlet UILabel *deviceTypeLabel;
    IBOutlet UIButton *deviceTypeButton;
    IBOutlet UILabel *LANTypeLabel;
    IBOutlet UIButton *LANTypeButton;
    
    IBOutlet UILabel *currentRSSITitleLabel;
    IBOutlet UIProgressView *currentRSSIProgressView;
    IBOutlet UILabel *currentRSSILabel;
    IBOutlet UILabel *thresholdTitleLabel;
    IBOutlet UISlider *thresholdSlider;
    IBOutlet UILabel *thresholdLabel;
    
    IBOutlet UILabel *useCashDrawerSwitchLabel;
    IBOutlet UISwitch *useCashDrawerSwitch;
    
    int selectedLANType;
    
}

- (IBAction)updatedThreshold:(id)sender;
- (IBAction)selectPortNumber:(id)sender;
- (IBAction)selectDeviceType:(id)sender;
- (IBAction)selectLANType:(id)sender;
- (IBAction)setThresholdAutomatically:(id)sender;

@end
