//
//  StandardHelp.h
//  IOS_SDK
//
//  Created by Tzvi on 8/19/11.
//  Copyright 2011 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface StandardHelp : UIViewController {
    IBOutlet UILabel *uilabel_helptitle;
    IBOutlet UIWebView *uiwebview_helptext;
    IBOutlet UIButton *buttonClose;
}

- (IBAction)closeCommand;
- (void)setHelpTitle:(NSString*)helpTitle;
- (void)setHelpText:(NSString*)helpText;
- (void)setWebViewScaling:(BOOL)scaling;

@end
