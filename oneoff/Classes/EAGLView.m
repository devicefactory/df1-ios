//
//  EAGLView.m
//  CubeExample
//
//  Created by Brad Larson on 4/20/2010.
//

#import "EAGLView.h"

#import "ES1Renderer.h"
#import "ES2Renderer.h"
#import "BLEUtility.h"

float lastx;
float lasty;
float lastz;

@implementation EAGLView

// You must implement this method
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

//The EAGL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder
{
    NSLog(@"entering initWithCoder");
    if ((self = [super initWithCoder:coder]))
    {		
		// Set scaling to account for Retina display	
		if ([self respondsToSelector:@selector(setContentScaleFactor:)])
		{
			self.contentScaleFactor = [[UIScreen mainScreen] scale];
		}
		
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;

        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];

		renderer = [[ES2Renderer alloc] init];
//		renderer = nil;

        if (!renderer)
        {
            renderer = [[ES1Renderer alloc] init];

            if (!renderer)
            {
                [self release];
                return nil;
            }
        }

    }

    self.m = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    self.nDevices = [[NSMutableArray alloc]init];
    self.m.delegate = self;
    NSLog(@"scan for devices");
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                             CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    [self.m scanForPeripheralsWithServices:nil options:options];
    return self;
}

- (void)dealloc
{
    [renderer release];

    [super dealloc];
}

/*
-(void) viewDidLoad
{
    NSLog(@"entering viewDidAppear");
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                             CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    [self.m scanForPeripheralsWithServices:nil options:options];
}
*/
 
-(void) viewWillDisappear:(BOOL)animated
{
    if(self.p.isConnected)
    {
        [self deconfigureDevice];
    }
}

#pragma mark -
#pragma mark UIView layout methods

- (void)drawView:(id)sender
{
    [renderer renderByRotatingAroundX:0 rotatingAroundY:0];
}

- (void)layoutSubviews
{	
	NSLog(@"Scale factor: %f", self.contentScaleFactor);
    [renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
    [self drawView:nil];
}

#pragma mark -
#pragma mark Touch-handling methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSMutableSet *currentTouches = [[[event touchesForView:self] mutableCopy] autorelease];
    [currentTouches minusSet:touches];
	
	// New touches are not yet included in the current touches for the view
	lastMovementPosition = [[touches anyObject] locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
	CGPoint currentMovementPosition = [[touches anyObject] locationInView:self];
	[renderer renderByRotatingAroundX:(lastMovementPosition.x - currentMovementPosition.x) rotatingAroundY:(lastMovementPosition.y - currentMovementPosition.y)];
	lastMovementPosition = currentMovementPosition;
    NSLog(@"x position = @%f", currentMovementPosition.x);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
	NSMutableSet *remainingTouches = [[[event touchesForView:self] mutableCopy] autorelease];
    [remainingTouches minusSet:touches];

	lastMovementPosition = [[remainingTouches anyObject] locationInView:self];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event 
{
	// Handle touches canceled the same as as a touches ended event
    [self touchesEnded:touches withEvent:event];
}



#pragma mark - CBCentralManager delegate

-(void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"centralManagerDidUpdateState with state: %d", central.state);
    if (central.state != CBCentralManagerStatePoweredOn) {
        if(central.state == CBCentralManagerStatePoweredOff) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"BLE not supported !" message:[NSString stringWithFormat:@"CoreBluetooth return state: %d",central.state] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    }
    else {
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber  numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
        [central scanForPeripheralsWithServices:nil options:options];
    }
}

// we actually need to check the UUID
-(int) hasPeripheral:(CBPeripheral*) p1
{
    if(!p1.UUID)
        return NSNotFound;
    
    CBUUID *p1UUID = [CBUUID UUIDWithCFUUID:p1.UUID];
    for(int i=0; i<self.nDevices.count; i++) {
        CBPeripheral *p = [self.nDevices objectAtIndex:i];
        CBUUID *pUUID = [CBUUID UUIDWithCFUUID:p.UUID];
        if([pUUID isEqual:p1UUID])
            return i;
    }
    return NSNotFound;
}


-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSLog(@"Found a BLE Device : %@",peripheral);
    
    /* iOS 6.0 bug workaround : connect to device before displaying UUID !
     The reason for this is that the CFUUID .UUID property of CBPeripheral
     here is null the first time an unkown (never connected before in any app)
     peripheral is connected. So therefore we connect to all peripherals we find.
     */
    
    peripheral.delegate = self;
    [central connectPeripheral:peripheral options:nil];
    
    int i = [self hasPeripheral:peripheral];
    if(i==NSNotFound) {
        [self.nDevices addObject:peripheral];
    } else {
        [self.nDevices replaceObjectAtIndex:i withObject:peripheral];
    }
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    // Match if we have this device from before
    int i = [self hasPeripheral:peripheral];
    if(i==NSNotFound) {
        [self.nDevices addObject:peripheral];
    } else {
        [self.nDevices replaceObjectAtIndex:i withObject:peripheral];
    }
    
    // let's just discover one single service
    CBUUID *su = [BLEUtility IntToCBUUID:ACC_SERV_UUID];
    NSArray *services    = [NSArray arrayWithObject:su];
    [peripheral discoverServices:services];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"didFailToConnectPeripheral: %@", peripheral.UUID);
    // [self finishScan];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"didDisconnectPeripheral for %@ error = %@",CFUUIDCreateString(nil, peripheral.UUID), error);
    int i = [self hasPeripheral: peripheral];
    if(i!=NSNotFound) {
        [self.nDevices removeObjectAtIndex:i];
    }
    //[self.m connectPeripheral:peripheral options:nil];
}


#pragma  mark - CBPeripheral delegate


-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSLog(@"entering didDiscoverServices for p = %@, error = %@", peripheral.name, error);
    
    // [self.m cancelPeripheralConnection:peripheral];
    for (CBService *s in peripheral.services) {
        UInt16 iuuid = [BLEUtility CBUUIDToInt:s.UUID];
        NSLog(@"Service found : %@, 0x%4x",s.UUID, iuuid);
        if([BLEUtility isUUID:s.UUID thisInt:ACC_SERV_UUID]) {
            [peripheral discoverCharacteristics:nil forService:s];
            NSLog(@"Found the accel service!!");
            self.p = peripheral;
            self.p.delegate = self;
        }
    }
    [self.m stopScan];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    NSLog(@"entering didDiscoverCharacteristicsForService: %@", service.UUID);
    
    if([[peripheral.name lowercaseString] hasPrefix:@"df1"] && [BLEUtility isUUID:service.UUID thisInt:ACC_SERV_UUID]) {
        // int i = [self hasPeripheral:peripheral];
        NSLog(@"found accelerometer conf characteristic");
        [self configureDevice];
        // here we subscribe to data
    }
}

-(void) peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didUpdateNotificationStateForCharacteristic %@ error = %@",characteristic,error);
}

-(void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didWriteValueForCharacteristic %@ error = %@",characteristic,error);
}

- (void) peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    int i = [self hasPeripheral:peripheral];
    NSLog(@"peripheralDidUpdateRSSI for [%d] %@ = %f error = %@",i, CFUUIDCreateString(nil, peripheral.UUID), [peripheral.RSSI floatValue], error);
    if(i!=NSNotFound) {
        // NSLog([NSString stringWithFormat:@"RSSI %.0fdBm:", [peripheral.RSSI floatValue]]);
        NSLog(@"RSSI = %f",[peripheral.RSSI floatValue]);
    }
}


-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"didUpdateValueForCharacteristic error: %@", error);
        return;
    }
    UInt16 cUUID = [BLEUtility CBUUIDToInt:characteristic.UUID];
    switch(cUUID)
    {
        case ACC_XYZ_DATA8_UUID:
        {
            char adata[3];
            [characteristic.value getBytes:&adata length:3];
            float x = ((float)adata[0])/64.0;
            float y = ((float)adata[1])/64.0;
            float z = ((float)adata[2])/64.0;
            x = (x+2.0)*48.0;
            y = (-y+2.0)*48.0;

            [renderer renderByRotatingAroundX:(lastx - x) rotatingAroundY:(lasty - y)];
            lastx = x;
            lasty = y;
            lastz = z;
            break;
        }
    }
}


-(void) configureDevice
{
    NSLog(@"subscribing from accelerometer service");
    CBUUID *sUUID = [BLEUtility IntToCBUUID:ACC_SERV_UUID];
    CBUUID *cUUID = [BLEUtility IntToCBUUID:ACC_ENABLE_UUID];
    uint8_t data = 0x01;
    // first enable accelermeter
    [BLEUtility writeCharacteristic:self.p sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
    cUUID = [BLEUtility IntToCBUUID:ACC_XYZ_DATA8_UUID];
    [BLEUtility setNotificationForCharacteristic:self.p sCBUUID:sUUID cCBUUID:cUUID enable:YES];
}


-(void) deconfigureDevice
{
    CBUUID *sUUID = [BLEUtility IntToCBUUID:ACC_SERV_UUID];
    CBUUID *cUUID = [BLEUtility IntToCBUUID:ACC_ENABLE_UUID];
    NSLog(@"disabling accelerometer service");
    uint8_t data = 0x00;
    [BLEUtility writeCharacteristic:self.p sCBUUID:sUUID cCBUUID:cUUID data:[NSData dataWithBytes:&data length:1]];
    cUUID = [BLEUtility IntToCBUUID:ACC_XYZ_DATA8_UUID];
    [BLEUtility setNotificationForCharacteristic:self.p sCBUUID:sUUID cCBUUID:cUUID enable:NO];
}


@end
