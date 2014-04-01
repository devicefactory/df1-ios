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


@interface DF1 : NSObject <CBCentralManagerDelegate,CBPeripheralDelegate>

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

-(void) subscribe:(CBPeripheral*) peripheral UUID:(UInt16) uuid;
-(void) subscribeXYZ8:(CBPeripheral*) peripheral;
-(void) subscribeXYZ14:(CBPeripheral*) peripheral;
-(void) subscribeTap:(CBPeripheral*) peripheral;
-(void) subscribeFreefall:(CBPeripheral*) peripheral;
-(void) subscribeMotion:(CBPeripheral*) peripheral;
-(void) subscribeShake:(CBPeripheral*) peripheral;

-(void) modifyRange:(CBPeripheral*) peripheral withRange:(UInt8) value;

-(void) modifyTap:(CBPeripheral*) peripheral UUID:(UInt16) uuid withValue:(UInt8) value;
-(void) modifyTapThsz:(CBPeripheral*) withG:(double) g; // 0.064g increment
-(void) modifyTapThsx:(CBPeripheral*) withG:(double) g;
-(void) modifyTapThsy:(CBPeripheral*) withG:(double) g;
-(void) modifyTapTmlt:(CBPeripheral*) withMsec:(double) msec; // multiples of 10msec
-(void) modifyTapLtcy:(CBPeripheral*) withMsec:(double) msec;
-(void) modifyTapWind:(CBPeripheral*) withMsec:(double) msec;

-(void) modifyFreefall:(CBPeripheral*) peripheral UUID:(UInt16) uuid withValue:(UInt8) value;
-(void) modifyFreefallThs:(CBPeripheral*) withG:(double) g; // 0.064g increment
-(void) modifyFreefallDeb:(CBPeripheral*) withMsec:(double) msec; // 10msec increment

-(void) modifyMotion:(CBPeripheral*) peripheral UUID:(UInt16) uuid withValue:(UInt8) value;
-(void) modifyMotionThs:(CBPeripheral*) withG:(double) g; // 0.064g increment
-(void) modifyMotionDeb:(CBPeripheral*) withMsec:(double) msec; // 10msec increment

-(void) modifyShake:(CBPeripheral*) peripheral UUID:(UInt16) uuid withValue:(UInt8) value;
-(void) modifyShakeThs:(CBPeripheral*) peripheral withG:(double) g;
-(void) modifyShakeDeb:(CBPeripheral*) peripheral withMsec:(double) msec;
-(void) modifyShakeHpf:(CBPeripheral*) peripheral withHz:(double) hz; // 0.063==1, 0.125=2, 0.25=4, 0.5=8, 1=16, 2=32, 4=64

@end


//-----------------------------------------------------------------------------
// DELEGATE INTERFACE
//-----------------------------------------------------------------------------
@protocol DF1Delegate <NSObject>

@required

-(bool) didScan:(NSArray*) devices;
-(bool) didConnectPeripheral:(CBPeripheral*) peripheral;
-(bool) receivedXYZ8:(double*) data;
-(bool) receivedXYZ14:(double*) data;

@optional

-(void) hasCentralErrors:(CBCentralManager*) central;

@end
