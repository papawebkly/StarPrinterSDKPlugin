//
//  SelectDesktopTextFormattingLanguageViewController.m
//  IOS_SDK
//
//  Created by u3237 on 2014/08/21.
//
//

#import "SelectDesktopTextFormattingLanguageViewController.h"
#import "TextFormating.h"
#import "JpKnjFormating.h"
#import "SimplifiedChineseTextFormatting.h"
#import "TraditionalChineseTextFormatting.h"


@implementation SelectDesktopTextFormattingLanguageViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self moveDBCSControls];
}

- (IBAction)printInEnglish:(id)sender
{
    TextFormating *viewController = [[TextFormating alloc] initWithNibName:@"TextFormating" bundle:NSBundle.mainBundle];
    [self presentViewController:viewController animated:YES completion:nil];
    [viewController release];
}

- (IBAction)printInJapanese:(id)sender
{
    JpKnjFormating *viewController = [[JpKnjFormating alloc] initWithNibName:@"JpKnjFormating" bundle:NSBundle.mainBundle];
    [self presentViewController:viewController animated:YES completion:nil];
    [viewController release];
}

- (IBAction)printInSimplifiedChinese:(id)sender
{
    SimplifiedChineseTextFormatting *viewController = [[SimplifiedChineseTextFormatting alloc] initWithNibName:@"TextFormating" bundle:NSBundle.mainBundle];
    [self presentViewController:viewController animated:YES completion:nil];
    [viewController release];
}

- (IBAction)printInTraditionalChinese:(id)sender
{
    TraditionalChineseTextFormatting *viewController = [[TraditionalChineseTextFormatting alloc] initWithNibName:@"TextFormating" bundle:NSBundle.mainBundle];
    [self presentViewController:viewController animated:YES completion:nil];
    [viewController release];
}

@end
