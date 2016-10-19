/*
DF1CfgController: Configuration Management Controller
    Takes user config parameters and creates a dictionary which can 
    then be saved under NSUserDefaults.
*/
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <QuartzCore/QuartzCore.h>
#import "DF1Lib.h"
#import "DF1CfgCells.h"
#import "DF1FeaturePickerCell.h"
#import "DF1FeatureTitleCell.h"
#import "DF1NewFeatureCell.h"

#define SECTION_NAMES @"Configuration",@"Features",@"Firmware",nil
#define SECTION1 @"DF1CfgCellName",@"DF1CfgCellRange",@"DF1CfgCellRes",@"DF1CfgCellFreqRange",nil
#define SECTION2 @"DF1CfgXYZPlotter",@"DF1CfgTap",@"DF1CfgFlip",@"DF1CfgCSVDataRecorder",@"DF1CfgBatteryLevel", @"DF1CfgMagnitudeValues",@"DF1CfgTop10",@"DF1CfgDistance",@"DF1CfgFreefall", nil
#define SECTION3 @"DF1CfgCellOADTrigger",nil

@interface DF1CfgController : UIViewController <DF1Delegate,DF1CfgCellOADTriggerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (strong,nonatomic) DF1 *df;
@property (strong,nonatomic) NSMutableDictionary *cfg;
@property (strong,nonatomic) UITableView *useCaseTableView;
@property (strong,nonatomic) UITableView *featuresTableView;
@property BOOL useCaseToggle;

-(id) initWithDF:(DF1*) df;
-(void) saveCfg;
-(void) triggerOAD;
@end
