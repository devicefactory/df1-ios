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


// Private stuff
@interface DF1 ()
{
    NSTimer *scanTimer;
    NSUInteger deviceCountMax;
    UInt8 regEnable;
}

-(NSUInteger) _hasPeripheral:(CBPeripheral*) p;

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

-(void) scan:(NSUInteger) maxCount
{
    if(!self.m)
    {
        DF_ERR(@"CBCentralManager does not exist!");
    }
    deviceCountMax = maxCount;
    if(!self.delegate)
    {
        DF_ERR(@"set the delegate first"); 
        return;
    }
    // rssiTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(triggerReadRSSI:) userInfo:nil repeats:YES];
    CBUUID *su = [DF1LibUtil IntToCBUUID:ACC_SERV_UUID];
    // defining these services caused the scan to fail
    NSArray *services = [NSArray arrayWithObject:su];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],
                                          CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    [self.m scanForPeripheralsWithServices:nil options:options];

    DF_DBG(@"scanning for peripheral");
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
    [self.m stopScan];
    if(peripheral==nil)
    {
        DF_DBG(@"removing %d peripherals", self.devices.count);
        for(int i=0; i<self.devices.count; i++)
        {
            CBPeripheral *p = [self.devices objectAtIndex:i];
            if(p.state==CBPeripheralStateConnected)
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
            [self deconfigureDevice:peripheral];
            self.p = nil;
        }
        [self.m cancelPeripheralConnection:peripheral];
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
    
    if(self.devices.count >= deviceCountMax)
    {
        DF_DBG(@"stopping scan");
        [self.m stopScan];
    }

    if(self.delegate &&
       [self.delegate respondsToSelector:@selector(didScan:)] &&
       i==NSNotFound)
    {
        bool keepScanning = [self.delegate didScan:(NSArray*) self.devices]; // casting?
        if(!keepScanning)
        {
            [self.m stopScan];
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
        CBUUID *su = [DF1LibUtil IntToCBUUID:ACC_SERV_UUID];
        NSArray *services    = [NSArray arrayWithObject:su];
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
        if([DF1LibUtil isUUID:s.UUID thisInt:ACC_SERV_UUID]) {
            [peripheral discoverCharacteristics:nil forService:s];
            NSLog(@"Found the accel service!!");
            self.p = peripheral;
            self.p.delegate = self;
        }
    }
    [self.m stopScan];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"entering didDiscoverCharacteristicsForService: %@", service.UUID);
    
    if([[peripheral.name lowercaseString] hasPrefix:@"dfmove"] && [DF1LibUtil isUUID:service.UUID thisInt:ACC_SERV_UUID]) {
        // int i = [self _hasPeripheral:peripheral];
        NSLog(@"found accelerometer conf characteristic");
        [self configureDevice:peripheral];
        // here we subscribe to data
    }
}

-(void) peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"didUpdateNotificationStateForCharacteristic %@ error = %@",characteristic,error);
}

-(void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"didWriteValueForCharacteristic %@ error = %@",characteristic,error);
}

- (void) peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSUInteger i = [self _hasPeripheral:peripheral];
    NSLog(@"peripheralDidUpdateRSSI for [%lu] %@ = %f error = %@",(unsigned long)i, peripheral.name, [peripheral.RSSI floatValue], error);
    if(i!=NSNotFound) {
        // NSLog([NSString stringWithFormat:@"RSSI %.0fdBm:", [peripheral.RSSI floatValue]]);
        NSLog(@"RSSI = %f",[peripheral.RSSI floatValue]);
    }
}


-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
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
    }
}


-(void) configureDevice:(CBPeripheral*) peripheral
{
    NSLog(@"subscribing from accelerometer service");
    CBUUID *sUUID = [DF1LibUtil IntToCBUUID:ACC_SERV_UUID];
    CBUUID *cUUID = [DF1LibUtil IntToCBUUID:ACC_ENABLE_UUID];
    uint8_t data = 0x01;
    // first enable accelermeter
    [DF1LibUtil writeCharacteristic:peripheral sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
    cUUID = [DF1LibUtil IntToCBUUID:ACC_XYZ_DATA8_UUID];
    [DF1LibUtil setNotificationForCharacteristic:peripheral sCBUUID:sUUID cCBUUID:cUUID enable:YES];
}


-(void) deconfigureDevice:(CBPeripheral*) peripheral
{
    CBUUID *sUUID = [DF1LibUtil IntToCBUUID:ACC_SERV_UUID];
    CBUUID *cUUID = [DF1LibUtil IntToCBUUID:ACC_ENABLE_UUID];
    NSLog(@"disabling accelerometer service");
    uint8_t data = 0x00;
    [DF1LibUtil writeCharacteristic:peripheral sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
    cUUID = [DF1LibUtil IntToCBUUID:ACC_XYZ_DATA8_UUID];
    [DF1LibUtil setNotificationForCharacteristic:peripheral sCBUUID:sUUID cCBUUID:cUUID enable:NO];
}

@end
