#import "BLEUtility.h"

@implementation BLEUtility

+(void)writeCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID data:(NSData *)data {
    // Sends data to BLE peripheral to process HID and send EHIF command to PC
    for ( CBService *service in peripheral.services ) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:sUUID]]) {
            for ( CBCharacteristic *characteristic in service.characteristics ) {
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cUUID]]) {
                    /* EVERYTHING IS FOUND, WRITE characteristic ! */
                    [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                    
                }
            }
        }
    }
}

+(void)writeCharacteristic:(CBPeripheral *)peripheral sCBUUID:(CBUUID *)sCBUUID cCBUUID:(CBUUID *)cCBUUID data:(NSData *)data {
    // Sends data to BLE peripheral to process HID and send EHIF command to PC
    for ( CBService *service in peripheral.services ) {
        if ([service.UUID isEqual:sCBUUID]) {
            for ( CBCharacteristic *characteristic in service.characteristics ) {
                if ([characteristic.UUID isEqual:cCBUUID]) {
                    /* EVERYTHING IS FOUND, WRITE characteristic ! */
                    [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                    
                }
            }
        }
    }
}


+(void)readCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID {
    for ( CBService *service in peripheral.services ) {
        if([service.UUID isEqual:[CBUUID UUIDWithString:sUUID]]) {
            for ( CBCharacteristic *characteristic in service.characteristics ) {
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cUUID]]) {
                    /* Everything is found, read characteristic ! */
                    [peripheral readValueForCharacteristic:characteristic];
                }
            }
        }
    }
}

+(void)readCharacteristic:(CBPeripheral *)peripheral sCBUUID:(CBUUID *)sCBUUID cCBUUID:(CBUUID *)cCBUUID {
    for ( CBService *service in peripheral.services ) {
        if([service.UUID isEqual:sCBUUID]) {
            for ( CBCharacteristic *characteristic in service.characteristics ) {
                if ([characteristic.UUID isEqual:cCBUUID]) {
                    /* Everything is found, read characteristic ! */
                    [peripheral readValueForCharacteristic:characteristic];
                }
            }
        }
    }
}

+(void)setNotificationForCharacteristic:(CBPeripheral *)peripheral sUUID:(NSString *)sUUID cUUID:(NSString *)cUUID enable:(BOOL)enable {
    for ( CBService *service in peripheral.services ) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:sUUID]]) {
            for (CBCharacteristic *characteristic in service.characteristics ) {
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:cUUID]])
                {
                    /* Everything is found, set notification ! */
                    [peripheral setNotifyValue:enable forCharacteristic:characteristic];
                    
                }
                
            }
        }
    }
}

+(void)setNotificationForCharacteristic:(CBPeripheral *)peripheral sCBUUID:(CBUUID *)sCBUUID cCBUUID:(CBUUID *)cCBUUID enable:(BOOL)enable {
    for ( CBService *service in peripheral.services ) {
        if ([service.UUID isEqual:sCBUUID]) {
            for (CBCharacteristic *characteristic in service.characteristics ) {
                if ([characteristic.UUID isEqual:cCBUUID])
                {
                    /* Everything is found, set notification ! */
                    [peripheral setNotifyValue:enable forCharacteristic:characteristic];
                    
                }
                
            }
        }
    }
}


+(bool) isCharacteristicNotifiable:(CBPeripheral *)peripheral sCBUUID:(CBUUID *)sCBUUID cCBUUID:(CBUUID *) cCBUUID {
    for ( CBService *service in peripheral.services ) {
        if ([service.UUID isEqual:sCBUUID]) {
            for (CBCharacteristic *characteristic in service.characteristics ) {
                if ([characteristic.UUID isEqual:cCBUUID])
                {
                    if (characteristic.properties & CBCharacteristicPropertyNotify) return YES;
                    else return NO;
                }
                
            }
        }
    }
    return NO;
}


+(CBUUID *) expandToTIUUID:(CBUUID *)sourceUUID {
    CBUUID *expandedUUID = [CBUUID UUIDWithString:TI_BASE_LONG_UUID];
    unsigned char expandedUUIDBytes[16];
    unsigned char sourceUUIDBytes[2];
    [expandedUUID.data getBytes:expandedUUIDBytes];
    [sourceUUID.data getBytes:sourceUUIDBytes];
    expandedUUIDBytes[2] = sourceUUIDBytes[0];
    expandedUUIDBytes[3] = sourceUUIDBytes[1];
    expandedUUID = [CBUUID UUIDWithData:[NSData dataWithBytes:expandedUUIDBytes length:16]];
    return expandedUUID;
}


+(NSString *) CBUUIDToString:(CBUUID *)inUUID {
    unsigned char i[16];
    [inUUID.data getBytes:i];
    if (inUUID.data.length == 2) {
        return [NSString stringWithFormat:@"%02hhx%02hhx",i[0],i[1]];
    }
    else {
        uint32_t g1 = ((i[0] << 24) | (i[1] << 16) | (i[2] << 8) | i[3]);
        uint16_t g2 = ((i[4] << 8) | (i[5]));
        uint16_t g3 = ((i[6] << 8) | (i[7]));
        uint16_t g4 = ((i[8] << 8) | (i[9]));
        uint16_t g5 = ((i[10] << 8) | (i[11]));
        uint32_t g6 = ((i[12] << 24) | (i[13] << 16) | (i[14] << 8) | i[15]);
        return [NSString stringWithFormat:@"%08x-%04hx-%04hx-%04hx-%04hx%08x",g1,g2,g3,g4,g5,g6];
    }
    return nil;
}

/*
 *  @method UUIDToString
 *  @param UUID UUID to convert to string
 *  @returns Pointer to a character buffer containing UUID in string representation
 *  @discussion UUIDToString converts the data of a CFUUIDRef class to a character pointer for easy printout using printf()
 */
+(const char *) UUIDToString:(CFUUIDRef)UUID {
    if (!UUID) return "NULL";
    CFStringRef s = CFUUIDCreateString(NULL, UUID);
    return CFStringGetCStringPtr(s, 0);
}

/*
 *  @method compareCBUUID
 *
 *  @param UUID1 UUID 1 to compare
 *  @param UUID2 UUID 2 to compare
 *
 *  @returns 1 (equal) 0 (not equal)
 *
 *  @discussion compareCBUUID compares two CBUUID's to each other and returns 1 if they are equal and 0 if they are not
 *
 */

+(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2 {
    char b1[16];
    char b2[16];
    [UUID1.data getBytes:b1];
    [UUID2.data getBytes:b2];
    if (memcmp(b1, b2, UUID1.data.length) == 0)return 1;
    else return 0;
}

/*
 *  @method compareCBUUIDToInt
 *
 *  @param UUID1 UUID 1 to compare
 *  @param UUID2 UInt16 UUID 2 to compare
 *
 *  @returns 1 (equal) 0 (not equal)
 *
 *  @discussion compareCBUUIDToInt compares a CBUUID to a UInt16 representation of a UUID and returns 1
 *  if they are equal and 0 if they are not
 *
 */
+(int) compareCBUUIDToInt:(CBUUID *)UUID1 UUID2:(UInt16)UUID2 {
    char b1[16];
    [UUID1.data getBytes:b1];
    UInt16 b2 = [self swap:UUID2];
    if (memcmp(b1, (char *)&b2, 2) == 0) return 1;
    else return 0;
}

/*
 *  @method CBUUIDToInt
 *  @param UUID1 UUID 1 to convert
 *  @returns UInt16 representation of the CBUUID
 *  @discussion CBUUIDToInt converts a CBUUID to a Uint16 representation of the UUID
 *
 */
+(UInt16) CBUUIDToInt:(CBUUID *) UUID {
    char b1[16];
    [UUID.data getBytes:b1];
    return ((b1[0] << 8) | b1[1]);
}

/*
 *  @method IntToCBUUID
 *  @param UInt16 representation of a UUID
 *  @return The converted CBUUID
 *  @discussion IntToCBUUID converts a UInt16 UUID to a CBUUID
 *
 */
+(CBUUID *) IntToCBUUID:(UInt16)UUID {
    char t[16];
    t[0] = ((UUID >> 8) & 0xff); t[1] = (UUID & 0xff);
    // if you do all 16 bytes, you get weird results.
    // possibly because the UUID is not exactly in the first 2 butes?
    // NSData *data = [[NSData alloc] initWithBytes:t length:16];
    NSData *data = [[NSData alloc] initWithBytes:t length:2];
    return [CBUUID UUIDWithData:data];
}


/*!
 *  @method swap:
 *
 *  @param s Uint16 value to byteswap
 *
 *  @discussion swap byteswaps a UInt16
 *
 *  @return Byteswapped UInt16
 */

+(UInt16) swap:(UInt16)s {
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}


+(BOOL) doesPeripheral: (CBPeripheral*) p haveServiceUUID:(CBUUID*) uuid
{
    BOOL foundService = NO;
    for(CBService* s in p.services)
    {
        if([s.UUID isEqual: uuid])
        {
            foundService = YES;
            break;
        }
    }
    return foundService;
}

+(BOOL) isUUID: (CBUUID*) uuid thisInt: (UInt16) intuuid
{
  return ([BLEUtility CBUUIDToInt:uuid]==intuuid);
}

  
@end
