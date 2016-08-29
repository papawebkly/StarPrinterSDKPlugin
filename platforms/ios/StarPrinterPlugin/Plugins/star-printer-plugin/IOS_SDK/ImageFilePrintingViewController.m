//
//  ImageFilePrintingViewController.m
//  IOS_SDK
//
//  Created by u3237 on 2014/08/20.
//
//

#import "ImageFilePrintingViewController.h"

#import "AppDelegate.h"
#import "ActionSheetStringPicker.h"
#import "StandardHelp.h"

#import "PrinterFunctions.h"

@interface ImageFilePrintingViewController() {
    SMPrinterType p_printerType;
}
@end

@implementation ImageFilePrintingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSString *portSettings = [AppDelegate getPortSettings];
        p_printerType = [AppDelegate parsePortSettings:portSettings];
        if (p_printerType == SMPrinterTypeDesktopPrinterStarLine) {
            array_width = [[NSArray alloc] initWithObjects:@"3 Inch", @"4 Inch", nil];
        } else {
            array_width = [[NSArray alloc] initWithObjects:@"2 Inch", @"3 Inch", @"4 Inch", nil];
        }
        array_image = [[NSArray alloc] initWithObjects:@"image1.png", @"image2.jpg", @"image3.bmp", @"image4.gif", nil];
        blocking = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    selectedWidth = 0;
    selectedImage = 0;
    
    [buttonWidth setTitle:array_width[selectedWidth] forState:UIControlStateNormal];
    [buttonImage setTitle:array_image[selectedImage] forState:UIControlStateNormal];
    
    [AppDelegate setButtonArrayAsOldStyle:@[buttonBack, buttonWidth, buttonImage, buttonHelp, buttonPrint]];
    
    [self initializeControls];
}

- (void)initializeControls
{
    self.pageModeLabel.hidden = YES;
    self.pageModeButton.hidden = YES;
    self.compressionLabel.text = @"Compression";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [array_width release];
    [array_image release];
    
    [_previewImageView release];
    
    [_selectImageButton release];
    [_paperWidthButton release];
    [_compressionButton release];
    [_pageModeButton release];
    
    [_compressionLabel release];
    [_selectImageLabel release];
    [_paperWidthLabel release];
    [_pageModeLabel release];
    
    [buttonHelp release];
    [buttonBack release];
    [buttonPrint release];
    [buttonWidth release];
    [buttonImage release];
    [super dealloc];
}

- (IBAction)selectImageFile:(id)sender
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
    {
        selectedImage = selectedIndex;
        
        [buttonImage setTitle:selectedValue forState:UIControlStateNormal];
        self.previewImageView.image = [UIImage imageNamed:array_image[selectedIndex]];
    };
    
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker)
    {
    };
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select Image"
                                            rows:array_image
                                initialSelection:selectedImage
                                       doneBlock:done
                                     cancelBlock:cancel
                                          origin:sender];
}

- (IBAction)selectPaperWidth:(id)sender
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
    {
        selectedWidth = selectedIndex;
        
        [buttonWidth setTitle:selectedValue forState:UIControlStateNormal];
    };
    
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker)
    {
    };
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select Width"
                                            rows:array_width
                                initialSelection:selectedWidth
                                       doneBlock:done
                                     cancelBlock:cancel origin:sender];
}

- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showHelp:(id)sender
{
    NSString *title = @"IMAGE FILE PRINTING";
    NSString *helpText = [AppDelegate HTMLCSS];
    
    NSString *portSettings = [AppDelegate getPortSettings];
    SMPrinterType printerType = [AppDelegate parsePortSettings:portSettings];
    
    NSString *tmpStr = nil;
    if (printerType == SMPrinterTypeDesktopPrinterStarLine) {
        tmpStr = @"<UnderlineTitle>Enter Raster Mode</UnderlineTitle><br/><br/>"
        "<Code>ASCII:</Code> <CodeDef>ESC * r A</CodeDef><br/>"
        "<Code>Hex:</Code> <CodeDef>1B 2A 72 41</CodeDef><br/><br/>"
        "<UnderlineTitle>Initialize raster mode</UnderlineTitle><br/>"
        "<Code>ASCII:</Code> <CodeDef>ESC * r R</CodeDef><br/>"
        "<Code>Hex:</Code> <CodeDef>1B 2A 72 52</CodeDef><br/><br/>"
        "<UnderlineTitle>Set Raster EOT mode</UnderlineTitle><br/><br/>"
        "<Code>ASCII:</Code> <CodeDef>ESC * r E <StandardItalic>n</StandardItalic> NUL</CodeDef><br/>"
        "<Code>Hex:</Code> <CodeDef>1B 2A 72 45 <StandardItalic>n</StandardItalic> 00</CodeDef><br/>"
        "<div class=\"div-tableCut\">"
        "<div class=\"div-table-rowCut\">"
        "<div class=\"div-table-colRaster\"><center>n</center></div>"
        "<div class=\"div-table-colRaster\"><center>FormFeed</center></div>"
        "<div class=\"div-table-colRaster\"><center>Cut Feed</center></div>"
        "<div class=\"div-table-colRaster\"><center>Cutter</center></div>"
        "<div class=\"div-table-colRaster\"><center>Presenter</center></div>"
        "</div>"
        "<div class=\"div-table-rowCut\">"
        "<div class=\"div-table-colRaster\"><center>0</center></div>"
        "<div class=\"div-table-colRaster\"><center>Default</center></div>"
        "<div class=\"div-table-colRaster\"><center>Default</center></div>"
        "<div class=\"div-table-colRaster\"><center>Default</center></div>"
        "<div class=\"div-table-colRaster\"><center>Default</center></div>"
        "</div>"
        "<div class=\"div-table-rowCut\">"
        "<div class=\"div-table-colRaster\"><center>1</center></div>"
        "<div class=\"div-table-colRaster\"><center>&#x25CB;</center></div>"
        "<div class=\"div-table-colRaster\"><center>-</center></div>"
        "<div class=\"div-table-colRaster\"><center>-</center></div>"
        "<div class=\"div-table-colRaster\"><center>-</center></div>"
        "</div>"
        "<div class=\"div-table-rowCut\">"
        "<div class=\"div-table-colRaster\"><center>2</center></div>"
        "<div class=\"div-table-colRaster\"><center>&#x25CB;</center></div>"
        "<div class=\"div-table-colRaster\"><center>&#x25CB;</center></div>"
        "<div class=\"div-table-colRaster\"><center>-</center></div>"
        "<div class=\"div-table-colRaster\"><center>-</center></div>"
        "</div>"
        "<div class=\"div-table-rowCut\">"
        "<div class=\"div-table-colRaster\"><center>3</center></div>"
        "<div class=\"div-table-colRaster\"><center>&#x25CB;</center></div>"
        "<div class=\"div-table-colRaster\"><center>TearBar</center></div>"
        "<div class=\"div-table-colRaster\"><center>-</center></div>"
        "<div class=\"div-table-colRaster\"><center>-</center></div>"
        "</div>"
        "<div class=\"div-table-rowCut\">"
        "<div class=\"div-table-colRaster\"><center>8</center></div>"
        "<div class=\"div-table-colRaster\"><center>&#x25CB;</center></div>"
        "<div class=\"div-table-colRaster\"><center>-</center></div>"
        "<div class=\"div-table-colRaster\"><center>Full Cut</center></div>"
        "<div class=\"div-table-colRaster\"><center>-</center></div>"
        "</div>"
        "<div class=\"div-table-rowCut\">"
        "<div class=\"div-table-colRaster\"><center>9</center></div>"
        "<div class=\"div-table-colRaster\"><center>&#x25CB;</center></div>"
        "<div class=\"div-table-colRaster\"><center>&#x25CB;</center></div>"
        "<div class=\"div-table-colRaster\"><center>Full Cut</center></div>"
        "<div class=\"div-table-colRaster\"><center>-</center></div>"
        "</div>"
        "<div class=\"div-table-rowCut\">"
        "<div class=\"div-table-colRaster\"><center>12</center></div>"
        "<div class=\"div-table-colRaster\"><center>&#x25CB;</center></div>"
        "<div class=\"div-table-colRaster\"><center>-</center></div>"
        "<div class=\"div-table-colRaster\"><center>Partial Cut</center></div>"
        "<div class=\"div-table-colRaster\"><center>-</center></div>"
        "</div>"
        "<div class=\"div-table-rowCut\">"
        "<div class=\"div-table-colRaster\"><center>13</center></div>"
        "<div class=\"div-table-colRaster\"><center>&#x25CB;</center></div>"
        "<div class=\"div-table-colRaster\"><center>&#x25CB;</center></div>"
        "<div class=\"div-table-colRaster\"><center>Partial Cut</center></div>"
        "<div class=\"div-table-colRaster\"><center>-</center></div>"
        "</div>"
        "<div class=\"div-table-rowCut\">"
        "<div class=\"div-table-colRaster\"><center>36</center></div>"
        "<div class=\"div-table-colRaster\"><center>&#x25CB;</center></div>"
        "<div class=\"div-table-colRaster\"><center>-</center></div>"
        "<div class=\"div-table-colRaster\"><center>Full Cut</center></div>"
        "<div class=\"div-table-colRaster\"><center>Eject</center></div>"
        "</div>"
        "<div class=\"div-table-rowCut\">"
        "<div class=\"div-table-colRaster\"><center>37</center></div>"
        "<div class=\"div-table-colRaster\"><center>&#x25CB;</center></div>"
        "<div class=\"div-table-colRaster\"><center>&#x25CB;</center></div>"
        "<div class=\"div-table-colRaster\"><center>Full Cut</center></div>"
        "<div class=\"div-table-colRaster\"><center>Eject</center></div>"
        "</div>"
        "</div><br/><br/>"
        "<UnderlineTitle>Set Raster FF mode</UnderlineTitle><br/><br/>"
        "<Code>ASCII:</Code> <CodeDef>ESC * r F <StandardItalic>n</StandardItalic> NUL</CodeDef><br/>"
        "<Code>Hex:</Code> <CodeDef>1B 2A 72 46 <StandardItalic>n</StandardItalic> 00</CodeDef><br/>"
        "<div class=\"div-tableCut\">"
        "<div class=\"div-table-rowCut\">"
        "<div class=\"div-table-colRaster\"><center>n</center></div>"
        "<div class=\"div-table-colRaster\"><center>FormFeed</center></div>"
        "<div class=\"div-table-colRaster\"><center>Cut Feed</center></div>"
        "<div class=\"div-table-colRaster\"><center>Cutter</center></div>"
        "<div class=\"div-table-colRaster\"><center>Presenter</center></div>"
        "</div>"
        "<div class=\"div-table-rowCut\">"
        "<div class=\"div-table-colRaster\"><center>0</center></div>"
        "<div class=\"div-table-colRaster\"><center>Default</center></div>"
        "<div class=\"div-table-colRaster\"><center>Default</center></div>"
        "<div class=\"div-table-colRaster\"><center>Default</center></div>"
        "<div class=\"div-table-colRaster\"><center>Default</center></div>"
        "</div>"
        "<div class=\"div-table-rowCut\">"
        "<div class=\"div-table-colRaster\"><center>1</center></div>"
        "<div class=\"div-table-colRaster\"><center>&#x25CB;</center></div>"
        "<div class=\"div-table-colRaster\"><center>-</center></div>"
        "<div class=\"div-table-colRaster\"><center>-</center></div>"
        "<div class=\"div-table-colRaster\"><center>-</center></div>"
        "</div>"
        "<div class=\"div-table-rowCut\">"
        "<div class=\"div-table-colRaster\"><center>2</center></div>"
        "<div class=\"div-table-colRaster\"><center>&#x25CB;</center></div>"
        "<div class=\"div-table-colRaster\"><center>&#x25CB;</center></div>"
        "<div class=\"div-table-colRaster\"><center>-</center></div>"
        "<div class=\"div-table-colRaster\"><center>-</center></div>"
        "</div>"
        "<div class=\"div-table-rowCut\">"
        "<div class=\"div-table-colRaster\"><center>3</center></div>"
        "<div class=\"div-table-colRaster\"><center>&#x25CB;</center></div>"
        "<div class=\"div-table-colRaster\"><center>TearBar</center></div>"
        "<div class=\"div-table-colRaster\"><center>-</center></div>"
        "<div class=\"div-table-colRaster\"><center>-</center></div>"
        "</div>"
        "<div class=\"div-table-rowCut\">"
        "<div class=\"div-table-colRaster\"><center>8</center></div>"
        "<div class=\"div-table-colRaster\"><center>&#x25CB;</center></div>"
        "<div class=\"div-table-colRaster\"><center>-</center></div>"
        "<div class=\"div-table-colRaster\"><center>Full Cut</center></div>"
        "<div class=\"div-table-colRaster\"><center>-</center></div>"
        "</div>"
        "<div class=\"div-table-rowCut\">"
        "<div class=\"div-table-colRaster\"><center>9</center></div>"
        "<div class=\"div-table-colRaster\"><center>&#x25CB;</center></div>"
        "<div class=\"div-table-colRaster\"><center>&#x25CB;</center></div>"
        "<div class=\"div-table-colRaster\"><center>Full Cut</center></div>"
        "<div class=\"div-table-colRaster\"><center>-</center></div>"
        "</div>"
        "<div class=\"div-table-rowCut\">"
        "<div class=\"div-table-colRaster\"><center>12</center></div>"
        "<div class=\"div-table-colRaster\"><center>&#x25CB;</center></div>"
        "<div class=\"div-table-colRaster\"><center>-</center></div>"
        "<div class=\"div-table-colRaster\"><center>Partial Cut</center></div>"
        "<div class=\"div-table-colRaster\"><center>-</center></div>"
        "</div>"
        "<div class=\"div-table-rowCut\">"
        "<div class=\"div-table-colRaster\"><center>13</center></div>"
        "<div class=\"div-table-colRaster\"><center>&#x25CB;</center></div>"
        "<div class=\"div-table-colRaster\"><center>&#x25CB;</center></div>"
        "<div class=\"div-table-colRaster\"><center>Partial Cut</center></div>"
        "<div class=\"div-table-colRaster\"><center>-</center></div>"
        "</div>"
        "<div class=\"div-table-rowCut\">"
        "<div class=\"div-table-colRaster\"><center>36</center></div>"
        "<div class=\"div-table-colRaster\"><center>&#x25CB;</center></div>"
        "<div class=\"div-table-colRaster\"><center>-</center></div>"
        "<div class=\"div-table-colRaster\"><center>Full Cut</center></div>"
        "<div class=\"div-table-colRaster\"><center>Eject</center></div>"
        "</div>"
        "<div class=\"div-table-rowCut\">"
        "<div class=\"div-table-colRaster\"><center>37</center></div>"
        "<div class=\"div-table-colRaster\"><center>&#x25CB;</center></div>"
        "<div class=\"div-table-colRaster\"><center>&#x25CB;</center></div>"
        "<div class=\"div-table-colRaster\"><center>Full Cut</center></div>"
        "<div class=\"div-table-colRaster\"><center>Eject</center></div>"
        "</div>"
        "</div><br/><br/>"
        "<UnderlineTitle>Set raster page length</UnderlineTitle><br/>"
        "<Code>ASCII:</Code> <CodeDef>ESC * r P <StandardItalic>n</StandardItalic> NUL</CodeDef><br/>"
        "<Code>Hex:</Code> <CodeDef>1B 2A 72 50 <StandardItalic>n</StandardItalic> 00</CodeDef><br/><br/>"
        "<rightMov>0 = Continuous print mode (no page length setting)</rightMov><br/><br/>"
        "<rightMov>1&#60;n = Specify page length</rightMov><br/><br/>"
        "<UnderlineTitle>Set raster print quality</UnderlineTitle><br/>"
        "<Code>ASCII:</Code> <CodeDef>ESC * r Q <StandardItalic>n</StandardItalic> NUL</CodeDef><br/>"
        "<Code>Hex:</Code> <CodeDef>1B 2A 72 51 <StandardItalic>n</StandardItalic> 00</CodeDef><br/><br/>"
        "<rightMov>0 = Specify high speed printing</rightMov><br/>"
        "<rightMov>1 = Normal print quality</rightMov><br/>"
        "<rightMov>2 = High print quality</rightMov><br/><br/>"
        "<UnderlineTitle>Set raster left margin</UnderlineTitle><br/><br/>"
        "<Code>ASCII:</Code> <CodeDef>ESC * r m l <StandardItalic>n</StandardItalic> NUL</CodeDef><br/>"
        "<Code>Hex:</Code> <CodeDef>1B 2A 72 6D 6C <StandardItalic>n</StandardItalic> 00</CodeDef><br/><br/>"
        "<UnderlineTitle>Send raster data (auto line feed)</UnderlineTitle><br/><br/>"
        "<Code>ASCII:</Code> <CodeDef>b <StandardItalic>n1 n2 d1 d2 ... dk</StandardItalic></CodeDef><br/>"
        "<Code>Hex:</Code> <CodeDef>62 <StandardItalic>n1 n2 d1 d2 ... dk</StandardItalic></CodeDef><br/><br/>"
        "<rightMov>n1 = (image width / 8) Mod 256</rightMov><br/>"
        "<rightMov>n2 = image width / 256</rightMov><br/>"
        "<rightMov>k = n1 + n2 * 256</rightMov><br/>"
        "* Each byte send in d1 ... dk represents 8 horizontal bits.  The values n1 and n2 tell the printer how many byte are sent with d1 ... dk."
        "The printer automatically feeds when the last value for d1 ... dk is sent<br/><br/>"
        "<UnderlineTitle>Quit raster mode</UnderlineTitle><br/></br>"
        "<Code>ASCII:</Code> <CodeDef>ESC * r B</CodeDef><br/>"
        "<Code>Hex:</Code> <CodeDef>1B 2A 72 42</CodeDef><br/><br/>"
        "* This command automatically executes a EOT(cut) command before quiting.  Use the set EOT command to change the action of this command.";
    } else if (printerType == SMPrinterTypePortablePrinterStarLine) {
        tmpStr = @"<UnderlineTitle>Print Raster Graphics data</UnderlineTitle><br/><br/>\
        <Code>ASCII:</Code><CodeDef>ESC GS S <StandardItalic>m xL xH yL yH n1 [d11 d12 ... d1k] n2 [d21 d22 ... d2k]</StandardItalic></CodeDef><br/>\
        <Code>Hex:</Code><CodeDef>1B 1D 53 <StandardItalic>m xL xH yL yH n1 [d11 d12 ... d1k] n2 [d21 d22 ... d2k]</StandardItalic></CodeDef><br/><br/>\
        <div style=\"margin-left:15px; margin-bottom:15px\">\
        <table>\
        <tr><td width=\"50\" valign=\"top\">m</td><td>'m' specifies the number of transfer blocks and the tone.</td></tr>\
        <tr><td valign=\"top\">xL, xH</td><td>(xL + xH * 256) specifies the number of horizontal data bytes. </td></tr>\
        <tr><td valign=\"top\">yL, yH</td><td>(yL + yX x 256) specifies the number of dots in the vertical direction.</td></tr>\
        <tr><td valign=\"top\">k</td><td>(yL + yX x 256) specifies the number of dots in the vertical direction.</td>\
        </tr><tr><td valign=\"top\">d</td><td>(d1, d2, ... dk) specifies the image data to define.</td></tr>\
        </table>\
        </div>\
        <UnderlineTitle>n/8mm line feed</UnderlineTitle><br/>\
        <Code>ASCII:</Code><CodeDef>ESC I <StandardItalic>n</StandardItalic></CodeDef><br/>\
        <Code>Hex:</Code><CodeDef>1B 49 <StandardItalic>n</StandardItalic></CodeDef><br/>\
        <rightMov>1 &le; n &le; 255</rightMov> <br/>\
        <rightMov_NOI>\
        Executes a n/8mm paper feed.<br/>\
        If print data exists in the line buffer, it prints that data.\
        Using this command will intermittently feed paper, therefore, it is normally recommended that this command not be used.\
        </rightMov_NOI><br/><br/><br/><br/><br/><br/><br/>\
        ";
    }
    helpText = [helpText stringByAppendingString:tmpStr];
    
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
    if (p_printerType == SMPrinterTypeDesktopPrinterStarLine) {
        switch (selectedWidth) {
            case 1:
                width = 832;
                break;
            default:
                width = 576;
                break;
        }
    } else {
        switch (selectedWidth) {
            case 0: // 2 Inch
                width = 384;
                break;
            case 1: // 3 Inch
                width = 576;
                break;
            case 2: // 4 Inch
                width = 832;
                break;
        }
    }
    
    
    [PrinterFunctions PrintImageWithPortname:portName
                                portSettings:portSettings
                                imageToPrint:self.previewImageView.image
                                    maxWidth:width compressionEnable:self.compressionButton.on
                              withDrawerKick:NO];
}


@end
