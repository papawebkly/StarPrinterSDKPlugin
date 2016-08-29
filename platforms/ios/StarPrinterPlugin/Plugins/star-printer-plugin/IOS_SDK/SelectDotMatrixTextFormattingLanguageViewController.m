//
//  SelectDotMatrixTextFormattingLanguageViewController.m
//  IOS_SDK
//
//  Created by u3237 on 2014/08/22.
//
//

#import "SelectDotMatrixTextFormattingLanguageViewController.h"

#import "TextFormattingDotMatrixViewController.h"
#import "JpKnjFormattingDotMatrixViewController.h"
#import "SimplifiedTextFormattingDotMatrixViewController.h"
#import "TraditionalChineseFormattingDotMatrixViewController.h"


@implementation SelectDotMatrixTextFormattingLanguageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self moveDBCSControls];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

 - (IBAction)printInEnglish:(id)sender
 {
     UIViewController *vc = [[TextFormattingDotMatrixViewController alloc] initWithNibName:@"TextFormattingDotMatrixViewController"
                                                                                    bundle:NSBundle.mainBundle];
     [self presentViewController:vc animated:YES completion:nil];
     [vc release];
 }

 - (IBAction)printInJapanese:(id)sender
 {
     UIViewController *vc = [[JpKnjFormattingDotMatrixViewController alloc] initWithNibName:@"TextFormattingDotMatrixViewController"
                                                                                     bundle:NSBundle.mainBundle];
     [self presentViewController:vc animated:YES completion:nil];
     [vc release];
 }

 - (IBAction)printInSimplifiedChinese:(id)sender
 {
     UIViewController *vc = [[SimplifiedTextFormattingDotMatrixViewController alloc] initWithNibName:@"TextFormattingDotMatrixViewController"
                                                                                              bundle:NSBundle.mainBundle];
     [self presentViewController:vc animated:YES completion:nil];
     [vc release];
 }

 - (IBAction)printInTraditionalChinese:(id)sender
 {
     UIViewController *vc = [[TraditionalChineseFormattingDotMatrixViewController alloc] initWithNibName:@"TextFormattingDotMatrixViewController"
                                                                                                  bundle:NSBundle.mainBundle];
     [self presentViewController:vc animated:YES completion:nil];
     [vc release];
 }

@end
