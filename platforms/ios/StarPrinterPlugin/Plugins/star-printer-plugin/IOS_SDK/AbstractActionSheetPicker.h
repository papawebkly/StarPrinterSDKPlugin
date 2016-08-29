#import <Foundation/Foundation.h>

@interface AbstractActionSheetPicker : NSObject <UIPopoverControllerDelegate>

- (id)initWithTarget:(id)origin;

- (void)showSubViewPicker;

- (UIPickerView *)configuredPickerView;

- (void)notifyDoneTarget;
- (void)notifyCancelTarget;

- (UIBarButtonItem *)createToolbarLabelWithTitle :(NSString *)title;
- (UIToolbar       *)createPickerToolbarWithTitle:(NSString *)title;

- (UIBarButtonItem *)createButtonWithType:(UIBarButtonSystemItem)type target:(id)target action:(SEL)buttonAction;

- (void)presentPickerForView:(UIView *)view;

- (void)configureAndPresentSubviewForView:(UIView *)view;
- (void)configureAndPresentPopoverForView    :(UIView *)view;

- (IBAction)actionPickerDone  :(id)sender;
- (IBAction)actionPickerCancel:(id)sender;

- (void)dismissPicker;

@property (nonatomic, copy)   NSString            *title;
@property (nonatomic, retain) UIView              *pickerView;
@property (nonatomic, retain) UIView              *containerView;
@property (nonatomic, retain) UIPopoverController *popOverController;
@property (nonatomic, retain) NSObject            *selfReference;

#pragma mark for iPhone / iPod touch
@property (nonatomic, retain) UIView              *baseView;
@property (nonatomic, retain) UIView              *blockView;

@end
