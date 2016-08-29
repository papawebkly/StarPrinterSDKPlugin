//
//  CheckConnectionViewController.h
//  IOS_SDK
//
//  Created by u3237 on 12/10/25.
//
//

#import <UIKit/UIKit.h>
#import <StarIO/SMPort.h>

@interface CheckConnectionViewController : UIViewController <UIAlertViewDelegate> {
    SMPort *starPort;
    dispatch_queue_t queue;
    BOOL enableCheckLoop;
    IBOutlet UILabel *portNameInfo;
    IBOutlet UILabel *statusInfo;
    IBOutlet UILabel *message;
    IBOutlet UIButton *connectButton;
    IBOutlet UIButton *sampleReceiptButton;
    IBOutlet UIButton *getStatusButton;
    IBOutlet UIButton *backButton;
}
- (IBAction)pushButtonSampleReceipt:(id)sender;
- (IBAction)pushButtonGetStatus:(id)sender;
- (IBAction)pushButtonConnect:(id)sender;
- (IBAction)pushButtonBack:(id)sender;
@end
