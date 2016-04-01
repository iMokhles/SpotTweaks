#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <substrate.h>
#import <iMoMacros.h>
#import "UIAlertView+Blocks.h"

@interface SPTWindow : UIWindow
+(SPTWindow *)sharedWindow;
- (void)showWindowForInstallWithPackageID:(NSString *)packageID;
- (void)showWindowForUnInstallWithPackageID:(NSString *)packageID;
- (void)hideWindow;
@end
