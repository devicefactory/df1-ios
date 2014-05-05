#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DF1Lib.h"
#import "DF1DevCell.h"
#import "DF1DevDetailController.h"


@interface DF1DevListController : UITableViewController <DF1Delegate,DF1DevCellDelegate,DF1DevDetailDelegate>

@property (strong,nonatomic) DF1 *df;
// @property (strong,nonatomic) NSMutableArray *nDevices;
@property (strong,nonatomic) NSArray *nDevices;
@property (strong,nonatomic) CBPeripheral *selectedPeripheral;

-(void) flashLED:(CBPeripheral*) p withByte:(NSData*) data;

@end
