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
    self.magText.textAlignment = NSTextAlignmentRight;
    self.magText.font = [UIFont systemFontOfSize:36];
    self.magText.textColor = [UIColor blackColor];
    self.magText.backgroundColor = [UIColor clearColor];
    
    self.maxMagText = [[UILabel alloc] init];
    self.maxMagText.textAlignment = NSTextAlignmentRight;
    self.maxMagText.font = [UIFont systemFontOfSize:24];
    self.maxMagText.textColor = [UIColor blackColor];
    self.maxMagText.backgroundColor = [UIColor clearColor];
    
    self.avgMagText = [[UILabel alloc] init];
    self.avgMagText.textAlignment = NSTextAlignmentRight;
    self.avgMagText.font = [UIFont systemFontOfSize:24];
    self.avgMagText.textColor = [UIColor blackColor];
    self.avgMagText.backgroundColor = [UIColor clearColor];
    
    self.magTitleText = [[UILabel alloc] init];
    self.magTitleText.textAlignment = NSTextAlignmentRight;
    self.magTitleText.font = [UIFont systemFontOfSize:24];
    self.magTitleText.textColor = [UIColor blackColor];
    self.magTitleText.backgroundColor = [UIColor clearColor];
    self.magTitleText.text = @"Magnitude";


    [self.contentView addSubview:self.magText];
    [self.contentView addSubview:self.maxMagText];
    [self.contentView addSubview:self.avgMagText];
    [self.contentView addSubview:self.magTitleText];

    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat boundsX = self.contentView.bounds.origin.x;
    CGFloat width = self.contentView.bounds.size.width;
    
    self.magText.frame = CGRectMake(boundsX + 5, 50, width-50, 30);
    self.avgMagText.frame = CGRectMake(boundsX -100, 80, width-100, 30);
    self.maxMagText.frame = CGRectMake(boundsX + 5, 80, width, 30);
    self.magTitleText.frame = CGRectMake(boundsX/2, 15, width, 30);


}

@end
