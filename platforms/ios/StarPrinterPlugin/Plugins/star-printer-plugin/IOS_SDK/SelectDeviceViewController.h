//
//  SelectDeviceViewController.h
//  IOS_SDK
//
//  Created by u3237 on 2014/02/05.
//
//

#import <UIKit/UIKit.h>
#import <StarIO/SMPort.h>

@interface SelectDeviceViewController : UIViewController <UINavigationBarDelegate, UITableViewDelegate, UITableViewDataSource>
@property (retain, nonatomic) IBOutlet UITableView *mainTable;

@end
