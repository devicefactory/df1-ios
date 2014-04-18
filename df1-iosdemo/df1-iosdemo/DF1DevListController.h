#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DF1Lib.h"
// #import "SensorTagApplicationViewController.h"

@interface DF1DevListController : UITableViewController <DF1Delegate>

// @property (strong,nonatomic) CBCentralManager *m;
// @property (strong,nonatomic) NSMutableArray *nDevices;
// @property (strong,nonatomic) NSMutableArray *sensorTags;
@property (strong,nonatomic) CBPeripheral *selectedPeripheral;

-(void) flashLED:(CBPeripheral*) p withByte:(NSData*) data;

@end
