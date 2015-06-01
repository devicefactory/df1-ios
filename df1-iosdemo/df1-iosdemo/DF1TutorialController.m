//
//  DF1TutorialController.m
//  df1-iosdemo
//
//  Created by Nicholas Breeser on 5/31/15.
//  Copyright (c) 2015 JB Kim. All rights reserved.
//

#import "DF1TutorialController.h"
#define NUMBER_OF_PAGES 7
#define timeForPage(page) (NSInteger)(self.view.frame.size.width * (page - 1))
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface DF1TutorialController ()
@property (strong, nonatomic) UILabel *firstLabel;
@property (strong, nonatomic) UILabel *secondLabel;
@property (strong, nonatomic) UILabel *thirdLabel;
@property (strong, nonatomic) UILabel *colorTitleText;
@property (strong, nonatomic) UILabel *listsTitleText;
@property (strong, nonatomic) UILabel *iCloudTitleText;
@property (strong, nonatomic) UILabel *fourthLabel;
@property (strong, nonatomic) UILabel *fifthLabel;
@property (strong, nonatomic) UILabel *list2PageText;
@property (strong, nonatomic) UILabel *listPageText;



@property NSTimer *checkAnimTimer;
@property NSTimer *cloudAnimTimer;
@property int imgIndex;
@property int imgIndex2;
@property (strong, nonatomic) UIImageView *backgroundImage;

@end

@implementation DF1TutorialController

- (void)viewDidLoad {
}

@end
