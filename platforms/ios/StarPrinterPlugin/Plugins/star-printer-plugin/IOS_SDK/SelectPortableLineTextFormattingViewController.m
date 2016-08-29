//
//  SelectPortableLineTextFormattingViewController.m
//  IOS_SDK
//
//  Created by u3237 on 2014/10/30.
//
//

#import "SelectPortableLineTextFormattingViewController.h"

#import "TextFormating.h"
#import "JpKnjFormating.h"
#import "SimplifiedChineseTextFormatting.h"
#import "TraditionalChineseTextFormatting.h"


@implementation SelectPortableLineTextFormattingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.simplifiedChineseButton.hidden = YES;
    self.traditionalChineseButton.hidden = YES;
    
    self.descriptionLabel.text = @"These samples will require the correct DBCS character set to be loaded.";
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

@end
