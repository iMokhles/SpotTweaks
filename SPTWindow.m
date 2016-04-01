#import "SPTWindow.h"
#import "MALoggingViewController.h"
 #import "NSTask.h"

#import "STPrivilegedTask.h"

#define Script_PATH @"/Library/Application Support/SpotTweaks/SpotTweaks.sh"
NSTask *unixTask;
NSPipe *unixStandardOutputPipe;

NSPipe *unixStandardErrorPipe;
NSPipe *unixStandardInputPipe;

NSFileHandle *fhOutput;
NSFileHandle *fhError;

NSData *standardOutputData;
NSData *standardErrorData;

@interface SPTWindow () <MALoggingViewControllerDelegate>
@property (nonatomic, strong) MALoggingViewController *loggingVC;
// @property (nonatomic, strong) NSTask *unixTask;
// @property (nonatomic, strong) NSPipe *unixStandardOutputPipe;
// @property (nonatomic, strong) NSPipe *unixStandardErrorPipe;
// @property (nonatomic, strong) NSPipe *unixStandardInputPipe;
// @property (nonatomic, strong) NSFileHandle *fhOutput;
// @property (nonatomic, strong) NSFileHandle *fhError;
// @property (nonatomic, strong) NSData *standardOutputData;
// @property (nonatomic, strong) NSData *standardErrorData;
@end

@implementation SPTWindow
@synthesize loggingVC;
+(SPTWindow *)sharedWindow {
	static SPTWindow *sptWNDW;

	if (sptWNDW == nil) {
		sptWNDW = [[SPTWindow alloc] initWindow];
	}

	return sptWNDW;
}

- (SPTWindow *)initWindow {
	self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
	loggingVC = [MALoggingViewController new];
	loggingVC.delegate = self;
	[self setWindowLevel:UIWindowLevelStatusBar + 500];
	UINavigationController *navigationController;
	navigationController = [[UINavigationController alloc] initWithRootViewController:loggingVC];
	navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self setRootViewController:navigationController];

	NSString *scriptText = [NSString stringWithFormat:@""];
    [scriptText writeToFile:Script_PATH atomically:YES encoding:NSUTF8StringEncoding error:nil];

	return self;
}

// - (void)getRootAccess {
// 	NSString *scriptPath = Script_PATH;
// 	NSString *password = @"alpine";
// 	NSString *
// 	NSString *scriptText = [[NSString alloc]initWithFormat:@"#! usr/sh/echo\n%@ | sudo -S %@", password, command];

// 	[scriptText writeToFile:scriptPath atomically:YES encoding:NSUTF8StringEncoding error:nil];

//     NSTask * task = [[NSTask alloc]init];
//     [task setLaunchPath:@"/bin/sh"];
//     NSArray * args = [NSArray arrayWithObjects:scriptPath, nil];
//     [task setArguments:args];
//     [task launch];
//     NSString * blank = @" ";
//     [blank writeToFile:scriptPath atomically:YES encoding:NSUTF8StringEncoding error:nil];

// }
- (void)showWindowForInstallWithPackageID:(NSString *)packageID {
	[self setHidden:NO];

	unixStandardOutputPipe = [[NSPipe alloc] init];
    unixStandardErrorPipe =  [[NSPipe alloc] init];

    fhOutput = [unixStandardOutputPipe fileHandleForReading];
    fhError =  [unixStandardErrorPipe fileHandleForReading];

    //setup notification alerts
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    [nc addObserver:self selector:@selector(notifiedForStdOutput:) name:NSFileHandleReadCompletionNotification object:fhOutput];
    [nc addObserver:self selector:@selector(notifiedForStdError:)  name:NSFileHandleReadCompletionNotification object:fhError];
    [nc addObserver:self selector:@selector(notifiedForComplete:)  name:NSTaskDidTerminateNotification object:unixTask];

	// NSMutableArray *commandLine = [NSMutableArray new];
 //    [commandLine addObject:@"-c"];
 //    [commandLine addObject:[NSString stringWithFormat:@"/usr/bin/apt-get install '%@'", packageID]];

    NSString *scriptPath = Script_PATH;
	NSString *password = @"alpine";

    NSString *command = [NSString stringWithFormat:@"/usr/bin/apt-get install %@", packageID];
    NSString *scriptText = [NSString stringWithFormat:@"#! echo %@ | sudo -S %@", password, command];

    [scriptText writeToFile:scriptPath atomically:YES encoding:NSUTF8StringEncoding error:nil];

    unixTask = [[NSTask alloc] init];
    [unixTask setLaunchPath:@"/bin/sh"];
    [unixTask setArguments:[NSArray arrayWithObjects:scriptPath, nil]];
    // [unixTask setLaunchPath:@"/bin/bash"];
    // [unixTask setArguments:commandLine];
    [unixTask setStandardOutput:unixStandardOutputPipe];
    [unixTask setStandardError:unixStandardErrorPipe];
    [unixTask setStandardInput:[NSPipe pipe]];
    [unixTask launch];

    //note we are calling the file handle not the pipe
    [fhOutput readInBackgroundAndNotify];
    [fhError readInBackgroundAndNotify];
}

- (void)showWindowForUnInstallWithPackageID:(NSString *)packageID {
	[self setHidden:NO];

	unixStandardOutputPipe = [[NSPipe alloc] init];
    unixStandardErrorPipe =  [[NSPipe alloc] init];

    fhOutput = [unixStandardOutputPipe fileHandleForReading];
    fhError =  [unixStandardErrorPipe fileHandleForReading];

    //setup notification alerts
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    [nc addObserver:self selector:@selector(notifiedForStdOutput:) name:NSFileHandleReadCompletionNotification object:fhOutput];
    [nc addObserver:self selector:@selector(notifiedForStdError:)  name:NSFileHandleReadCompletionNotification object:fhError];
    [nc addObserver:self selector:@selector(notifiedForComplete:)  name:NSTaskDidTerminateNotification object:unixTask];

	NSMutableArray *commandLine = [NSMutableArray new];
    [commandLine addObject:@"-c"];
    [commandLine addObject:[NSString stringWithFormat:@"/usr/bin/apt-get remove --purge %@", packageID]];

    unixTask = [[NSTask alloc] init];
    [unixTask setLaunchPath:@"/bin/bash"];
    [unixTask setArguments:commandLine];
    [unixTask setStandardOutput:unixStandardOutputPipe];
    [unixTask setStandardError:unixStandardErrorPipe];
    [unixTask setStandardInput:[NSPipe pipe]];
    [unixTask launch];

    //note we are calling the file handle not the pipe
    [fhOutput readInBackgroundAndNotify];
    [fhError readInBackgroundAndNotify];
}

- (void)hideWindow {
	[self setHidden:YES];
}
- (void)didTapDoneButton:(MALoggingViewController *)arSearchViewController {
	[self hideWindow];
}

#pragma mark - GET Log
-(void) notifiedForStdOutput: (NSNotification *)notified
{

    NSData * data = [[notified userInfo] valueForKey:NSFileHandleNotificationDataItem];
    if ([data length]){

        NSString * outputString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];  
        [loggingVC logToView:outputString];
    }

    if (unixTask != nil) {

        [fhOutput readInBackgroundAndNotify];
    }

}
-(void) notifiedForStdError: (NSNotification *)notified
{

    NSData * data = [[notified userInfo] valueForKey:NSFileHandleNotificationDataItem];
    NSLog(@"standard error ready %ld bytes",(unsigned long) data.length);

    if ([data length]) {

        NSString * outputString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];  
        [loggingVC logToView:outputString];
    }

    if (unixTask != nil) {

        [fhError readInBackgroundAndNotify];
    }

}
-(void) notifiedForComplete:(NSNotification *)anotification {

    NSLog(@"task completed or was stopped with exit code %d",[unixTask terminationStatus]);
    unixTask = nil;

    if ([unixTask terminationStatus] == 0) {
        [loggingVC logToView:@"Success"];
    }
    else {
    	[loggingVC logToView:@"Terminated with non-zero exit code"];
    }
}
@end
