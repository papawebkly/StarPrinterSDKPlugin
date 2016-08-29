//
//  SelectLanguageViewController.h
//  IOS_SDK
//
//  Created by u3237 on 2014/08/20.
//
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface SelectLanguageViewController : UIViewController <UIScrollViewDelegate> {
    SMLanguage p_selectedLanguage;
    SMPaperWidth p_selectedWidthInch;
    NSString *p_portName;
    NSString *p_portSettings;
    
    UIView *p_blockView;
}

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutletCollection(UIButton) NSArray *printButtons;

@property (retain, nonatomic) IBOutlet UILabel *SBCSLabel;
@property (retain, nonatomic) IBOutlet UIButton *englishButton;
@property (retain, nonatomic) IBOutlet UIButton *frenchButton;
@property (retain, nonatomic) IBOutlet UIButton *portugueseButton;
@property (retain, nonatomic) IBOutlet UIButton *spanishButton;
@property (retain, nonatomic) IBOutlet UIButton *russianButton;
@property (retain, nonatomic) IBOutlet UIButton *japaneseButton;
@property (retain, nonatomic) IBOutlet UIButton *simplifiedChineseButton;
@property (retain, nonatomic) IBOutlet UIButton *traditionalChineseButton;
@property (retain, nonatomic) IBOutlet UILabel *DBCSLabel;
@property (retain, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (retain, nonatomic) IBOutlet UIButton *cloudServiceButton;
@property (retain, nonatomic) IBOutlet UIButton *backButton;


- (IBAction)printInEnglish:(id)sender;
- (IBAction)printInFrench:(id)sender;
- (IBAction)printInPortuguese:(id)sender;
- (IBAction)printInSpanish:(id)sender;
- (IBAction)printInRussian:(id)sender;
- (IBAction)printInJapanese:(id)sender;
- (IBAction)printInSimplifiedChinese:(id)sender;
- (IBAction)printInTraditionalChinese:(id)sender;
- (IBAction)showLoginDialog:(id)sender;

- (void)moveDBCSControls;
- (void)blockView;
- (void)unblockView;
- (void)hideDBCSDescription;

- (IBAction)back:(id)sender;

@end
