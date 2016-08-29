//
//  SearchPrinterViewController.h
//  IOS_SDK
//
//  Created by satsuki on 12/08/17.
//
//

#import <UIKit/UIKit.h>
#import "ReturnSelectedCellText.h"

@interface SearchPrinterViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
    
    NSArray *printerArray;
    NSString *lastSelectedPortName;

    IBOutlet UITableView *uitableview_printerList;
}
@property(readonly) NSString *lastSelectedPortName;
@property(retain, nonatomic) NSArray* foundPrinters;
@property(nonatomic, assign) id <ReturnSelectedCellTextDelegate> delegate;
@property(readonly) id target;
@property(readonly) SEL action;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil target:(id)target action:(SEL)action;

@end
