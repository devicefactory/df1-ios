/*
DF1CfgController: Configuration Management Controller
    Takes user config parameters and creates a dictionary which can 
    then be saved under NSUserDefaults.
*/
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DF1Lib.h"
#import "DF1CfgCells.h"

#define SECTION_NAMES @"DF1 Config",@"DF1 Features",@"DF1 Firmware",nil
#define SECTION1 @"DF1CfgCellName",@"DF1CfgCellRange",@"DF1CfgCellRes",nil 
// #define SECTION2 @"DF1CfgCellBatt",@"DF1CfgCellProx",nil
#define SECTION2 @"DF1CfgCellBatt",nil
#define SECTION3 @"DF1CfgCellOADTrigger",nil


@interface DF1CfgController : UITableViewController <DF1Delegate,DF1CfgCellOADTriggerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate>

@property (strong,nonatomic) DF1 *df;
@property (strong,nonatomic) NSMutableDictionary *cfg;

-(id) initWithDF:(DF1*) df;
-(void) saveCfg;
// DF1CfgCellOADTriggerDelegate func
-(void) triggerOAD;
@end
