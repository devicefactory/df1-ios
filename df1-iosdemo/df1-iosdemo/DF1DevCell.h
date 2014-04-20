//
//  DF1DevCell.h
//  MonBabyApp
//
//  Created by JB Kim on 6/8/13.
//  Copyright (c) 2013 JB Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol DF1DevCellDelegate

@optional
-(void) flashLED:(CBPeripheral*) p withByte:(NSData*) byte;

@end

@interface DF1DevCell : UITableViewCell

// IBOutlet markers are not necessary on manual interface build, but just in case
@property (nonatomic,strong) IBOutlet UILabel *nameLabel;
@property (nonatomic,strong) IBOutlet UILabel *subLabel;
@property (nonatomic,strong) IBOutlet UILabel *detailLabel;
@property (nonatomic,strong) IBOutlet UIImageView *deviceIcon;
@property (nonatomic,assign) id<DF1DevCellDelegate> delegate;
@property (nonatomic,assign) CBPeripheral *p;
@property (nonatomic,weak) IBOutlet UIButton *ledButton;

- (IBAction)ledButton2Up:(UIButton*)sender;
- (IBAction)ledButton2Dn:(UIButton*)sender;

@end
