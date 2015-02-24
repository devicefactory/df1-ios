//
//  DF1DevCell.h
//
//  Created by JB Kim on 6/8/13.
//  Copyright (c) 2013 JB Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DF1Lib.h"

@protocol DF1DevCellDelegate
@optional
-(void) flashLED:(CBPeripheral*) p withByte:(NSData*) byte;
@end


@interface DF1DevCell : UITableViewCell

@property (nonatomic,assign) id<DF1DevCellDelegate> delegate;
@property (nonatomic,strong) IBOutlet UILabel *nameLabel;
@property (nonatomic,strong) IBOutlet UILabel *subLabel;
@property (nonatomic,strong) IBOutlet UILabel *detailLabel;
@property (nonatomic,strong) IBOutlet UIImageView *deviceIcon;
@property (nonatomic,assign) CBPeripheral *p;
@property (nonatomic,retain) UIButton *ledButton;
@property (nonatomic,retain) UIProgressView *signalBar;
@property (nonatomic,retain) UIView *barHolder;
@property (nonatomic,retain) NSNumber *isOAD;

- (IBAction)ledButtonUp:(UIButton*)sender;
- (IBAction)ledButtonDn:(UIButton*)sender;
- (void) updateSignalValue:(float) value;

@end
