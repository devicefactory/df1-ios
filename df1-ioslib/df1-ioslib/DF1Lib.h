//
//  df1_ioslib.h
//  df1-ioslib
//
//  Created by JB Kim on 3/23/14.
//  Copyright (c) 2014 JB Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DF1LibDefs.h"
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
@property (strong,nonatomic) NSMutableDictionary *devices;
@property (strong,nonatomic) NSMutableArray *deviceList; // possible external dep
// @property (strong,nonatomic) NSMutableDictionary *registers;
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
-(void) stopScan:(bool) clear;
-(void) connect:(CBPeripheral*) peripheral;
-(void) connect:(CBPeripheral*) peripheral withServices:(NSArray*) services;
-(void) disconnect:(CBPeripheral*) peripheral;
-(void) askRSSI:(CBPeripheral*) peripheral;
-(bool) isConnected:(CBPeripheral*) peripheral;
-(NSDictionary*) getParams;

-(void) syncParameters;
-(void) subscription:(UInt16) suuid withCUUID:(UInt16) cuuid onOff:(BOOL)enable;
-(void) subscribeBatt;
-(void) subscribeXYZ8;
-(void) subscribeXYZ14;
-(void) subscribeTap;
-(void) subscribeFreefall;
-(void) subscribeMotion;
-(void) subscribeShake;

-(void) unsubscribeBatt;
-(void) unsubscribeXYZ8;
-(void) unsubscribeXYZ14;
-(void) unsubscribeTap;
-(void) unsubscribeFreefall;

-(void) modifyRange:(UInt8) value;

-(void) modifyTapThsz:(float) g; // 0.064g increment
-(void) modifyTapThsx:(float) g;
-(void) modifyTapThsy:(float) g;
-(void) modifyTapTmlt:(float) msec; // multiples of 10msec
-(void) modifyTapLtcy:(float) msec;
-(void) modifyTapWind:(float) msec;

-(void) modifyFreefallThs:(float) g; // 0.064g increment
-(void) modifyFreefallDeb:(float) msec; // 10msec increment

-(void) modifyMotionThs:(float) g; // 0.064g increment
-(void) modifyMotionDeb:(float) msec; // 10msec increment

-(void) modifyShakeThs:(float) g;
-(void) modifyShakeDeb:(float) msec;
-(void) modifyShakeHpf:(float) hz; // 0.063==1, 0.125=2, 0.25=4, 0.5=8, 1=16, 2=32, 4=64

-(void) modifyXyzFreq:(int) hz;
@end


//-----------------------------------------------------------------------------
// DELEGATE INTERFACE
//-----------------------------------------------------------------------------
@protocol DF1Delegate <NSObject>

@required

-(bool) didScan:(NSArray*) devices;
-(void) didStopScan;
-(void) didConnect:(CBPeripheral*) peripheral; // at this point, services and characteristics discovered

@optional

-(void) didSyncParameters:(NSDictionary*) params;
-(void) hasCentralErrors:(CBCentralManager*) central;
-(void) didUpdateRSSI:(CBPeripheral*) peripheral withRSSI:(float) rssi;
-(void) receivedBatt:(float) level;
// passes NSArray containing NSNumber objects.
-(void) receivedXYZ8:(NSArray*) data;
-(void) receivedXYZ14:(NSArray*) data;
-(void) receivedTap:(NSDictionary*) data;
-(void) receivedFall:(NSDictionary*) data;
// pass through
-(void) receivedValue:(CBPeripheral*) peripheral forCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

@end
