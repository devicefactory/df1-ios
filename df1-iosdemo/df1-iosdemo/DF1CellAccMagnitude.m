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
    self.height = 150;

    // Initialization code
    self.magText = [[UILabel alloc] init];
    self.magText.textAlignment = NSTextAlignmentCenter;
    self.magText.font = [UIFont systemFontOfSize:36];
    self.magText.textColor = [UIColor blackColor];
    self.magText.backgroundColor = [UIColor clearColor];
    
    self.maxMagText = [[UILabel alloc] init];
    self.maxMagText.textAlignment = NSTextAlignmentRight;
    self.maxMagText.font = [UIFont systemFontOfSize:24];
    self.maxMagText.textColor = [UIColor blackColor];
    self.maxMagText.backgroundColor = [UIColor clearColor];
    
    self.avgMagText = [[UILabel alloc] init];
    self.avgMagText.textAlignment = NSTextAlignmentLeft;
    self.avgMagText.font = [UIFont systemFontOfSize:24];
    self.avgMagText.textColor = [UIColor blackColor];
    self.avgMagText.backgroundColor = [UIColor clearColor];
    
    self.magTitleText = [[UILabel alloc] init];
    self.magTitleText.textAlignment = NSTextAlignmentCenter;
    self.magTitleText.font = [UIFont systemFontOfSize:24];
    self.magTitleText.textColor = [UIColor blackColor];
    self.magTitleText.backgroundColor = [UIColor clearColor];
    self.magTitleText.text = @"Magnitude";
    
    self.maxMagTitleText = [[UILabel alloc] init];
    self.maxMagTitleText.textAlignment = NSTextAlignmentRight;
    self.maxMagTitleText.font = [UIFont systemFontOfSize:18];
    self.maxMagTitleText.textColor = [UIColor darkGrayColor];
    self.maxMagTitleText.backgroundColor = [UIColor clearColor];
    self.maxMagTitleText.text = @"max";
    
    self.avgMagTitleText = [[UILabel alloc] init];
    self.avgMagTitleText.textAlignment = NSTextAlignmentLeft;
    self.avgMagTitleText.font = [UIFont systemFontOfSize:18];
    self.avgMagTitleText.textColor = [UIColor darkGrayColor];
    self.avgMagTitleText.backgroundColor = [UIColor clearColor];
    self.avgMagTitleText.text = @"avg";


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
    
    self.magText.frame = CGRectMake(0, 50, width, 30);
    self.avgMagText.frame = CGRectMake(15, 110, width, 30);
    self.maxMagText.frame = CGRectMake(-15, 110, width, 30);
    self.avgMagTitleText.frame = CGRectMake(15, 80, width, 30);
    self.maxMagTitleText.frame = CGRectMake(-15, 80, width, 30);
    self.magTitleText.frame = CGRectMake(0, 15, width, 30);


}

@end
