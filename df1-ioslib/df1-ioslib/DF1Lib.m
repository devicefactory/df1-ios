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
    NSArray *g_defaultServices;
    float accDivisor;
    float accDivisor14;
    bool scanOtherDevices;
}

-(bool) _hasPeripheral:(CBPeripheral*) p;

-(void) _enableFeature:(UInt16) cuuid;
-(void) _disableFeature:(UInt16) cuuid;

@end


@implementation DF1

-(id) initWithDelegate:(id<DF1Delegate>) userDelegate
{
    self = [self init];
    if(self)
    {
        self.delegate = userDelegate;
        self.m = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        
        self.devices = [[NSMutableDictionary alloc] init];
        // self.deviceList = [[NSMutableArray alloc] init]; // initialized later

        DF_DBG(@"initializing central");
        if(g_defaultServices==nil)
        {
            CBUUID *aserv = [DF1LibUtil IntToCBUUID:ACC_SERV_UUID];
            CBUUID *bserv = [DF1LibUtil IntToCBUUID:BATT_SERVICE_UUID];
            CBUUID *tserv = [DF1LibUtil IntToCBUUID:TEST_SERV_UUID];
            g_defaultServices = [NSArray arrayWithObjects: aserv, bserv, tserv, nil];
        }
        // default is 2G
        accDivisor = 64.0;
        accDivisor14 = 4096.0;

        scanOtherDevices = false;
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
    if(self.delegate==nil)
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
        // [inventory enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        //    NSLog(@"There are %@ %@'s in stock", obj, key);
        // }];
        // should we disconnect all the peripherals?
        for (id key in self.devices)
        {
            CBPeripheral *p = (CBPeripheral*) key;
            if([self isConnected:p]) {
                [self.m cancelPeripheralConnection:p];
            }
        }
        [self.devices removeAllObjects];
        [self.deviceList removeAllObjects];
    }

    if([self.delegate respondsToSelector:@selector(didStopScan)])
        [self.delegate didStopScan];
}


-(void) connect:(CBPeripheral*) peripheral withServices:(NSArray*) services
{
    self.p = peripheral;
    peripheral.delegate = self;
    if(services==nil)
        services = g_defaultServices;
    DF_DBG(@"connect with %lu specified services",(unsigned long)services.count);
    [self.devices setObject:services forKey:peripheral]; // CBPeripheral -> CBUUIDs
    [self.m connectPeripheral:peripheral options:nil];
}

-(void) connect:(CBPeripheral*) peripheral
{
    [self connect:peripheral withServices:nil];
}

-(void) disconnect:(CBPeripheral *)peripheral
{
    if(peripheral==nil)
    {
        DF_DBG(@"removing %lu peripherals", (unsigned long)self.devices.count);
        for (id key in self.devices)
        {
            CBPeripheral *p = (CBPeripheral*) key;
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

-(NSDictionary*) getParams
{
    return g_reg;
}

// we actually need to check the UUID
-(bool) _hasPeripheral:(CBPeripheral*) p1
{
    if([self.devices objectForKey:p1]!=nil)
    {
        return true;
    }
    DF_DBG(@"Found a BLE Device : %@",p1);
    return false;
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
    // reference from:
    //  https://github.com/Sensorcon/Sensordrone-iOS-Library/blob/master/SensordroneiOSLibrary/SensordroneiOSLibrary.m
    // Get the device name from advertisementData
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    // if the advertisement name contains df1
    if (localName != nil && [localName rangeOfString:@"df1"].location != NSNotFound) 
    { 
    }
    else
    {
        if(!scanOtherDevices) {
            DF_DBG(@"skipping because we are not interested in other devices");
            return;
        }
    }

    bool hasit = [self _hasPeripheral:peripheral];
    if(!hasit)
        [self.devices setObject:g_defaultServices forKey:peripheral];
    
    if(self.devices.count >= g_deviceCountMax)
    {
        DF_DBG(@"stopping scan");
        [self stopScan:false];
    }

    if(self.delegate &&
       [self.delegate respondsToSelector:@selector(didScan:)] &&
       !hasit)
    {
        // self.deviceList = (NSMutableArray*) [self.devices allKeys];
        // create a copy here because external app can hold a pointer to this
        self.deviceList = [[NSMutableArray alloc] initWithArray:[self.devices allKeys] copyItems:YES];
        bool keepScanning = [self.delegate didScan:self.deviceList];
        if(!keepScanning)
        {
            [self stopScan:false];
        }
    }
}


-(void) centralManager:(CBCentralManager*) central didConnectPeripheral:(CBPeripheral*) peripheral
{
    peripheral.delegate = self;
    // Match if we have this device from before
    bool hasit = [self _hasPeripheral:peripheral];
    if(!hasit)
        [self.devices setObject:g_defaultServices forKey:peripheral];
    
    NSArray *services = [self.devices objectForKey:peripheral];
    // if this peripheral is the one we were trying to connect to
    // [peripheral discoverServices:services];
    [peripheral discoverServices:nil];
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
    bool hasit = [self _hasPeripheral: peripheral];
    if(hasit) {
        [self.devices removeObjectForKey:peripheral];
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
    
    // if we found DF1 and we have valid list of characteristics for ACC_SERV_UUID
    if([[peripheral.name lowercaseString] hasPrefix:@"df1"] &&
        [DF1LibUtil isUUID:service.UUID thisInt:ACC_SERV_UUID] &&
        [service.characteristics count]>0) {
        self.p = peripheral;
        NSLog(@"found accelerometer conf characteristic");
        // [self syncParameters]; // user callable
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
    // Useless, the values in the characteristic is not updated
    // NSLog(@"didWriteValueForCharacteristic %@ error = %@",characteristic,error);

//     UInt16 cUUID = [DF1LibUtil CBUUIDToInt:characteristic.UUID];
//     switch(cUUID)
//     {
//         case ACC_GEN_CFG_UUID:
//         {
//             uint8_t bt;
//             [characteristic.value getBytes:&bt length:1];
//             DF_DBG(@"did write ACC_GEN_CFG_UUID with byte: 0x%x",bt);
//             if(! (bt & (GEN_CFG_RA1_MASK|GEN_CFG_RA0_MASK)) )            {  accDivisor = 64.0; }
//             else if((bt & GEN_CFG_RA0_MASK) && !(bt & GEN_CFG_RA1_MASK)) {  accDivisor = 32.0; }
//             else if(!(bt & GEN_CFG_RA0_MASK) && (bt & GEN_CFG_RA1_MASK)) {  accDivisor = 16.0; }
//             else                                                         {  accDivisor = 64.0; } 
//             break;
//         }
//     }
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

    if (error) {
        NSLog(@"didUpdateValueForCharacteristic error: %@", error);
        return;
    }
    
    UInt16 cUUID = [DF1LibUtil CBUUIDToInt:characteristic.UUID];
    switch(cUUID)
    {
        case ACC_XYZ_DATA8_UUID:
        {
            // holy shizo, uint8_t and char are different!!!
            uint8_t adata[3];
            [characteristic.value getBytes:adata length:3];
            float x = (float)((int8_t)adata[0])/accDivisor;
            float y = (float)((int8_t)adata[1])/accDivisor;
            float z = (float)((int8_t)adata[2])/accDivisor;
            // if(count++ % 50 == 0) DF_DBG(@"getting values: %f,%f,%f",x,y,z);
            lastx = x;
            lasty = y;
            lastz = z;
            NSNumber *xf = [NSNumber numberWithFloat:x];
            NSNumber *yf = [NSNumber numberWithFloat:y];
            NSNumber *zf = [NSNumber numberWithFloat:z];
            NSArray *fdata = [[NSArray alloc] initWithObjects:xf,yf,zf,nil];

            if([self.delegate respondsToSelector:@selector(receivedXYZ8:)]) {
                [self.delegate receivedXYZ8:fdata];
            }
            break;
        }
        case ACC_XYZ_DATA14_UUID:
        {
            uint8_t adata[6];
            [characteristic.value getBytes:adata length:6];
            
            float x = (float)(((int16_t)((adata[0]<<8)|adata[1]))>>2)/accDivisor14;
            float y = (float)(((int16_t)((adata[2]<<8)|adata[3]))>>2)/accDivisor14;
            float z = (float)(((int16_t)((adata[4]<<8)|adata[5]))>>2)/accDivisor14;
            lastx = x;
            lasty = y;
            lastz = z;
            NSNumber *xf = [NSNumber numberWithFloat:x];
            NSNumber *yf = [NSNumber numberWithFloat:y];
            NSNumber *zf = [NSNumber numberWithFloat:z];
            NSArray *fdata = [[NSArray alloc] initWithObjects:xf,yf,zf,nil];
            
            if([self.delegate respondsToSelector:@selector(receivedXYZ14:)]) {
                [self.delegate receivedXYZ14:fdata];
            }
            break;
        }
        case ACC_TAP_DATA_UUID:
        {
            uint8_t bt;
            [characteristic.value getBytes:&bt length:1]; 
            // Bit 7   EA  one or more event flag has been asserted
            // Bit 6   AxZ Z-event triggered
            // Bit 5   AxY Y-event triggered
            // Bit 4   AxX X-event triggered
            // Bit 3   DPE 0 = single pulse, 1 = double pulse
            // Bit 2   PolZ    Z event 0=positive g 1=negative g
            // Bit 1   PolY    Y event 0=positive g 1=negative g
            // Bit 0   PolX    X event 0=positive g 1=negative g
            NSDictionary  *data = @{
                @"TapHasEvent"    : [NSNumber numberWithInt: (bt & 0x80)],
                @"TapIsZEvent"    : [NSNumber numberWithInt: (bt & 0x40)],
                @"TapIsYEvent"    : [NSNumber numberWithInt: (bt & 0x20)],
                @"TapIsXEvent"    : [NSNumber numberWithInt: (bt & 0x10)],
                @"TapDoubleEvent" : [NSNumber numberWithInt: (bt & 0x08)],
                @"TapIsXNegative" : [NSNumber numberWithInt: (bt & 0x04)],
                @"TapIsYNegative" : [NSNumber numberWithInt: (bt & 0x02)],
                @"TapIsZNegative" : [NSNumber numberWithInt: (bt & 0x01)],
            };
            if([self.delegate respondsToSelector:@selector(receivedTap:)]) {
                [self.delegate receivedTap:data];
            }
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
            uint8_t bt;
            [characteristic.value getBytes:&bt length:1]; 
            float battlev = ((float)bt) / 100.0;
            if([self.delegate respondsToSelector:@selector(receivedBatt:)]) {
                [self.delegate receivedBatt:battlev];
            }
            break;
        }
        case TEST_DATA_UUID:
        {
            break;
        }
        // rest are all parameter related
        case ACC_GEN_CFG_UUID:
        {
            uint8_t bt;
            [characteristic.value getBytes:&bt length:1];
            DF_DBG(@"did write ACC_GEN_CFG_UUID with byte: 0x%x",bt);
            if(! (bt & (GEN_CFG_RA1_MASK|GEN_CFG_RA0_MASK)) )            {
                accDivisor = 64.0;
                accDivisor14 = 4096.0;
            }
            else if((bt & GEN_CFG_RA0_MASK) && !(bt & GEN_CFG_RA1_MASK)) {
                accDivisor = 32.0;
                accDivisor14 = 2048.0;
            }
            else if(!(bt & GEN_CFG_RA0_MASK) && (bt & GEN_CFG_RA1_MASK)) {
                accDivisor = 16.0;
                accDivisor14 = 1024.0;
            }
            else                                                         {
                accDivisor = 64.0;
                accDivisor14 = 4096.0;
            }
        }
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
            break;
    }
    //receivedValue:(CBPeripheral*) peripheral forCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
    if([self.delegate respondsToSelector:@selector(receivedValue:forCharacteristic:error:)]) {
        [self.delegate receivedValue:peripheral forCharacteristic:characteristic error:error];
    }
}



-(void) syncParameters
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
    //DF_DBG(@"received from %@ = %@", [DF1LibUtil CBUUIDToString:c.UUID], [c.value hexString]);
    // here, strong reference to the object (value) is maintained 
    [g_reg setObject:c.value forKey:c.UUID]; // cuuid (CBUUID*) -> CBCharacteristic.value (NSData*)
    if([DF1LibUtil compareCBUUIDToInt:c.UUID UUID2:ACC_TRAN_HPF_UUID] && [g_reg count]>5)
    {
        if([self.delegate respondsToSelector:@selector(didSyncParameters:)]) {
            [self.delegate didSyncParameters:(NSDictionary*)g_reg];
        }
    }
}

-(void) _modifyRegister:(UInt16) cuuid clearMask:(uint8_t) clear setMask:(uint8_t) set
{
    if(![self isConnected:self.p]) 
    {
        DF_DBG(@"peripheral not connected!");
        return;
    }

    uint8_t enreg = 0x00;
    // get current stored byte 
    NSData *data = [g_reg objectForKey:[DF1LibUtil IntToCBUUID:cuuid]];
    if(data != nil && data.length > 0)
    {
        uint8_t byte;
        [data getBytes:&byte length:1];
        // DF_DBG(@"current stored byte for CUUID %x: %x", cuuid, byte);
        enreg = byte;
    }
    // clear first and then set
    if(clear > 0)
    {
        enreg &= ~clear;
    }
    if(set > 0)
    {
        enreg |= set;
    }
    DF_DBG(@"writing byte to CUUID 0x%x: 0x%x", cuuid, enreg);
    [DF1LibUtil writeCharacteristic:self.p sUUID:ACC_SERV_UUID cUUID:cuuid withByte:enreg];
    [g_reg setObject:[NSData dataWithBytes:&enreg length:1] forKey:[DF1LibUtil IntToCBUUID:cuuid]]; // store the register
}

-(void) _modifyRegister:(UInt16) cuuid setValue:(uint8_t) value
{
    [self _modifyRegister:cuuid clearMask:0xff setMask:value];
}


-(void) _enableFeature:(UInt16) cuuid
{
    char enreg = 0x00;
    switch(cuuid)
    {
        case ACC_XYZ_DATA8_UUID:   enreg = ENABLE_XYZ8_MASK; break;
        case ACC_XYZ_DATA14_UUID:  enreg = ENABLE_XYZ14_MASK; break;
        case ACC_TAP_DATA_UUID:    enreg = ENABLE_TAP_MASK; break;
        case ACC_FF_DATA_UUID:     enreg = ENABLE_FF_MASK; break;
        case ACC_MO_DATA_UUID:     enreg = ENABLE_MO_MASK; break;
        case ACC_TRAN_DATA_UUID:   enreg = ENABLE_TRAN_MASK; break;
        case ACCD_FALL_DATA_UUID:  enreg = ENABLE_USR1_MASK; break;
        // case ACC_USR2_DATA_UUID:   enreg |= ENABLE_USR2_MASK; break;
    }
    [self _modifyRegister:ACC_ENABLE_UUID clearMask:0x00 setMask:enreg];
}


-(void) _disableFeature:(UInt16) cuuid
{
    char enreg = 0x00;
    switch(cuuid)
    {
        case ACC_XYZ_DATA8_UUID:   enreg = ENABLE_XYZ8_MASK; break;
        case ACC_XYZ_DATA14_UUID:  enreg = ENABLE_XYZ14_MASK; break;
        case ACC_TAP_DATA_UUID:    enreg = ENABLE_TAP_MASK; break;
        case ACC_FF_DATA_UUID:     enreg = ENABLE_FF_MASK; break;
        case ACC_MO_DATA_UUID:     enreg = ENABLE_MO_MASK; break;
        case ACC_TRAN_DATA_UUID:   enreg = ENABLE_TRAN_MASK; break;
        case ACCD_FALL_DATA_UUID:  enreg = ENABLE_USR1_MASK; break; // derived event, hence ACCD_ instead of ACC_
        // case ACC_USR2_DATA_UUID:   enreg |= ENABLE_USR2_MASK; break;
    }
    [self _modifyRegister:ACC_ENABLE_UUID clearMask:enreg setMask:0x00];
}


-(void) subscription:(UInt16) suuid withCUUID:(UInt16) cuuid onOff:(BOOL)enable
{
    if(![self isConnected:self.p]) 
    {
        DF_ERR(@"peripheral property self.p not valid!");
        return;
    }
    DF_DBG(@"subscribing from %@ %@",[DF1LibUtil CBUUIDToString:[DF1LibUtil IntToCBUUID:suuid]],
                                    [DF1LibUtil CBUUIDToString:[DF1LibUtil IntToCBUUID:cuuid]]);
    [DF1LibUtil setNotificationForCharacteristic:self.p sUUID:suuid cUUID:cuuid enable:enable];
}

-(void) subscribeBatt
{
    // initiate the first read
    [DF1LibUtil readCharacteristic:self.p sUUID:BATT_SERVICE_UUID cUUID:BATT_LEVEL_UUID];
    [self subscription:BATT_SERVICE_UUID withCUUID:BATT_LEVEL_UUID onOff:true];
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
-(void) unsubscribeBatt
{
    [self subscription:BATT_SERVICE_UUID withCUUID:BATT_LEVEL_UUID onOff:false];
}

-(void) unsubscribeXYZ8
{
    [self _disableFeature:ACC_XYZ_DATA8_UUID];
    [self subscription:ACC_SERV_UUID withCUUID:ACC_XYZ_DATA8_UUID onOff:false];
}

-(void) unsubscribeXYZ14
{
    [self _disableFeature:ACC_XYZ_DATA14_UUID];
    [self subscription:ACC_SERV_UUID withCUUID:ACC_XYZ_DATA14_UUID onOff:false];
}

-(void) unsubscribeTap
{
    [self _disableFeature:ACC_TAP_DATA_UUID];
    [self subscription:ACC_SERV_UUID withCUUID:ACC_TAP_DATA_UUID onOff:false];
}

-(void) modifyRange:(UInt8) value
{
    uint8_t clear = GEN_CFG_RA1_MASK|GEN_CFG_RA0_MASK;
    if(value==4)       // RA1:RA0 == 0:1  4G
    {
        [self _modifyRegister:ACC_GEN_CFG_UUID clearMask:clear setMask:GEN_CFG_RA0_MASK];
        // accDivisor = 32.0;
    } 
    else if(value==8)  // RA1:RA0 == 1:0  8G
    {
        [self _modifyRegister:ACC_GEN_CFG_UUID clearMask:clear setMask:GEN_CFG_RA1_MASK];
        // accDivisor = 16.0;
    } 
    else               // RA1:RA0 == 0:0  2G by default
    {
        [self _modifyRegister:ACC_GEN_CFG_UUID clearMask:clear setMask:0x00];
        // accDivisor = 64.0;
    }
    // incur a read immediately following the setting : this will modify the accDivisor in didUpdateChar..
    [DF1LibUtil readCharacteristic:self.p sUUID:ACC_SERV_UUID cUUID:ACC_GEN_CFG_UUID];
}

-(void) modifyTapThsz:(float) g
{
    g = fabsf(g); // just to make sure
    uint8_t mult = (uint8_t) (g / 0.063f); 
    DF_DBG(@"TapThsz is %d", mult);
    [self _modifyRegister:ACC_TAP_THSZ_UUID setValue:mult];
}

-(void) modifyTapThsx:(float) g
{
    g = fabsf(g); // just to make sure
    uint8_t mult = (uint8_t) (g / 0.063f); 
    [self _modifyRegister:ACC_TAP_THSX_UUID setValue:mult];
}

-(void) modifyTapThsy:(float) g
{
    g = fabsf(g); // just to make sure
    uint8_t mult = (uint8_t) (g / 0.063f); 
    [self _modifyRegister:ACC_TAP_THSY_UUID setValue:mult];
}

-(void) modifyTapTmlt:(float) msec
{
    msec = fabsf(msec);
    uint8_t incr = (uint8_t) (msec / 10.0f); // expressed as multiple of 10msec
    DF_DBG(@"TapTmlt is %d or %f msec", incr, msec);
    [self _modifyRegister:ACC_TAP_TMLT_UUID setValue:incr];
}

-(void) modifyTapLtcy:(float) msec
{
}

-(void) modifyTapWind:(float) msec
{
}

-(void) modifyFreefallThs:(float) g
{
}

-(void) modifyFreefallDeb:(float) msec
{
}

-(void) modifyMotionThs:(float) g
{
}

-(void) modifyMotionDeb:(float) msec
{
}

-(void) modifyShakeThs:(float) g
{
}

-(void) modifyShakeDeb:(float) msec
{
}

-(void) modifyShakeHpf:(float) hz
{
}


@end
