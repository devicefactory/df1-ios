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
#import "DF1CellBatt.h"


@protocol DF1DevDetailDelegate <NSObject>
@required
-(void) willTransitionBack:(DF1 *) userdf;
@end

@interface DF1DevDetailController : UITableViewController <DF1Delegate>

@property (strong,nonatomic) DF1 *df;
@property (strong,nonatomic) UIViewController *previousVC;

@property (strong,nonatomic) DF1CellAccXyz *accXyzCell;
@property (strong,nonatomic) DF1CellAccTap *accTapCell;
@property (strong,nonatomic) DF1CellBatt   *battCell;
// @property (strong,nonatomic) DF1CellBatt   *rssiCell;
@property (nonatomic) DF1Data *df1data;

-(id)initWithDF:(DF1*) df;

@end
