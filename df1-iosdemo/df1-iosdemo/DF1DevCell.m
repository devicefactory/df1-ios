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

    // self.contentView.backgroundColor = [UIColor darkGrayColor];
    self.ledButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    // ledButton.tag = CustomCellActionTitle;
    [self setupButton:ledButton withTitle:@"led" withOffset:35.0f];

    // Initialization code
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.textAlignment = NSTextAlignmentLeft;
    self.nameLabel.font = [UIFont boldSystemFontOfSize:14];

    self.subLabel = [[UILabel alloc] init];
    self.subLabel.textAlignment = NSTextAlignmentLeft;
    self.subLabel.font = [UIFont boldSystemFontOfSize:8];

    self.detailLabel = [[UILabel alloc] init];
    self.detailLabel.textAlignment = NSTextAlignmentLeft;
    self.detailLabel.font = [UIFont boldSystemFontOfSize:8];

    self.deviceIcon = [[UIImageView alloc] init];
    [self.deviceIcon setAutoresizingMask:UIViewAutoresizingNone];
    self.deviceIcon.contentMode = UIViewContentModeScaleAspectFit;

    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.subLabel];
    [self.contentView addSubview:self.detailLabel];
    [self.contentView addSubview:self.ledButton];

    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGRect fr;

    // if (contentRect.size.width < WIDTH_CHECKER) {
    self.nameLabel.font = [UIFont boldSystemFontOfSize:17];
    fr = CGRectMake(boundsX + 10, 10, 300, 30);
    self.nameLabel.frame = fr;

    self.subLabel.font = [UIFont boldSystemFontOfSize:12];
    fr = CGRectMake(boundsX + 10, 30, 300, 30);
    self.subLabel.frame = fr;

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
