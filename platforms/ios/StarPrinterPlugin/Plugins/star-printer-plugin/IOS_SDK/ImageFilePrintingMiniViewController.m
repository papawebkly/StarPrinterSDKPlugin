//
//  ImageFilePrintingMiniViewController.m
//  IOS_SDK
//
//  Created by u3237 on 2014/08/25.
//
//

#import "ImageFilePrintingMiniViewController.h"

#import "AppDelegate.h"
#import "MiniPrinterFunctions.h"
#import "StandardHelp.h"

@implementation ImageFilePrintingMiniViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [array_width release];
        array_width = [[NSArray alloc] initWithObjects:@"2 Inch", @"3 Inch", @"4 Inch", nil];
        [array_image release];
        array_image = [[NSArray alloc] initWithObjects:@"image1.png", @"image2.jpg", @"image3.bmp", @"image4.gif", nil];
        blocking = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)initializeControls
{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)showHelp:(id)sender
{
    NSString *title = @"IMAGE FILE PRINTING";
    NSString *helpText = [AppDelegate HTMLCSS];
    NSMutableString *tmpStr = [[NSMutableString alloc]init];
    [tmpStr appendFormat:@"<UnderlineTitle>Define Bit Image</UnderlineTitle><br/><br/>"];
    [tmpStr appendFormat:@"<Code>ASCII:</Code> <CodeDef>ESC X 4 <StandardItalic>x y d1...dk</StandardItalic></CodeDef><br/>"];
    [tmpStr appendFormat:@"<Code>Hex:</Code> <CodeDef>1B 58 34 <StandardItalic>x y d1...dk</StandardItalic></CodeDef><br/><br/>"];
    [tmpStr appendFormat:@"<rightMov>x</rightMov> <rightMov_NOI>Width of the image divided by 8</rightMov_NOI><br/>"];
    [tmpStr appendFormat:@"<rightMov>y</rightMov> <rightMov_NOI>Vertical number of dots to be printed.  This value shouldn't exceed 24.  If you need to print an image taller than 24 then you should use this command multiple times</rightMov_NOI><br/><br/><br/><br/><br/><br/>"];
    [tmpStr appendFormat:@"<rightMov>d1...dk</rightMov> <rightMov_NOI2>The dots that should be printed.  When all vertical dots are printed the head moves horizontally to the next vertical set of dots</rightMov_NOI2><br/><br/><br/><br/><br/><br/>"];
    [tmpStr appendFormat:@"<UnderlineTitle>Print Bit Image</UnderlineTitle><br/><br/>"];
    [tmpStr appendFormat:@"<Code>ASCII:</Code> <CodeDef>ESC X 2 <StandardItalic> y</StandardItalic></CodeDef><br/>"];
    [tmpStr appendFormat:@"<Code>Hex:</Code> <CodeDef>1B 58 32<StandardItalics> y</StandardItalics></CodeDef><br/><br/>"];
    [tmpStr appendFormat:@"<rightMov>y</rightMov> <rightMov_NOI>The value y must be the same value that was used in ESC X 4 command for define a bit image</rightMov_NOI><br/><br/><br/><br/>"];
    [tmpStr appendFormat:@"Note: The command ESC X 2 must be used after each usage of ESC X 4 inorder to print images"];
    
    helpText = [helpText stringByAppendingString:tmpStr];
    [tmpStr release];
    
    StandardHelp *helpVar = [[StandardHelp alloc] initWithNibName:@"StandardHelp" bundle:[NSBundle mainBundle]];
    [self presentViewController:helpVar animated:YES completion:nil];
    [helpVar setHelpTitle:title];
    [helpVar setHelpText:helpText];
    
    [helpVar release];
}

- (IBAction)print:(id)sender
{
    NSString *portName = [AppDelegate getPortName];
    NSString *portSettings = [AppDelegate getPortSettings];
    
    int width = 576;
    
    switch (selectedWidth) {
        default: width = 384; break;
        case 1:  width = 576; break;
        case 2:  width = 832; break;
    }
    
    [MiniPrinterFunctions PrintBitmapWithPortName:portName
                                     portSettings:portSettings
                                      imageSource:self.previewImageView.image
                                     printerWidth:width
                                compressionEnable:self.compressionButton.on
                                   pageModeEnable:self.pageModeButton.on];
}

@end
