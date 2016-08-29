//
//  IOS_SDKViewControllerProxiPRNT.h
//  IOS_SDK
//
//  Created by u3237 on 2014/01/31.
//
//

#import <UIKit/UIKit.h>
#import <StarIO/SMProxiPRNTManager.h>

@protocol SMProxiPRNTManagerDelegate;

@interface IOS_SDKViewControllerProxiPRNT : UIViewController <SMProxiPRNTManagerDelegate, UITableViewDelegate, UITableViewDataSource>
@property (retain, nonatomic) IBOutlet UITableView *mainTable;

@end
