//
//  EAGLView.h
//  CubeExample
//
//  Created by Brad Larson on 4/20/2010.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "ESRenderer.h"

//  from firmware code
#define ACC_SERV_UUID           0xAA10  // F0000000-0451-4000-B000-00000000-AA10
#define ACC_ENABLE_UUID         0xAA12
#define ACC_XYZ_DATA8_UUID      0xAA13


#define TEST_SERV_UUID                  0xAA60 // F0000000-0451-4000-B000-00000000-AA60
#define TEST_DATA_UUID                  0xAA61
#define TEST_CONF_UUID                  0xAA62

#define BATT_SERVICE_UUID               0x180F  // Battery Service
#define BATT_LEVEL_UUID                 0x2A19  // Battery Level


@interface EAGLView : UIView <CBCentralManagerDelegate,CBPeripheralDelegate>
{
    CGPoint lastMovementPosition;
@private
    id <ESRenderer> renderer;

}

@property (strong,nonatomic) NSMutableArray *nDevices;
@property (strong,nonatomic) CBCentralManager *m;
@property (strong,nonatomic) CBPeripheral *p;

- (void)drawView:(id)sender;

@end
