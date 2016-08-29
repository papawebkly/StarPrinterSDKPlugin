//
//  BarcodeSelector.h
//  IOS_SDK
//
//  Created by satsuki on 12/07/20.
//  Copyright 2012 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BarcodeSelector : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSArray *options;
    
    IBOutlet UITableView *tableviewBarcode;

    IBOutlet UIButton *buttonBack;
}

- (IBAction)pushButtonBack:(id)sender;

@end
