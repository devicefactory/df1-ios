//
//  DF1Lib.m
//  DF1Lib
//
//  Created by JB Kim on 12/16/13.
//  Copyright (c) 2013 JB Kim. All rights reserved.
//

#define DF_LEVEL 0

#import "DF1Lib.h"
#import "DF1LibUtil.h"
#import "DF1LibDefs.h"
#import "NSData+Conversion.h"

// Private stuff
@interface DF1 ()
{
    NSTimer *scanTimer;
    NSUInteger g_deviceCountMax;
    NSMutableDictionary *g_reg; // maintains current register settings
}

-(NSUInteger) _hasPeripheral:(CBPeripheral*) p;
-(void) _syncParameters;

-(void) _enableFeature:(UInt16) cuuid;
-(void) _disableFeature:(UInt16) cuuid;

@end


@implementation DF1

-(id) initWithDelegate:(id<DF1Delegate>) userDelegate
{
    self = [self init];
    if(self)
    {
        self.m = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        self.devices = [[NSMutableArray alloc] init];
        self.delegate = userDelegate;
        DF_DBG(@"initializing central");
    }
    return self;
}


-(bool) isConnected:(CBPeripheral*) p
{
    if(p==nil)
    {
        DF_ERR(@"peripheral property is nil!");
        return false;
    }
    if(![p respondsToSelector:@selector(state)])
    {
        DF_ERR(@"peripheral property self.p does not respond to state!");
        return false;
    }
    return [p state] == CBPeripheralStateConnected;
}


-(void) scan:(NSUInteger) maxCount
{
    if(!self.m)
    {
        DF_ERR(@"CBCentralManager does not exist!");
    }
    g_deviceCountMax = maxCount;
    if(!self.delegate)
    {
        DF_ERR(@"set the delegate first"); 
        return;
    }
    // rssiTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(triggerReadRSSI:) userInfo:nil repeats:YES];
    // CBUUID *su = [DF1LibUtil IntToCBUUID:ACC_SERV_UUID];
    // defining these services caused the scan to fail
    // NSArray *services = [NSArray arrayWithObject:su];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],
                                          CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    [self.m scanForPeripheralsWithServices:nil options:options];

    DF_DBG(@"scanning for peripheral");
}

-(void) stopScan:(bool) clear
{
    if(!self.m)
        return;

    DF_DBG(@"stopping central scan"); 
    [self.m stopScan];

    if(clear)
    {
        // should we disconnect all the peripherals?
        for (int i=0; i<self.devices.count; i++)
        {
            CBPeripheral *p = [self.devices objectAtIndex:i];
            if([self isConnected:p]) {
                [self.m cancelPeripheralConnection:p];
            }
        }
        [self.devices removeAllObjects];
    }

    if([self.delegate respondsToSelector:@selector(didStopScan)])
        [self.delegate didStopScan];
}


-(void) connect:(CBPeripheral*) peripheral
{
    // this is the one we are intending to connect
    peripheral.delegate = self;
    self.p = peripheral;
    // self.p.delegate = self;
    [self.m connectPeripheral:peripheral options:nil];
}

-(void) disconnect:(CBPeripheral *)peripheral
{
    if(peripheral==nil)
    {
        DF_DBG(@"removing %d peripherals", self.devices.count);
        for(int i=0; i<self.devices.count; i++)
        {
            CBPeripheral *p = [self.devices objectAtIndex:i];
            if([self isConnected:p])
                // [self deconfigureDevice:p];
                [self.m cancelPeripheralConnection:p];
        }
        self.p = nil;
        // [self.devices removeAllObjects];
    }
    else
    {
        if([peripheral isEqual:self.p])
        {
            // [self deconfigureDevice:peripheral];
            self.p = nil;
        }
        [self.m cancelPeripheralConnection:peripheral];
    }
}

-(void) askRSSI:(CBPeripheral *)peripheral
{
    if([self isConnected:peripheral])
    {
        [peripheral readRSSI]; // will invokte delegate function 
    }
}

-(void) dealloc
{
    if(scanTimer != nil)
    {
        [scanTimer invalidate];
        scanTimer = nil;
    }
}

// we actually need to check the UUID
-(NSUInteger) _hasPeripheral:(CBPeripheral*) p1
{
    if([self.devices containsObject:p1])
    {
        return [self.devices indexOfObject:p1];
    }
    else
    {
        DF_DBG(@"Found a BLE Device : %@",p1);
        return NSNotFound;
    }
    /*
    if(p1.identifier == nil)
        return NSNotFound;
    
    for(int i=0; i<self.devices.count; i++)
    {
        CBPeripheral *p = [self.devices objectAtIndex:i];
        if([p.identifier isEqual:p1.identifier])
            return i;
    }
    return NSNotFound;
     */
}


#pragma mark - CBCentralManager delegate

-(void) centralManagerDidUpdateState:(CBCentralManager*) central
{
    DF_DBG(@"centralManagerDidUpdateState with state: %d", central.state);

    if (central.state != CBCentralManagerStatePoweredOn)
    {
        if(central.state == CBCentralManagerStatePoweredOff)
        {
            DF_ALT(@"central error %d",central.state);
            // trigger alert to the delegate?
            if(self.delegate && [self.delegate respondsToSelector:@selector(hasCentralErrors:)])
            {
                [self.delegate hasCentralErrors:central];
            }
        }
    }
    else
    {
        self.m = central;
        
        // NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
        //                                      CBCentralManagerScanOptionAllowDuplicatesKey, nil];
        // [self.m scanForPeripheralsWithServices:nil options:options];
    }
}


-(void) centralManager:(CBCentralManager*) central didDiscoverPeripheral:(CBPeripheral*) peripheral
            advertisementData:(NSDictionary*) advertisementData RSSI:(NSNumber*) RSSI
{
    NSUInteger i = [self _hasPeripheral:peripheral];
    (i==NSNotFound) ?
        [self.devices addObject:peripheral] :
        [self.devices replaceObjectAtIndex:i withObject:peripheral];

    // if the peripheral is found, and we are scanning but has already been connected
    /*
    if([peripheral respondsToSelector:@selector(state)] &&
       [peripheral state] == CBPeripheralStateConnected &&
       i==NSNotFound)
    {
        DF_DBG(@"cancelling peripheral connection because of previous connected state");
        [self.m cancelPeripheralConnection:peripheral];
    }
     */
    
    if(self.devices.count >= g_deviceCountMax)
    {
        DF_DBG(@"stopping scan");
        [self stopScan:false];
    }

    if(self.delegate &&
       [self.delegate respondsToSelector:@selector(didScan:)] &&
       i==NSNotFound)
    {
        bool keepScanning = [self.delegate didScan:(NSArray*) self.devices]; // casting?
        if(!keepScanning)
        {
            [self stopScan:false];
        }
    }
    /* left here as reference from:
      https://github.com/Sensorcon/Sensordrone-iOS-Library/blob/master/SensordroneiOSLibrary/SensordroneiOSLibrary.m

    // Get the device name
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
     if (localName != nil && [localName rangeOfString:@"Sensordrone"].location != NSNotFound) {
     
     // Add the name and peripheral to our list
     [scannedDroneNames addObject:localName];
     [scannedDronePeriperals addObject:peripheral];
     // Fire away
     [self notifyDelegate:@selector(doOnFoundDrone)];
     }
     */
}


-(void) centralManager:(CBCentralManager*) central didConnectPeripheral:(CBPeripheral*) peripheral
{
    peripheral.delegate = self;
    // Match if we have this device from before
    NSUInteger i = [self _hasPeripheral:peripheral];
    (i==NSNotFound) ?
        [self.devices addObject:peripheral] :
        [self.devices replaceObjectAtIndex:i withObject:peripheral];
    
    // if this peripheral is the one we were trying to connect to
    if([peripheral isEqual: self.p])
    {
        CBUUID *aserv = [DF1LibUtil IntToCBUUID:ACC_SERV_UUID];
        CBUUID *bserv = [DF1LibUtil IntToCBUUID:BATT_SERVICE_UUID];
        CBUUID *tserv = [DF1LibUtil IntToCBUUID:TEST_SERV_UUID];
        NSArray *services    = [NSArray arrayWithObjects: aserv, bserv, tserv, nil];
        [peripheral discoverServices:services];
    }
}

-(void) centralManager:(CBCentralManager*) central didFailToConnectPeripheral:(CBPeripheral*) peripheral
            error:(NSError*) error
{
    DF_DBG(@"didFailToConnectPeripheral: %@", peripheral.identifier);
}

-(void) centralManager:(CBCentralManager*) central didDisconnectPeripheral:(CBPeripheral*) peripheral
            error:(NSError*) error
{
    DF_DBG(@"didDisconnectPeripheral for %@ error = %@",peripheral.name, error);
    NSUInteger i = [self _hasPeripheral: peripheral];
    if(i!=NSNotFound) {
        [self.devices removeObjectAtIndex:i];
    }
}


#pragma  mark - CBPeripheral delegate

-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    DF_DBG(@"entering didDiscoverServices for p = %@, error = %@", peripheral.name, error);
    
    // [self.m cancelPeripheralConnection:peripheral];
    for (CBService *s in peripheral.services) {
        UInt16 iuuid = [DF1LibUtil CBUUIDToInt:s.UUID];
        NSLog(@"Service found : %@, 0x%4x",s.UUID, iuuid);
        [peripheral discoverCharacteristics:nil forService:s];
        // if([DF1LibUtil isUUID:s.UUID thisInt:ACC_SERV_UUID]) {
        //    [peripheral discoverCharacteristics:nil forService:s];
        //    NSLog(@"Found the accel service!!");
        //    self.p = peripheral;
        //    self.p.delegate = self;
        //}
    }
}


- (void) peripheral:(CBPeripheral *)peripheral
    didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"entering didDiscoverCharacteristicsForService: %@", service.UUID);
    
    if([[peripheral.name lowercaseString] hasPrefix:@"df1"] &&
        [DF1LibUtil isUUID:service.UUID thisInt:ACC_SERV_UUID] &&
        [service.characteristics count]>0) {
        // int i = [self _hasPeripheral:peripheral];
        NSLog(@"found accelerometer conf characteristic");
        [self _syncParameters];
        // here we subscribe to data
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(didConnect:)])
    {
        [self.delegate didConnect:peripheral];
    }
}


-(void) peripheral:(CBPeripheral *)peripheral
    didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
    error:(NSError *)error
{
    NSLog(@"didUpdateNotificationStateForCharacteristic %@ error = %@",characteristic,error);
}


-(void) peripheral:(CBPeripheral *)peripheral
    didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"didWriteValueForCharacteristic %@ error = %@",characteristic,error);
}


- (void) peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSUInteger i = [self _hasPeripheral:peripheral];
    float rssi = [peripheral.RSSI floatValue];
    DF_DBG(@"peripheralDidUpdateRSSI for [%lu] %@ = %f error = %@",
            (unsigned long)i, peripheral.name, [peripheral.RSSI floatValue], error);
    if(i!=NSNotFound) {
        // NSLog([NSString stringWithFormat:@"RSSI %.0fdBm:", [peripheral.RSSI floatValue]]);
        DF_DBG(@"RSSI = %f",rssi);
        if(self.delegate!=nil) {
            if([self.delegate respondsToSelector:@selector(didUpdateRSSI:withRSSI:)])
                [self.delegate didUpdateRSSI:peripheral withRSSI:rssi];
        }
    }
}


-(void)peripheral:(CBPeripheral *)peripheral
    didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    static float lastx = 0;
    static float lasty = 0;
    static float lastz = 0;
    static NSUInteger count = 0;
    if (error) {
        NSLog(@"didUpdateValueForCharacteristic error: %@", error);
        return;
    }
    
    UInt16 cUUID = [DF1LibUtil CBUUIDToInt:characteristic.UUID];
    switch(cUUID)
    {
        case ACC_XYZ_DATA8_UUID:
        {
            char adata[3];
            [characteristic.value getBytes:&adata length:3];
            float x = ((float)adata[0])/64.0;
            float y = ((float)adata[1])/64.0;
            float z = ((float)adata[2])/64.0;
            if(count++ % 50 == 0)
                DF_DBG(@"getting values: %f,%f,%f",x,y,z);
            x = (x+2)*64.0;
            y = (-y+2)*64.0;
            
            // [renderer renderByRotatingAroundX:(lastx - x) rotatingAroundY:(lasty - y)];
            lastx = x;
            lasty = y;
            lastz = z;
            break;
        }
        case ACC_XYZ_DATA14_UUID:
        {
            break;
        }
        case ACC_TAP_DATA_UUID:
        {
            break;
        }
        case ACC_FF_DATA_UUID:
        {
            break;
        }
        case ACC_MO_DATA_UUID:
        {
            break;
        }
        case ACC_TRAN_DATA_UUID:
        {
            break;
        }
        case ACCD_FALL_DATA_UUID:
        {
            break;
        }
        case BATT_LEVEL_UUID:
        {
            break;
        }
        case TEST_DATA_UUID:
        {
            break;
        }
        // rest are all parameter related
        case ACC_GEN_CFG_UUID:
        case ACC_ENABLE_UUID:
        case ACC_TAP_THSZ_UUID:
        case ACC_TAP_THSX_UUID:
        case ACC_TAP_THSY_UUID:
        case ACC_TAP_TMLT_UUID:
        case ACC_TAP_LTCY_UUID:
        case ACC_TAP_WIND_UUID:
        case ACC_FF_THS_UUID:
        case ACC_MO_THS_UUID:
        case ACC_FFMO_DEB_UUID:
        case ACC_TRAN_THS_UUID:
        case ACC_TRAN_DEB_UUID:
        case ACC_TRAN_HPF_UUID:
        case TEST_CONF_UUID:
            [self _updateParameters:characteristic]; 
    }
}



-(void) _syncParameters
{
    DF_DBG(@"snapping UUID parameters");
    if(![self isConnected:self.p]) return;
    
    #define UUID_NUM 14
    
    UInt16 cuuids[UUID_NUM] = {ACC_GEN_CFG_UUID, ACC_ENABLE_UUID,
                        ACC_TAP_THSZ_UUID, ACC_TAP_THSX_UUID, ACC_TAP_THSY_UUID,
                        ACC_TAP_TMLT_UUID, ACC_TAP_LTCY_UUID, ACC_TAP_WIND_UUID,
                        ACC_FF_THS_UUID,   ACC_MO_THS_UUID,   ACC_FFMO_DEB_UUID,
        ACC_TRAN_THS_UUID, ACC_TRAN_DEB_UUID, ACC_TRAN_HPF_UUID};
    // read all the config related characteristics first
    for(int i=0; i<UUID_NUM; i++)
    {
        UInt16 cuuid = cuuids[i];
        [DF1LibUtil readCharacteristic:self.p sUUID:ACC_SERV_UUID cUUID:cuuid];
    }
}

// Maintain the most up-to-date register values from DF1 device. We attempt to keep the 
// parameters on the target device and our App synchronized.
-(void) _updateParameters:(CBCharacteristic*) c
{
    // alloc on the fly
    if(g_reg == nil) 
        g_reg = [[NSMutableDictionary alloc] init];
    // notice the use for category extension function
    DF_DBG(@"received from %@ = %@", [DF1LibUtil CBUUIDToString:c.UUID], [c.value hexString]);
    // here, strong reference to the object (value) is maintained 
    [g_reg setObject:c.value forKey:c.UUID]; // cuuid (CBUUID*) -> CBCharacteristic.value (NSData*)
}


-(void) _enableFeature:(UInt16) cuuid
{
    if(![self isConnected:self.p]) 
        return;

    char enreg = 0x00;
    // get current stored byte 
    NSData *data = [g_reg objectForKey:[DF1LibUtil IntToCBUUID:ACC_ENABLE_UUID]];
    if(data.length > 0)
    {
        char byte;
        [data getBytes:&byte length:1];
        DF_DBG(@"current stored byte for CUUID %x: %x", cuuid, byte);
        enreg = byte;
    }
    switch(cuuid)
    {
        case ACC_XYZ_DATA8_UUID:   enreg |= ENABLE_XYZ8_MASK; break;
        case ACC_XYZ_DATA14_UUID:  enreg |= ENABLE_XYZ14_MASK; break;
        case ACC_TAP_DATA_UUID:    enreg |= ENABLE_TAP_MASK; break;
        case ACC_FF_DATA_UUID:     enreg |= ENABLE_FF_MASK; break;
        case ACC_MO_DATA_UUID:     enreg |= ENABLE_MO_MASK; break;
        case ACC_TRAN_DATA_UUID:   enreg |= ENABLE_TRAN_MASK; break;
        case ACCD_FALL_DATA_UUID:  enreg |= ENABLE_USR1_MASK; break;
        // case ACC_USR2_DATA_UUID:   enreg |= ENABLE_USR2_MASK; break;
    }
    [DF1LibUtil writeCharacteristic:self.p sUUID:ACC_SERV_UUID cUUID:ACC_ENABLE_UUID withByte:enreg];
    [g_reg setObject:[NSData dataWithBytes:&enreg length:1] forKey:[DF1LibUtil IntToCBUUID:ACC_ENABLE_UUID]]; // store the register
}


-(void) _disableFeature:(UInt16) cuuid
{
    if(![self isConnected:self.p]) 
        return;

    char enreg = 0x00;
    // get current stored byte 
    NSData *data = [g_reg objectForKey:[DF1LibUtil IntToCBUUID:ACC_ENABLE_UUID]];
    if(data.length > 0)
    {
        char byte;
        [data getBytes:&byte length:1];
        DF_DBG(@"current stored byte for CUUID %x: %x", cuuid, byte);
        enreg = byte;
    }
    switch(cuuid)
    {
        case ACC_XYZ_DATA8_UUID:   enreg &= ~ENABLE_XYZ8_MASK; break;
        case ACC_XYZ_DATA14_UUID:  enreg &= ~ENABLE_XYZ14_MASK; break;
        case ACC_TAP_DATA_UUID:    enreg &= ~ENABLE_TAP_MASK; break;
        case ACC_FF_DATA_UUID:     enreg &= ~ENABLE_FF_MASK; break;
        case ACC_MO_DATA_UUID:     enreg &= ~ENABLE_MO_MASK; break;
        case ACC_TRAN_DATA_UUID:   enreg &= ~ENABLE_TRAN_MASK; break;
        case ACCD_FALL_DATA_UUID:  enreg &= ~ENABLE_USR1_MASK; break; // derived event, hence ACCD_ instead of ACC_
        // case ACC_USR2_DATA_UUID:   enreg |= ENABLE_USR2_MASK; break;
    }
    DF_DBG(@"writing byte to ACC_ENABLE_UUID stored byte for CUUID %x: %x", cuuid, enreg);
    [DF1LibUtil writeCharacteristic:self.p sUUID:ACC_SERV_UUID cUUID:ACC_ENABLE_UUID withByte:enreg];
    [g_reg setObject:[NSData dataWithBytes:&enreg length:1] forKey:[DF1LibUtil IntToCBUUID:ACC_ENABLE_UUID]]; // store the register
}


-(void) subscription:(UInt16) suuid withCUUID:(UInt16) cuuid onOff:(BOOL)enable
{
    if(![self isConnected:self.p]) 
    {
        DF_ERR(@"peripheral property self.p not valid!");
        return;
    }
    [DF1LibUtil setNotificationForCharacteristic:self.p sUUID:suuid cUUID:cuuid enable:enable];
}

// Turn on individual features
-(void) subscribeXYZ8
{
    [self _enableFeature:ACC_XYZ_DATA8_UUID];
    [self subscription:ACC_SERV_UUID withCUUID:ACC_XYZ_DATA8_UUID onOff:true];
}
-(void) subscribeXYZ14
{
    [self _enableFeature:ACC_XYZ_DATA14_UUID];
    [self subscription:ACC_SERV_UUID withCUUID:ACC_XYZ_DATA14_UUID onOff:true];
}
-(void) subscribeTap
{
    [self _enableFeature:ACC_TAP_DATA_UUID];
    [self subscription:ACC_SERV_UUID withCUUID:ACC_TAP_DATA_UUID onOff:true];
}
-(void) subscribeFreefall
{
    [self _enableFeature:ACC_FF_DATA_UUID];
    [self subscription:ACC_SERV_UUID withCUUID:ACC_FF_DATA_UUID onOff:true];
}
-(void) subscribeMotion
{
    [self _enableFeature:ACC_MO_DATA_UUID];
    [self subscription:ACC_SERV_UUID withCUUID:ACC_MO_DATA_UUID onOff:true];
}
-(void) subscribeShake
{
    [self _enableFeature:ACC_TRAN_DATA_UUID];
    [self subscription:ACC_SERV_UUID withCUUID:ACC_TRAN_DATA_UUID onOff:true];
}

// Turn off features
-(void) unsubscribeXYZ8
{
    [self _disableFeature:ACC_XYZ_DATA8_UUID];
    [self subscription:ACC_SERV_UUID withCUUID:ACC_XYZ_DATA8_UUID onOff:false];
}

-(void) modifyRange:(UInt8) value
{
}

-(void) modifyTapThsz:(double) g
{
}

-(void) modifyTapThsx:(double) g
{
}

-(void) modifyTapThsy:(double) g
{
}

-(void) modifyTapTmlt:(double) msec
{
}

-(void) modifyTapLtcy:(double) msec
{
}

-(void) modifyTapWind:(double) msec
{
}

-(void) modifyFreefallThs:(double) g
{
}

-(void) modifyFreefallDeb:(double) msec
{
}

-(void) modifyMotionThs:(double) g
{
}

-(void) modifyMotionDeb:(double) msec
{
}

-(void) modifyShakeThs:(double) g
{
}

-(void) modifyShakeDeb:(double) msec
{
}

-(void) modifyShakeHpf:(double) hz
{
}


@end
