//
//  ProxiPRNTCell.h
//  IOS_SDK
//
//  Created by u3237 on 2014/02/06.
//
//

#import <UIKit/UIKit.h>
#import <StarIO/SMProxiPRNTManager.h>

static NS_ENUM(NSUInteger, ProxiPRNTCellType) {
    kProxiPRNTCellTypeUnregistered = 0,
    kProxiPRNTCellTypeRegistered
};

@interface ProxiPRNTCell : UITableViewCell

@property (assign, nonatomic, setter=setCellType:) enum ProxiPRNTCellType cellType;

@property (retain, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *peripheralMACAddrLabel;
@property (retain, nonatomic) IBOutlet UILabel *portNameLabel;
@property (retain, nonatomic) IBOutlet UIProgressView *RSSIProgressView;
@property (retain, nonatomic) IBOutlet UIButton *PrintOrOpenDrawerButton;
@property (retain, nonatomic) IBOutlet UILabel *selectDeviceLabel;
@property (retain, nonatomic) IBOutlet UIProgressView *thresholdProgressView;

@property (retain, nonatomic) NSString *portSettings;
@property (assign, nonatomic) SMDeviceType deviceType;

@property (assign, nonatomic) BOOL useDrawer;

- (IBAction)printOrOpenDrawer:(id)sender;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
@end
