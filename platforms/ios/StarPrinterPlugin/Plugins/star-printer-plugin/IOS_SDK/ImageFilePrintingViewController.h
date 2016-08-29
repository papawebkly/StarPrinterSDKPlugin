//
//  ImageFilePrintingViewController.h
//  IOS_SDK
//
//  Created by u3237 on 2014/08/20.
//
//

#import <UIKit/UIKit.h>

@interface ImageFilePrintingViewController : UIViewController {
    NSInteger selectedWidth;
    NSInteger selectedImage;
    
    NSArray *array_width;
    NSArray *array_image;
    
    BOOL blocking;
    
    IBOutlet UIButton *buttonWidth;
    IBOutlet UIButton *buttonImage;
    IBOutlet UIButton *buttonBack;
    IBOutlet UIButton *buttonHelp;
    IBOutlet UIButton *buttonPrint;
}

@property (retain, nonatomic) IBOutlet UILabel *selectImageLabel;
@property (retain, nonatomic) IBOutlet UILabel *paperWidthLabel;
@property (retain, nonatomic) IBOutlet UILabel *compressionLabel;
@property (retain, nonatomic) IBOutlet UILabel *pageModeLabel;

@property (retain, nonatomic) IBOutlet UIButton *selectImageButton;
@property (retain, nonatomic) IBOutlet UIButton *paperWidthButton;
@property (retain, nonatomic) IBOutlet UISwitch *compressionButton;
@property (retain, nonatomic) IBOutlet UISwitch *pageModeButton;

@property (retain, nonatomic) IBOutlet UIImageView *previewImageView;

- (IBAction)selectImageFile:(id)sender;
- (IBAction)selectPaperWidth:(id)sender;

- (IBAction)back:(id)sender;
- (IBAction)showHelp:(id)sender;
- (IBAction)print:(id)sender;

@end
