//
//  DF1DevDetailController.h
//  df1-iosdemo
//
//  Created by JB Kim on 4/27/14.
//  Copyright (c) 2013 JB Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DF1Lib.h"
#import "DF1Data.h"
#import "DF1CellAccXyz.h"
#import "DF1CellAccTap.h"
#import "DF1CellFlip.h"
#import "DF1CellDataShare.h"
#import "DF1CellBatt.h"
#import "DF1CellAccMagnitude.h"
#import "DF1CellDistance.h"
#import "DF1CellFreefall.h"

/*
@protocol DF1DevDetailDelegate <NSObject>
@required
-(void) willTransitionBack:(DF1 *) userdf;
@end
 */

@interface DF1DevDetailController : UITableViewController <DF1Delegate,UINavigationControllerDelegate>

@property (strong,nonatomic) DF1 *df;
@property (strong,nonatomic) UIViewController *previousVC;

@property (strong,nonatomic) DF1CellAccXyz *accXyzCell;
@property (strong,nonatomic) DF1CellAccTap *accTapCell;
@property (strong,nonatomic) DF1CellFlip *flipCell;
@property (strong,nonatomic) DF1CellBatt   *battCell;
@property (strong,nonatomic) DF1CellDataShare *dataCell;
@property (strong,nonatomic) DF1CellAccMagnitude *magCell;
@property (strong,nonatomic) DF1CellDistance *distCell;
@property (strong,nonatomic) DF1CellFreefall *freeCell;

@property (strong,nonatomic) CBPeripheral *peripheral;

@property NSNumber *maxAcceleration;
@property NSNumber *avgAcceleration;
@property NSNumber *avgAccCounter;
@property NSMutableArray *magnitudeArray;
@property NSMutableArray *peaksArray;

@property (nonatomic) DF1Data *df1data;

@property NSTimer *rssiTimer;
@property bool _isScanning;


-(id)initWithDF:(DF1*) df;

@end
