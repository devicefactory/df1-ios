//
//  DF1DevCell.m
//  MonBabyApp
//
//  Created by JB Kim on 6/8/13.
//  Copyright (c) 2013 JB Kim. All rights reserved.
//
#define DF_LEVEL 0

#import "DF1DevCell.h"
#import "DF1LibUtil.h"

@implementation DF1DevCell

@synthesize nameLabel;
@synthesize subLabel;
@synthesize detailLabel;
@synthesize deviceIcon;
@synthesize p;
@synthesize delegate;
@synthesize ledButton;

- (void) setupButton: (UIButton *) aButton withTitle: (NSString *) aTitle withOffset: (CGFloat) anOffset
{
    [aButton setTitle:aTitle forState:UIControlStateNormal];
    [aButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    aButton.frame = CGRectMake(anOffset, 35.0f, 0.0f, 0.0f);
    [aButton sizeToFit];
    aButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    DF_DBG(@"initWithStyle for DF1DevCell");
    self.accessoryType = UITableViewCellAccessoryNone; // UITableViewCellAccessoryDetailDisclosureButton
    // self.selectionStyle = UITableViewCellSelectionStyleNone;
    // [[self contentView] setBackgroundColor:[UIColor clearColor]];
    // [[self backgroundView] setBackgroundColor:[UIColor clearColor]];
    // [self setBackgroundColor:[UIColor clearColor]];
    
    // self.contentView.backgroundColor = [UIColor darkGrayColor];
    self.ledButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    // ledButton.tag = CustomCellActionTitle;
    [self setupButton:ledButton withTitle:@"led" withOffset:35.0f];

    // Initialization code
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.textAlignment = NSTextAlignmentLeft;
    self.nameLabel.font = [UIFont boldSystemFontOfSize:14];
    self.nameLabel.textColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.5 alpha:1.0];

    self.subLabel = [[UILabel alloc] init];
    self.subLabel.textAlignment = NSTextAlignmentLeft;
    self.subLabel.font = [UIFont boldSystemFontOfSize:8];
    self.subLabel.textColor = [UIColor grayColor];

    self.detailLabel = [[UILabel alloc] init];
    self.detailLabel.textAlignment = NSTextAlignmentLeft;
    self.detailLabel.font = [UIFont boldSystemFontOfSize:8];

    self.deviceIcon = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"oem-front1-icon.png"]];
    [self.deviceIcon setAutoresizingMask:UIViewAutoresizingNone];
    self.deviceIcon.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.subLabel];
    [self.contentView addSubview:self.detailLabel];
    [self.contentView addSubview:self.deviceIcon];
    [self.contentView addSubview:self.ledButton];

    return self;
}


-(void) layoutSubviews
{
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    // CGRect fr;

    self.deviceIcon.frame = CGRectMake(boundsX+11, 12, 60, 60);
    
    self.nameLabel.font = [UIFont boldSystemFontOfSize:18];
    self.nameLabel.frame = CGRectMake(boundsX+85, 15, 200, 30);

    self.subLabel.font = [UIFont boldSystemFontOfSize:12];
    self.subLabel.frame = CGRectMake(boundsX+85, 40, 200, 30);

    // fr = CGRectMake(contentRect.size.width-75, 10, 60, 60);
    // self.deviceIcon.frame = fr;

    DF_DBG(@"calling layoutSubview in DF1DevCell");
    // fr = CGRectMake(boundsX + contentRect.size.width - 90, 10, 100, 30);
    // self.serviceOnOffButton.frame = fr;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (IBAction) ledButton2Up:(UIButton*) sender
{
    uint8_t byte = 0x00;
    NSData *data = [NSData dataWithBytes:&byte length:1];
    // if([self.delegate respondsToSelector:@selector(flashLED)]) {
    [self.delegate flashLED:self.p withByte:data];
    // }
}

- (IBAction) ledButton2Dn:(UIButton*) sender
{
    uint8_t byte = 0x02;
    NSData *data = [NSData dataWithBytes:&byte length:1];
    // if([self.delegate respondsToSelector:@selector(flashLED)]) {
    [self.delegate flashLED:self.p withByte:data];
    // }
}

@end
