#import "AbstractActionSheetPicker.h"

@implementation AbstractActionSheetPicker

@synthesize title             = _title;
@synthesize pickerView        = _pickerView;
@synthesize containerView     = _containerView;
@synthesize popOverController = _popOverController;
@synthesize selfReference     = _selfReference;

- (id)initWithTarget:(id)origin  {
    self = [super init];

    if (self) {
        self.containerView = origin;
        self.selfReference = self;
    }

    return self;
}

- (void)dealloc {
    if ([self.pickerView respondsToSelector:@selector(setDelegate:)])   [self.pickerView performSelector:@selector(setDelegate:)   withObject:nil];
    if ([self.pickerView respondsToSelector:@selector(setDataSource:)]) [self.pickerView performSelector:@selector(setDataSource:) withObject:nil];

    self.pickerView        = nil;
    self.containerView     = nil;
    self.popOverController = nil;
    self.blockView = nil;
    self.baseView = nil;

    [super dealloc];
}

- (void)showSubViewPicker {
    UIView *masterView = [[UIView alloc] init];

    UIToolbar *pickerToolbar = [self createPickerToolbarWithTitle:self.title];

    pickerToolbar.barStyle = UIBarStyleBlackTranslucent;

    [masterView addSubview:pickerToolbar];

    _pickerView = [self configuredPickerView];

    [masterView addSubview:_pickerView];

    masterView.frame = CGRectMake(0, 0, pickerToolbar.frame.size.width, pickerToolbar.frame.size.height + _pickerView.frame.size.height);

    [self presentPickerForView:masterView];

    [masterView release];
}

#pragma mark Abstract methods

- (UIView *)configuredPickerView
{
    return nil;
}

- (void)notifyDoneTarget
{
}

- (void)notifyCancelTarget
{
}


#pragma mark -

- (UIToolbar *)createPickerToolbarWithTitle:(NSString *)title  {
    CGFloat pickerWidth = 0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        pickerWidth = UIScreen.mainScreen.bounds.size.width;
    } else {
        pickerWidth = 320;
    }
    UIToolbar *pickerToolbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, pickerWidth, 40)] autorelease];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    [barItems addObject:[self createButtonWithType:UIBarButtonSystemItemCancel target:self action:@selector(actionPickerCancel:)]];
    [barItems addObject:flexibleSpace];
    [barItems addObject:[self createToolbarLabelWithTitle:title]];
    [barItems addObject:flexibleSpace];
    [barItems addObject:[self createButtonWithType:UIBarButtonSystemItemDone target:self action:@selector(actionPickerDone:)]];

    [pickerToolbar setItems:barItems animated:YES];

    [flexibleSpace release];
    [barItems release];

    return pickerToolbar;
}

- (UIBarButtonItem *)createToolbarLabelWithTitle:(NSString *)title {
    UILabel *toolBarItemlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 185, 40)];     // fixed width and height

    toolBarItemlabel.textAlignment = NSTextAlignmentCenter;
    toolBarItemlabel.font = [UIFont boldSystemFontOfSize:16];
    toolBarItemlabel.text = title;
    toolBarItemlabel.textColor = [UIColor whiteColor];
    toolBarItemlabel.backgroundColor = [UIColor clearColor];

    UIBarButtonItem *buttonLabel = [[[UIBarButtonItem alloc]initWithCustomView:toolBarItemlabel] autorelease];

    [toolBarItemlabel release];

    return buttonLabel;
}

- (UIBarButtonItem *)createButtonWithType:(UIBarButtonSystemItem)type target:(id)target action:(SEL)buttonAction {
    return [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:type target:target action:buttonAction] autorelease];
}

- (void)presentPickerForView:(UIView *)view {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self configureAndPresentSubviewForView:view];
    } else {
        [self configureAndPresentPopoverForView:view];
    }
}

- (void)configureAndPresentSubviewForView:(UIView *)view
{
    UIViewController *topController = UIApplication.sharedApplication.keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    // hide software keyboard
    UITextField *textField = [[UITextField alloc] init];
    [topController.view addSubview:textField];
    [textField becomeFirstResponder];
    [textField resignFirstResponder];
    [textField removeFromSuperview];
    [textField release];

    CGSize mainScreenSize = UIScreen.mainScreen.bounds.size;
    
    UIView *blockView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, mainScreenSize.width, mainScreenSize.height)];
    blockView.backgroundColor = [UIColor grayColor];
    blockView.alpha = 0.7;
    self.blockView = blockView;
    [blockView release];
    
    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0.0, mainScreenSize.height - view.frame.size.height, view.frame.size.width, view.frame.size.height)];
    subView.backgroundColor = UIColor.whiteColor;
    [subView addSubview:view];
    
    self.baseView = subView;
    [subView release];

    [topController.view addSubview:self.blockView];
    [topController.view addSubview:self.baseView];
}

- (void)configureAndPresentPopoverForView:(UIView *)view {
    UIViewController *viewController = [[UIViewController alloc] init];

    viewController.view = view;
    viewController.preferredContentSize = view.frame.size;

    _popOverController = [[UIPopoverController alloc] initWithContentViewController:viewController];
    _popOverController.delegate = self;

    [_popOverController presentPopoverFromRect:_containerView.superview.frame inView:_containerView.superview permittedArrowDirections:0 animated:YES];

    [viewController release];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [self notifyCancelTarget];
    [self dismissPicker];
}

- (IBAction)actionPickerDone:(id)sender {
    [self notifyDoneTarget];
    [self dismissPicker];
}

- (IBAction)actionPickerCancel:(id)sender {
    [self notifyCancelTarget];
    [self dismissPicker];
}

- (void)dismissPicker {
    if (self.baseView) {
        [self.baseView removeFromSuperview];
    }
    
    if (self.blockView) {
        [self.blockView removeFromSuperview];
    }
    
    if (self.popOverController) {
        if (self.popOverController.isPopoverVisible) {
            [_popOverController dismissPopoverAnimated:YES];
        }
    }
    
    self.popOverController = nil;
    self.selfReference     = nil;
}

@end
