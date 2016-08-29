//
//  Cut.h
//  IOS_SDK
//
//  Created by Tzvi on 8/15/11.
//  Copyright 2011 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Cut : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSArray *options;
    
    IBOutlet UIView *uiview_block;
    IBOutlet UITableView *tableviewCut;
    IBOutlet UIButton *buttonBack;
    IBOutlet UIButton *buttonHelp;
}

- (IBAction)backCut;
- (IBAction)showHelp;

@end
