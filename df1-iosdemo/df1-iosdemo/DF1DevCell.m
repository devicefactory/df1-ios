//
//  DF1DevCell.m
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

// INSERTS expands out the button image
#define CAPWIDTH    10.0f
#define INSETS      (UIEdgeInsets){10.0f, CAPWIDTH, 10.0f, CAPWIDTH}
#define BASEGREEN   [[UIImage imageNamed:@"green-out.png"] resizableImageWithCapInsets:INSETS]
#define PUSHGREEN   [[UIImage imageNamed:@"green-in.png"] resizableImageWithCapInsets:INSETS]
#define BASERED     [[UIImage imageNamed:@"red-out-dark.png"] resizableImageWithCapInsets:INSETS]
#define PUSHRED     [[UIImage imageNamed:@"red-in.png"] resizableImageWithCapInsets:INSETS]
#define BASEGREEN2  [UIImage imageNamed:@"green-out.png"]
#define PUSHGREEN2  [UIImage imageNamed:@"green-in.png"]
#define BASERED2    [UIImage imageNamed:@"red-out-dark.png"]
#define PUSHRED2    [UIImage imageNamed:@"red-in.png"]
#define BASEBLACK     [[UIImage imageNamed:@"blackButton@2x.png"] resizableImageWithCapInsets:INSETS]
#define PUSHBLACK     [[UIImage imageNamed:@"blackButtonHighlight@2x.png"] resizableImageWithCapInsets:INSETS]
#define BASEWHITE     [[UIImage imageNamed:@"whiteButton@2x.png"] resizableImageWithCapInsets:INSETS]
#define PUSHWHITE     [[UIImage imageNamed:@"whiteButtonHighlight@2x.png"] resizableImageWithCapInsets:INSETS]

-(void) _imageButton
{
    // self.ledButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.ledButton = [UIButton buttonWithType:UIButtonTypeCustom];
    // self.ledButton.frame = CGRectMake(0.0f, 0.0f, 70.0f, 50.0f);
    self.ledButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.ledButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self.ledButton setBackgroundImage:BASEWHITE forState:UIControlStateNormal];
    [self.ledButton setBackgroundImage:PUSHWHITE forState:UIControlStateHighlighted];
    // [self.ledButton setBackgroundColor:[UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:0.2f]];
    [self.ledButton setTitle:@"led" forState:UIControlStateNormal];
    [self.ledButton setTitle:@"on!" forState:UIControlStateHighlighted];
    self.ledButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    [self.ledButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.ledButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [self.ledButton sizeToFit];
    self.ledButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    
    [self.ledButton addTarget:self action:@selector(ledButtonDn:)
             forControlEvents:UIControlEventTouchDown];
    [self.ledButton addTarget:self action:@selector(ledButtonUp:)
             forControlEvents:UIControlEventTouchUpInside];
    
}

-(void) _genericButton
{
    self.ledButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    // self.ledButton.frame = CGRectMake(0.0f, 0.0f, 70.0f, 45.0f);
    self.ledButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.ledButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self.ledButton setBackgroundColor:[UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:0.2f]];
    [self.ledButton setTitle:@"led" forState:UIControlStateNormal];
    [self.ledButton setTitle:@"on!" forState:UIControlStateHighlighted];
    self.ledButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    [self.ledButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.ledButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    // [self.ledButton.titleLabel setFont:[UIFont fontWithName:@"Zapfino" size:20.0]];
    // [self.ledButton.titleLabel setTextColor:[UIColor blueColor]];
    // [self.ledButton layoutIfNeeded];
    [self.ledButton sizeToFit];
    // self.ledButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    
    [self.ledButton addTarget:self action:@selector(ledButtonDn:) forControlEvents:UIControlEventTouchDown];
    [self.ledButton addTarget:self action:@selector(ledButtonUp:) forControlEvents:UIControlEventTouchUpInside];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    DF_DBG(@"initWithStyle for DF1DevCell");
    self.accessoryType = UITableViewCellAccessoryNone; // UITableViewCellAccessoryDetailDisclosureButton

    [self _imageButton];
    // [self _genericButton];

    self.isOAD = [NSNumber numberWithBool:false];
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
    
    self.signalBar = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, 85, 20)];
    self.signalBar.progress = 0.0f;
    // self.signalBar.transform = CGAffineTransformRotate(self.signalBar.transform, -M_PI/2 .0);
    // self.accBarX.transform = CGAffineTransformRotate(self.accBarX.transform, 0.0);
    self.signalBar.progressTintColor = [UIColor redColor];
    self.barHolder = [[UIView alloc] init];
    [self.barHolder addSubview:self.signalBar];

    self.deviceIcon = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"oem-front1-icon.png"]];
    [self.deviceIcon setAutoresizingMask:UIViewAutoresizingNone];
    self.deviceIcon.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.subLabel];
    [self.contentView addSubview:self.detailLabel];
    [self.contentView addSubview:self.deviceIcon];
    [self.contentView addSubview:self.ledButton];
    [self.contentView addSubview:self.barHolder];

    return self;
}


-(void) layoutSubviews
{
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;

    self.deviceIcon.frame = CGRectMake(boundsX+11, 12, 60, 60);
    
    self.nameLabel.font = [UIFont boldSystemFontOfSize:18];
    self.nameLabel.frame = CGRectMake(boundsX+85, 15, 200, 30);

    self.subLabel.font = [UIFont boldSystemFontOfSize:12];
    self.subLabel.frame = CGRectMake(boundsX+85, 35, 100, 30);
    self.barHolder.frame = CGRectMake(boundsX+85, 60, 100, 30);
    
    self.ledButton.frame = CGRectMake(contentRect.size.width-100, 25, 80, 35);

    DF_DBG(@"calling layoutSubview in DF1DevCell");
    // fr = CGRectMake(boundsX + contentRect.size.width - 90, 10, 100, 30);
    // self.serviceOnOffButton.frame = fr;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (IBAction) ledButtonUp:(UIButton*) sender
{
    uint8_t byte = 0x00;
    NSData *data = [NSData dataWithBytes:&byte length:1];
    // if(self.delegate && [self.delegate respondsToSelector:@selector(flashLED:withByte:)]) {
        [self.delegate flashLED:self.p withByte:data];
    // }
}

- (IBAction) ledButtonDn:(UIButton*) sender
{
    uint8_t byte = 0x01;
    NSData *data = [NSData dataWithBytes:&byte length:1];
    // if(self.delegate && [self.delegate respondsToSelector:@selector(flashLED:withByte:)]) {
        [self.delegate flashLED:self.p withByte:data];
    //}
}

-(void) updateSignalValue:(float)value
{
    self.subLabel.text = [NSString stringWithFormat:@"RSSI  %.0f dBm", value];
    float valuetrunc = (value < -100.0) ? -100.0 :
                       (value > -30.0 ) ? -30.0 : value;
    float strength = exp((30 + valuetrunc) / 50.0);  // in R: plot( exp( (20+seq(-20, -100))/40 ), type='b')
    self.signalBar.progress = strength;
    self.signalBar.progressTintColor = [UIColor colorWithRed:(1.0f - strength) green:(strength) blue:0.05f alpha:1.0f];
}

@end
