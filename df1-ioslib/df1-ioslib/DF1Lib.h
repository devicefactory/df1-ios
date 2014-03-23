//
//  df1_ioslib.h
//  df1-ioslib
//
//  Created by JB Kim on 3/23/14.
//  Copyright (c) 2014 JB Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DF1LibUtil.h"

@protocol DF1Delegate;  // forward declaration


@interface DF1Lib : NSObject <CBCentralManagerDelegate,CBPeripheralDelegate>

// Delegate properties should always be weak references
// See http://stackoverflow.com/a/4796131/263871 for the rationale
// (Tip: If you're not using ARC, use `assign` instead of `weak`)
@property (nonatomic, assign) id<DF1Delegate> delegate;

//-----------------------------------------------------------------------------
// MEMBERS
//-----------------------------------------------------------------------------
@property (strong,nonatomic) NSMutableArray *devices;
@property (strong,nonatomic) CBCentralManager *m;
@property (strong,nonatomic) CBPeripheral *p;
@property (retain) CBPeripheral *ptemp;

//-----------------------------------------------------------------------------
// PUBLIC FUNCTIONS
//-----------------------------------------------------------------------------

-(id) initWithDelegate:(id<DF1Delegate>) delegate;
/*!
 *  @method scan:
 *
 *  @param maxDevices maximum number of peripherals to scan for.
 *
 *  @discussion  Initiates CBCentral scan for peripherals.
 *               Invokes {@link didScan:} delegate function for each
 *               unique peripheral discovered.
 */
-(void) scan:(NSUInteger) maxDevices;
-(void) connect:(CBPeripheral*) peripheral;
-(void) disconnect:(CBPeripheral*) peripheral;

@end


//-----------------------------------------------------------------------------
// DELEGATE INTERFACE
//-----------------------------------------------------------------------------
@protocol DF1Delegate <NSObject>

@required

-(bool) didScan:(NSArray*) devices;
-(bool) didConnectPeripheral:(CBPeripheral*) peripheral;

@optional

-(void) hasCentralErrors:(CBCentralManager*) central;

@end
