#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DF1Lib.h"
#import "DF1CfgCells.h"
#import "BLEDevice.h"
#import "BLETIOADProfile.h"
#import "BLETIOADProgressViewController.h"

@interface DF1OADController : UIViewController <DF1Delegate,UINavigationControllerDelegate>

@property (strong,nonatomic) NSString *uuid;
@property (strong,nonatomic) DF1 *df;
@property (strong,nonatomic) BLEDevice *dev;
@property (strong,nonatomic) BLETIOADProfile *oadProfile;
//In case of iOS 7.0
@property (strong,nonatomic) BLETIOADProgressViewController *progressView;

@property (nonatomic,retain) UILabel *oadLabel;
@property (nonatomic,retain) UIButton *connButton;
@property (nonatomic,retain) UIButton *oadButton;

- (IBAction) oadButtonSelected:(id)sender;
-(id) initWithPeripheralUUID:(NSString*) uuid;
-(id) initWithDF:(DF1*) df;
@end
