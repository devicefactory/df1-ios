//
//  DF1CellGMagnitude.m
//  
//
//  Created by Nicholas Breeser on 3/14/15.
//
//

#import "DF1CellTop10.h"

@implementation DF1CellTop10


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
    self.titleText.text = @"Top 10 Peaks";
    
    self.top10Text = [[UILabel alloc] init];
    self.top10Text.textAlignment = NSTextAlignmentCenter;
    self.top10Text.font = [UIFont systemFontOfSize:20];
    self.top10Text.textColor = [UIColor darkGrayColor];
    self.top10Text.backgroundColor = [UIColor clearColor];
    

    [self.contentView addSubview:self.titleText];
    [self.contentView addSubview:self.top10Text];


    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    //CGFloat boundsX = self.contentView.bounds.origin.x;
    CGFloat width = self.contentView.bounds.size.width;
    self.titleText.frame = CGRectMake(0, 5, width, 30);
    self.top10Text.frame = CGRectMake(0, 60, width, 30);


}

@end
