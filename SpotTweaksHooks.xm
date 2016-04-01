#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <substrate.h>
#import <iMoMacros.h>
#import "SPTWindow.h"

@interface UIApplication (Private)
- (void)applicationOpenURL:(NSURL *)url;
- (void)applicationOpenURL:(NSURL *)url publicURLsOnly:(BOOL)publicURLsOnly;
@end

@interface SpringBoard
- (void)installTweakWithID:(NSString *)id;
- (void)unInstallTweakWithID:(NSString *)id;
@end

static void launchCydiaFromTweakID(NSString *pkgID) {
  UIApplication *app = [UIApplication sharedApplication];
  if ([app respondsToSelector:@selector(applicationOpenURL:publicURLsOnly:)]) {
    [app applicationOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"cydia://package/%@", pkgID]] publicURLsOnly:NO];
  } else {
    [app applicationOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"cydia://package/%@", pkgID]]];
  }
}

// static BOOL isTweakInstalled(NSString *tweakID) {
//     return [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/var/lib/dpkg/info/%@.list", tweakID]];
// }

%hook SpringBoard
- (void)applicationOpenURL:(NSURL *)url withApplication:(id)arg2 sender:(id)arg3 publicURLsOnly:(_Bool)arg4 animating:(_Bool)arg5 needsPermission:(_Bool)arg6 activationSettings:(id)arg7 withResult:(id)arg8 {
	// NSArray *stringArray = [url.absoluteString componentsSeparatedByString:@"id/"]; was for testing
	NSLog(@"******* %@", url.host);
	if ([url.host isEqualToString:@"planet-iphones.com"]) {
		NSString *packageID = [url.absoluteString lastPathComponent];
    launchCydiaFromTweakID(packageID);
    /******** PRIVATE USE ONLY **********/
		// NSMutableArray *btnsArray = [[NSMutableArray alloc] init];
		// if (isTweakInstalled(packageID)) {

		// 	// [btnsArray addObject:@"Remove"];
		// 	// [UIAlertView showWithTitle:@"SpotTweaks"
  //  //                 message:[NSString stringWithFormat:@"Would you like uninstall this tweak ?"]
  //  //       		cancelButtonTitle:@"Cancel"
  //  //       		otherButtonTitles:btnsArray
  //  //                tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
  //  //                    if (buttonIndex == [alertView cancelButtonIndex]) {
  //  //                        NSLog(@"Cancelled");
  //  //                    } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Remove"]) {
  //  //                        [self unInstallTweakWithID:packageID];
  //  //                    }
  //  //                }];
		// } else {
		// 	// [btnsArray addObject:@"Install"];

		// 	// [UIAlertView showWithTitle:@"SpotTweaks"
  //  //                 message:[NSString stringWithFormat:@"Would you like install this tweak ?"]
  //  //       		cancelButtonTitle:@"Cancel"
  //  //       		otherButtonTitles:btnsArray
  //  //                tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
  //  //                    if (buttonIndex == [alertView cancelButtonIndex]) {
  //  //                        NSLog(@"Cancelled");
  //  //                    } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Install"]) {
  //  //                        [self installTweakWithID:packageID];
  //  //                    }
  //  //                }];

		// }
	} else {
		%orig;
	}
}
%new
- (void)installTweakWithID:(NSString *)id {
	[[SPTWindow sharedWindow] showWindowForInstallWithPackageID:id];
}
%new
- (void)unInstallTweakWithID:(NSString *)id {
	[[SPTWindow sharedWindow] showWindowForUnInstallWithPackageID:id];
}
%end
