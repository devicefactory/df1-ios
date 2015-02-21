#define DF_LEVEL 0

#define PAD_LEFT 50
#define PAD_TOP 200

#import "DF1Lib.h"
#import "DF1DevListController.h"
#import "DF1DevCell.h"
#import "DF1DevDetailController.h"
#import "Utility.h"
#import "DF1OADController.h"

@interface DF1OADController ()
{
    bool _alreadyConnected;
}
@end

@implementation DF1OADController



-(id) initWithPeripheralUUID:(NSString*) uuid
{
    self = [super init];
    if (self)
    {
        self.df = [[DF1 alloc] initWithDelegate:self];
        self.title = @"Firmware Update";
        self.uuid = uuid;
        _alreadyConnected = false;
        [NSTimer scheduledTimerWithTimeInterval:1.0f
            target:self selector:@selector(triggerScan) userInfo:nil repeats:NO];
        // [self triggerScan];
    }
    return self;
}

-(id) initWithDF:(DF1*) df
{
    self = [super init];
    if (self)
    {
        self.df = df;
        self.df.delegate = self;
        self.title = @"Firmware Update";
        self.uuid = [self.df.p.identifier UUIDString];
        _alreadyConnected = true;
    }
    return self;
}

-(void) loadView
{
    [super loadView];
    // [super layoutSubviews];
    // this is akin to what [super loadView] does
    // CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    // UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    // contentView.backgroundColor = [UIColor blackColor];
    // self.view = contentView;
    // levelView = [[LevelView alloc] initWithFrame:applicationFrame viewController:self];
    // [self.view addSubview:levelView];
    self.view.backgroundColor = [UIColor whiteColor];
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    DF_DBG(@"view loaded DF1OADController");
    // self.navigationItem.title = @"DF1 OAD";
}

-(void) viewDidAppear:(BOOL)animated
{
    DF_DBG(@"entering viewDidAppear");
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    
    self.oadLabel = [[UILabel alloc] init];
    self.oadLabel.font = [UIFont boldSystemFontOfSize:11];
    self.oadLabel.textAlignment = NSTextAlignmentLeft;
    self.oadLabel.text = [[NSString alloc] initWithFormat:@"OAD for: %@", self.uuid];
    
    self.connButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.connButton.frame = CGRectMake(0.0f, 0.0f, 60.0f, 30.0f);
    self.connButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.connButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self.connButton setTitle:@"connect" forState:UIControlStateNormal];
    self.connButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    [self.connButton sizeToFit];
    self.connButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.connButton addTarget:self action:@selector(triggerScan) forControlEvents:UIControlEventTouchDown];
    
    self.oadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.oadButton.frame = CGRectMake(0.0f, 0.0f, 60.0f, 30.0f);
    self.oadButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.oadButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self.oadButton setTitle:@"select firmware" forState:UIControlStateNormal];
    self.oadButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    [self.oadButton sizeToFit];
    self.oadButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.oadButton addTarget:self action:@selector(oadButtonSelected:) forControlEvents:UIControlEventTouchDown];
    [self.oadButton setEnabled:NO];
    
    [self.view addSubview:self.oadLabel];
    [self.view addSubview:self.oadButton];
    [self.view addSubview:self.connButton];
    
    self.oadLabel.frame   = CGRectMake(PAD_LEFT,  PAD_TOP,     300, 45);
    self.oadButton.frame  = CGRectMake(PAD_LEFT,  PAD_TOP+50,  300, 45);
    self.connButton.frame = CGRectMake(PAD_LEFT,  PAD_TOP+200, 300, 45);
    
    if(_alreadyConnected)
        [self showFirmwareOption];
}

-(void) viewWillAppear:(BOOL)animated
{
    // if(self.df==nil) [self initializeMembers:nil];
}

// so that the timer doesn't hang around
-(void) viewWillDisappear:(BOOL)animated
{

}
    
-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) clearScan
{
    [self.df stopScan:true]; // clear the internal device list
    [self finishScan];
}

- (void) triggerScan
{
    DF_DBG(@"triggerScan: scanning for peripherals");
    self.title = @"Scanning...";
    [self.df scan:30];
    [NSTimer scheduledTimerWithTimeInterval:20.0f
                                     target:self selector:@selector(timeoutScan:) userInfo:nil repeats:NO];
}

- (void) finishScan
{
    DF_DBG(@"finishScan");
    self.title = @"Found Device";
}

// so that we avoid scanning indefinitely
- (void) timeoutScan: (NSTimer *) timer
{
    self.title = @"Select Device";
    [self.df stopScan:false]; // don't clear the internal device list
    [self finishScan];
    // UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Scan Timeout" message:@"Stopped scanning"
    //                        delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    // [alert show];
    // [alert release];
}


-(bool) didScan:(NSArray*) devices
{
    // simply set the pointer to the internal one : is this dangerous?
    for(CBPeripheral *p in devices) {
      if([[p.identifier UUIDString] isEqual:self.uuid]) {
        DF_DBG(@"target UUID %@ found!", self.uuid);
        self.oadLabel.text = @"desired peripheral found!";
        [self.df connect:p];
        return false;
      }
    }
    return true;
}

-(void) didStopScan
{
    DF_DBG(@"stopped scanning");    
}

-(void) showFirmwareOption
{
    [self.oadButton setEnabled:YES];
    [self.oadButton setTitle:@"Select file" forState:UIControlStateNormal];
}

-(void) didConnect:(CBPeripheral *) peripheral
{
    DF_DBG(@"did connect peripheral: %@", peripheral.name);
    self.oadLabel.text = @"connected to peripheral";
    for (CBService *service in peripheral.services)
    {
      NSString *cname = [DF1LibUtil CBUUIDToString:service.UUID];
      DF_DBG(@"contains service: %@",cname);
      if ([service.UUID isEqual:[CBUUID UUIDWithString:@"0xF000FFC0-0451-4000-B000-000000000000"]]) {
        [self showFirmwareOption];
        [self.oadButton setTitle:@"Select file" forState:UIControlStateNormal];
        return;
      }
    }

    if([[peripheral.name lowercaseString] hasPrefix:@"df1"])
    {
      
    }
}



#pragma mark - Button functions

// - (IBAction)button1Selected:(id)sender
// {
//     NSLog(@"Opening device selector");
//     [self presentViewController:self.dSVC animated:YES completion:nil];
//     [self dismissViewControllerAnimated:YES completion:nil];
// }

- (IBAction) oadButtonSelected:(id)sender
{
    BLEDevice *dev = [[BLEDevice alloc]init];
    dev.p = self.df.p;
    dev.manager = self.df.m;
    self.oadProfile = [[BLETIOADProfile alloc]initWithDevice:dev];
    self.oadProfile.progressView = [[BLETIOADProgressViewController alloc]init];
    [self.oadProfile makeConfigurationForProfile];
    self.oadProfile.navCtrl = self.navigationController;
    [self.oadProfile configureProfile]; // this gets the current img type and version
    self.oadProfile.view = self.view;
    [self.oadProfile selectImagePressed:self];
}


-(void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self.oadProfile deviceDisconnected:peripheral];
}

#pragma mark - CBPeripheralDelegate Callbacks

-(void) receivedValue:(CBPeripheral*) peripheral forCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    DF_DBG(@"receivedValue forCharacteristic!");
    [self.oadProfile didUpdateValueForProfile:characteristic];
}


#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    DF_DBG(@"DF1OADController calling navigationController:willShowViewController:animated");
    if ([viewController isEqual:self]) {
        [viewController viewWillAppear:animated];
    } else if ([viewController conformsToProtocol:@protocol(UINavigationControllerDelegate)]){
        // Set the navigation controller delegate to the passed-in view controller and call the UINavigationViewControllerDelegate method on the new delegate.
        [navigationController setDelegate:(id<UINavigationControllerDelegate>)viewController];
        
        if([viewController isMemberOfClass:[DF1DevListController class]])
        {
            [self.df unsubscribeBatt];
            [self.df unsubscribeXYZ8];
            [self.df unsubscribeXYZ14]; // just in case
            [self.df unsubscribeTap];
            DF1DevListController *vc = (DF1DevListController*) viewController;
            vc.df = self.df;
            vc.df.delegate = vc;
        }
        [[navigationController delegate] navigationController:navigationController willShowViewController:viewController animated:YES];
    }
}


@end
