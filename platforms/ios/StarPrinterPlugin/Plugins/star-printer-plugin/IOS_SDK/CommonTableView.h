//
//  CommonTableView.h
//  IOS_SDK
//
//  Created by u3237 on 13/06/25.
//
//

#import <UIKit/UIKit.h>

@interface CommonTableView : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    id _target;
    SEL _action;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil devices:(NSArray *)devices delegate:(id)delegate action:(SEL)action;

@property (retain, nonatomic) IBOutlet UITableView *tableView;

@property(retain, nonatomic) NSArray *deviceArray;

@end
