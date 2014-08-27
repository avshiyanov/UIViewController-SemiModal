#import <UIKit/UIKit.h>

@interface UIViewController (SemiModal)

- (void)presentSheetViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)dismissSheetView;

@end
