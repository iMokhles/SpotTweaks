//
//  MALoggingViewController.h
//  MALoggingViewController
//
//  Created by Mike on 8/8/14.
//  Copyright (c) 2014 Mike Amaral. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MALoggingViewController;

@protocol MALoggingViewControllerDelegate <NSObject>
- (void)didTapDoneButton:(MALoggingViewController *)arSearchViewController;
@end

@interface MALoggingViewController : UIViewController {
    UITextView *_textView;
    CGFloat _currentFontSize;
	__unsafe_unretained id <MALoggingViewControllerDelegate> _delegate;
}
@property (nonatomic, assign) id <MALoggingViewControllerDelegate> delegate;
- (void)logToView:(NSString *)format, ...;

@end
