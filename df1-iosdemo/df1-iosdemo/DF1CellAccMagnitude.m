//
//  DF1CellGMagnitude.m
//  
//
//  Created by Nicholas Breeser on 3/14/15.
//
//

#import "DF1CellAccMagnitude.h"

@implementation DF1CellAccMagnitude


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
  parentController:(DF1DevDetailController*) parent
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(!self) return self;
    //self.parent = parent;
    self.height = 100;

    // Initialization code
    self.titleText = [[UILabel alloc] init];
    self.titleText.textAlignment = NSTextAlignmentCenter;
    self.titleText.font = [UIFont fontWithName:@"Avenir Next" size:15];
    self.titleText.textColor = [UIColor DFBlack];
    self.titleText.backgroundColor = [UIColor clearColor];
    self.titleText.text = @"Acceleration Magnitude";
    
    self.magText = [[UILabel alloc] init];
    self.magText.textAlignment = NSTextAlignmentCenter;
    self.magText.font = [UIFont systemFontOfSize:20];
    self.magText.textColor = [UIColor darkGrayColor];
    self.magText.backgroundColor = [UIColor clearColor];
    
    self.maxMagText = [[UILabel alloc] init];
    self.maxMagText.textAlignment = NSTextAlignmentRight;
    self.maxMagText.font = [UIFont systemFontOfSize:20];
    self.maxMagText.textColor = [UIColor darkGrayColor];
    self.maxMagText.backgroundColor = [UIColor clearColor];
    
    self.avgMagText = [[UILabel alloc] init];
    self.avgMagText.textAlignment = NSTextAlignmentLeft;
    self.avgMagText.font = [UIFont systemFontOfSize:20];
    self.avgMagText.textColor = [UIColor darkGrayColor];
    self.avgMagText.backgroundColor = [UIColor clearColor];
    
    self.magTitleText = [[UILabel alloc] init];
    self.magTitleText.textAlignment = NSTextAlignmentCenter;
    self.magTitleText.font = [UIFont systemFontOfSize:12];
    self.magTitleText.textColor = [UIColor DFBlack];
    self.magTitleText.backgroundColor = [UIColor clearColor];
    self.magTitleText.text = @"Current";
    
    self.maxMagTitleText = [[UILabel alloc] init];
    self.maxMagTitleText.textAlignment = NSTextAlignmentRight;
    self.maxMagTitleText.font = [UIFont systemFontOfSize:12];
    self.maxMagTitleText.textColor = [UIColor DFBlack];
    self.maxMagTitleText.backgroundColor = [UIColor clearColor];
    self.maxMagTitleText.text = @"Max";
    
    self.avgMagTitleText = [[UILabel alloc] init];
    self.avgMagTitleText.textAlignment = NSTextAlignmentLeft;
    self.avgMagTitleText.font = [UIFont systemFontOfSize:12];
    self.avgMagTitleText.textColor = [UIColor DFBlack];
    self.avgMagTitleText.backgroundColor = [UIColor clearColor];
    self.avgMagTitleText.text = @"Average";

    [self.contentView addSubview:self.titleText];
    [self.contentView addSubview:self.magText];
    [self.contentView addSubview:self.maxMagText];
    [self.contentView addSubview:self.avgMagText];
    [self.contentView addSubview:self.maxMagTitleText];
    [self.contentView addSubview:self.avgMagTitleText];
    [self.contentView addSubview:self.magTitleText];

    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    //CGFloat boundsX = self.contentView.bounds.origin.x;
    CGFloat width = self.contentView.bounds.size.width;
    self.titleText.frame = CGRectMake(0, 5, width, 30);
    self.magText.frame = CGRectMake(0, 60, width, 30);
    self.avgMagText.frame = CGRectMake(30, 60, width, 30);
    self.maxMagText.frame = CGRectMake(-30, 60, width, 30);
    self.avgMagTitleText.frame = CGRectMake(30, 40, width, 30);
    self.maxMagTitleText.frame = CGRectMake(-30, 40, width, 30);
    self.magTitleText.frame = CGRectMake(0, 40, width, 30);


}

@end
