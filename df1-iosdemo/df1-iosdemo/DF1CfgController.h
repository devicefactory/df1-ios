/*
DF1CfgController: Configuration Management Controller
    Takes user config parameters and creates a dictionary which can 
    then be saved under NSUserDefaults.
*/
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DF1Lib.h"
#import "DF1CfgCells.h"


@interface DF1CfgController : UITableViewController <DF1Delegate,UINavigationControllerDelegate>

@property (strong,nonatomic) DF1 *df;
@property (strong,nonatomic) NSMutableDictionary *cfg;

-(id) initWithDF:(DF1*) df;
-(void) saveCfg;

@end
