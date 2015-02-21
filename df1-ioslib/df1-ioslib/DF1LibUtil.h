//
//  DF1LibUtil.h
//  DF1Lib
//
//  Created by JB Kim on 12/16/13.
//  Copyright (c) 2013 JB Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface DF1LibUtil : NSObject

// writeCharacteristic with overloaded args
+(void) writeCharacteristic:(CBPeripheral*)peripheral sCBUUID:(CBUUID *)sUUID   cCBUUID:(CBUUID*)cUUID    data:(NSData*)data;
+(void) writeCharacteristic:(CBPeripheral*)peripheral sStrUUID:(NSString*)sUUID cStrUUID:(NSString*)cUUID data:(NSData*)data;
+(void) writeCharacteristic:(CBPeripheral*)peripheral sUUID:  (UInt16)sUUID     cUUID:  (UInt16)cUUID     data:(NSData*)data;
+(void) writeCharacteristic:(CBPeripheral*)peripheral sUUID:  (UInt16)sUUID     cUUID:  (UInt16)cUUID     withByte:(uint8_t) byte;
+(void) writeNoResponseCharacteristic:(CBPeripheral*)peripheral sCBUUID:(CBUUID *)sCBUUID cCBUUID:(CBUUID *)cCBUUID data:(NSData *)data;
+(void) writeNoResponseCharacteristic:(CBPeripheral *)peripheral sStrUUID:(NSString *)sUUID cStrUUID:(NSString *)cUUID data:(NSData *)data;
+(void) writeNoResponseCharacteristic:(CBPeripheral *)peripheral sUUID:(UInt16)sUUID cUUID:(UInt16)cUUID data:(NSData *)data;
+(void) writeNoResponseCharacteristic:(CBPeripheral *)peripheral sUUID:(UInt16)sUUID cUUID:(UInt16)cUUID withByte:(uint8_t)byte;

// readCharacteristic with overloaded args
+(void) readCharacteristic:(CBPeripheral*)peripheral  sCBUUID:(CBUUID *)sUUID    cCBUUID:(CBUUID *)cUUID;
+(void) readCharacteristic:(CBPeripheral*)peripheral  sStrUUID:(NSString*) sUUID cStrUUID:(NSString *)cUUID;
+(void) readCharacteristic:(CBPeripheral*)peripheral  sUUID:(UInt16) sUUID       cUUID:(UInt16)cUUID;
// setNotificationForCharacteristic with overloaded args
+(void) setNotificationForCharacteristic:(CBPeripheral*)peripheral sCBUUID:(CBUUID*)sUUID    cCBUUID:(CBUUID*)cUUID    enable:(BOOL)enable;
+(void) setNotificationForCharacteristic:(CBPeripheral*)peripheral sStrUUID:(NSString*)sUUID cStrUUID:(NSString*)cUUID enable:(BOOL)enable;
+(void) setNotificationForCharacteristic:(CBPeripheral*)peripheral sUUID:(UInt16)sUUID       cUUID:(UInt16)cUUID       enable:(BOOL)enable;
// isCharacteristicNotifiable with overloaded args
+(bool) isCharacteristicNotifiable:(CBPeripheral*)peripheral sCBUUID:(CBUUID*)sUUID     cCBUUID:(CBUUID*) cUUID;
+(bool) isCharacteristicNotifiable:(CBPeripheral*)peripheral sStrUUID:(NSString*)sUUID  cStrUUID:(NSString*) cUUID;
+(bool) isCharacteristicNotifiable:(CBPeripheral*)peripheral sUUID:(UInt16)sUUID        cUUID:(UInt16) cUUID;

+(BOOL) runningiOSSeven;

/// Function to expand a TI 16-bit UUID to TI 128-bit UUID
+(CBUUID*) expandToTIUUID:(CBUUID *)sourceUUID;
/// Function to convert an CBUUID to NSString
+(NSString*) CBUUIDToString:(CBUUID *)inUUID;
+(const char*) UUIDToString:(CFUUIDRef)UUID;
+(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2;
+(bool) compareCBUUIDToInt:(CBUUID *)UUID1 UUID2:(UInt16)UUID2;
+(UInt16)   CBUUIDToInt:(CBUUID *) UUID;
+(CBUUID*) IntToCBUUID:(UInt16)UUID;
+(UInt16) swap:(UInt16)s;

+(bool) doesPeripheral: (CBPeripheral*) p haveServiceUUID:(CBUUID*) uuid;
+(bool) isUUID: (CBUUID*) uuid thisInt: (UInt16) intuuid;


// Returns NSDictionary object to be used with NSUserDefaults
+(void) clearUserDefaults;
+(NSDictionary*) getUserCfgDict:(CBPeripheral*) p;
+(NSString*) getUserCfgName:(CBPeripheral*) p;
+(NSDictionary*) mergeUserCfgDict:(CBPeripheral*) p withDict:(NSDictionary*) dict;
+(NSDictionary*) saveUserCfgDict:(CBPeripheral*) p withDict:(NSDictionary*) dict;

@end

//  http://stackoverflow.com/questions/1667994/best-practices-for-error-logging-and-or-reporting-for-iphone

// - (void)myMethod:(NSObject *)xiObj
// {
//   DF_ENTRY;
//   DF_DBG(@"Boring low level stuff");
//   DF_NRM(@"Higher level trace for more important info");
//   DF_ALT(@"Really important trace, something bad is happening");
//   DF_ERR(@"Error, this indicates a coding bug or unexpected condition");
//   DF_EXIT;
// }

#ifndef DF_LEVEL
#if TARGET_IPHONE_SIMULATOR != 0
#define DF_LEVEL 0
#else
#define DF_LEVEL 5
#endif
#endif

/*****************************************************************************/
/* Entry/exit trace macros                                                   */
/*****************************************************************************/
#if DF_LEVEL == 0
#define DF_ENTRY    NSLog(@"ENTRY: %s:%d:", __PRETTY_FUNCTION__,__LINE__);
#define DF_EXIT     NSLog(@"EXIT:  %s:%d:", __PRETTY_FUNCTION__,__LINE__);
#else
#define DF_ENTRY
#define DF_EXIT
#endif

/*****************************************************************************/
/* Debug trace macros                                                        */
/*****************************************************************************/
#if (DF_LEVEL <= 1)
#define DF_DBG(A, ...) NSLog(@"DEBUG: %s:%d:%@", \
    __PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:A, ## __VA_ARGS__]);
#else
#define DF_DBG(A, ...)
#endif

#if (DF_LEVEL <= 2)
#define DF_NRM(A, ...) NSLog(@"NORMAL:%s:%d:%@", \
    __PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:A, ## __VA_ARGS__]);
#else
#define DF_NRM(A, ...)
#endif

#if (DF_LEVEL <= 3)
#define DF_ALT(A, ...) NSLog(@"ALERT: %s:%d:%@", \
    __PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:A, ## __VA_ARGS__]);
#else
#define DF_ALT(A, ...)
#endif

#if (DF_LEVEL <= 4)
#define DF_ERR(A, ...) NSLog(@"ERROR: %s:%d:%@", \
    __PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:A, ## __VA_ARGS__]);
#else
#define DF_ERR(A, ...)
#endif
