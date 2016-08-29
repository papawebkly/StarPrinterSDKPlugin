//
//  SelectLanguageViewController.m
//  IOS_SDK
//
//  Created by u3237 on 2014/08/20.
//
//

#import "SelectLanguageViewController.h"


@implementation SelectLanguageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.view addSubview:self.scrollView];
        self.scrollView.contentSize = self.scrollView.frame.size;
        self.scrollView.scrollEnabled = YES;
        self.scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [_englishButton release];
    [_frenchButton release];
    [_portugueseButton release];
    [_spanishButton release];
    [_russianButton release];
    [_japaneseButton release];
    [_simplifiedChineseButton release];
    [_traditionalChineseButton release];
    
    [_descriptionLabel release];
    [_scrollView release];
    [_SBCSLabel release];
    [_DBCSLabel release];
    [_backButton release];
    [_cloudServiceButton release];
    [_printButtons release];
    [super dealloc];
}

#pragma mark Abstract methods

- (IBAction)printInEnglish:(id)sender
{

}

- (IBAction)printInFrench:(id)sender
{

}

- (IBAction)printInPortuguese:(id)sender
{

}

- (IBAction)printInSpanish:(id)sender
{

}

- (IBAction)printInRussian:(id)sender
{

}

- (IBAction)printInJapanese:(id)sender
{

}

- (IBAction)printInTraditionalChinese:(id)sender
{

}

- (IBAction)printInSimplifiedChinese:(id)sender
{

}

- (IBAction)showLoginDialog:(id)sender
{
    
}

#pragma mark Common methods

- (void)moveDBCSControls {
    const CGFloat OFFSET = -204.0;
    CGAffineTransform affineTransform = CGAffineTransformMakeTranslation(0.0, OFFSET);
    
    self.frenchButton.hidden = YES;
    self.portugueseButton.hidden = YES;
    self.spanishButton.hidden = YES;
    self.russianButton.hidden = YES;
    
    self.DBCSLabel.transform = affineTransform;
    self.japaneseButton.transform = affineTransform;
    self.descriptionLabel.transform = affineTransform;
    self.traditionalChineseButton.transform = affineTransform;
    self.simplifiedChineseButton.transform = affineTransform;
    
    self.backButton.transform = affineTransform;
}

- (void)blockView
{
    if (!p_blockView) {
        p_blockView = [[UIView alloc] initWithFrame:self.view.bounds];
    }
    
    [self.view addSubview:p_blockView];
}

- (void)unblockView
{
    if (!p_blockView) {
        return;
    }
    
    [p_blockView removeFromSuperview];
    [p_blockView release];
    p_blockView = nil;
}

- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)hideDBCSDescription {
    CGFloat offset = self.descriptionLabel.frame.size.height * -1.0;
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0.0, offset);
    
    self.descriptionLabel.hidden = YES;
    self.japaneseButton.transform = transform;
    self.traditionalChineseButton.transform = transform;
    self.simplifiedChineseButton.transform = transform;
    self.backButton.transform = transform;
}

@end
