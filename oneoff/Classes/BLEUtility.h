#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define TI_BASE_LONG_UUID @"F0000000-0451-4000-B000-000000000000"

@interface BLEUtility : NSObject

+(void)readCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID;

+(void)setNotificationForCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID enable:(BOOL)enable;
+(void)writeCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID data:(NSData *)data;

+(void)writeCharacteristic:(CBPeripheral *)peripheral sCBUUID:(CBUUID *)sCBUUID cCBUUID:(CBUUID *)cCBUUID data:(NSData *)data;
+(void)readCharacteristic:(CBPeripheral *)peripheral sCBUUID:(CBUUID *)sCBUUID cCBUUID:(CBUUID *)cCBUUID;
+(void)setNotificationForCharacteristic:(CBPeripheral *)peripheral sCBUUID:(CBUUID *)sCBUUID cCBUUID:(CBUUID *)cCBUUID enable:(BOOL)enable;

+(bool) isCharacteristicNotifiable:(CBPeripheral *)peripheral sCBUUID:(CBUUID *)sCBUUID cCBUUID:(CBUUID *) cCBUUID;

/// Function to expand a TI 16-bit UUID to TI 128-bit UUID
+(CBUUID *) expandToTIUUID:(CBUUID *)sourceUUID;
/// Function to convert an CBUUID to NSString
+(NSString *) CBUUIDToString:(CBUUID *)inUUID;

+(const char *) UUIDToString:(CFUUIDRef)UUID;
+(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2;
+(int) compareCBUUIDToInt:(CBUUID *)UUID1 UUID2:(UInt16)UUID2;
+(UInt16)   CBUUIDToInt:(CBUUID *) UUID;
+(CBUUID *) IntToCBUUID:(UInt16)UUID;
+(UInt16) swap:(UInt16)s;

+(BOOL) doesPeripheral: (CBPeripheral*) p haveServiceUUID:(CBUUID*) uuid;
+(BOOL) isUUID: (CBUUID*) uuid thisInt: (UInt16) intuuid;

@end
