#import "UIViewController+SemiModal.h"
#import <objc/runtime.h>
#import <sys/utsname.h>

#define kSheetModalViewController @"kSemiModalViewController"
#define kSheetModalView @"kSemiModalView"

@implementation UIViewController (SemiModal)

- (void)presentSheetViewController:(UIViewController *)vc animated:(BOOL)animated
{
	if (! vc)
	{
		return;
	}

	objc_setAssociatedObject(self, kSheetModalViewController, vc, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	UIView *window = [[UIApplication sharedApplication] keyWindow];
	UIView *view = [[UIView alloc] initWithFrame:window.bounds];
	view.backgroundColor = [UIColor clearColor];
	[window addSubview:view];
	
	objc_setAssociatedObject(self, kSheetModalView, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	CGRect sheetFrame  = vc.view.frame;
	sheetFrame.origin.y = window.bounds.size.height;
	vc.view.frame = sheetFrame;
	
	[window addSubview:vc.view];
	
	[vc viewWillAppear:animated];
	
	view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
	
	if (animated)
	{
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(sheetAnimationDidStop:)];
	}
	
	CGRect frame = vc.view.frame;
	frame.origin.y = window.bounds.size.height - frame.size.height;
	vc.view.frame = frame;
	
	if (animated)
	{
		[UIView commitAnimations];
	}
	else
	{
		[self sheetAnimationDidStop:nil];
	}
}

- (void)sheetAnimationDidStop:(id)context
{
	UIViewController *vc = objc_getAssociatedObject(self, kSheetModalViewController);
	if (vc != nil) {
		[vc viewDidAppear:NO];
	}
}

#pragma mark -

- (void)dismissSheetView
{
	UIViewController *vc = objc_getAssociatedObject(self, kSheetModalViewController);
	[self dismissSheetViewController:vc animated:YES];
	
}
- (void)dismissSheetViewController:(UIViewController *)vc animated:(BOOL)animated
{
	[vc viewWillDisappear:animated];
	
	if (animated)
	{
		[UIView animateWithDuration:0.3
						 animations:^(void) {
							 UIView *sheetView = objc_getAssociatedObject(self, kSheetModalView);
							 sheetView.backgroundColor = [UIColor clearColor];
							 CGRect frame = vc.view.frame;
							 frame.origin.y = self.view.bounds.size.height;
							 vc.view.frame = frame;
						 }
		completion:^(BOOL finished)
		 {
			 if (finished)
			 {
				 [self dismissSheetViewControllerDidEndAnimated:animated];
			 }
		 }];
	}
	else
	{
		[self dismissSheetViewControllerDidEndAnimated:animated];
	}
}

- (void)dismissSheetViewControllerDidEndAnimated:(BOOL)animated
{
	UIViewController *vc = objc_getAssociatedObject(self, kSheetModalViewController);
	[vc viewDidDisappear:animated];
	
	UIView *sheetView = objc_getAssociatedObject(self, kSheetModalView);
	[sheetView removeFromSuperview];
	objc_setAssociatedObject(self, kSheetModalView, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	[vc.view removeFromSuperview];
	objc_setAssociatedObject(self, kSheetModalViewController, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
