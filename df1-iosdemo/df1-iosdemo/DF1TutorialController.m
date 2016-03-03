//
//  DF1TutorialController.m
//  df1-iosdemo
//
//  Created by Nicholas Breeser on 5/31/15.
//  Copyright (c) 2015 JB Kim. All rights reserved.
//

#import "DF1TutorialController.h"
#define NUMBER_OF_PAGES 6
#define timeForPage(page) (NSInteger)(self.view.frame.size.width * (page - 1))
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface DF1TutorialController ()
@property (strong, nonatomic) UIPageControl *pageCtrl;

@property (strong, nonatomic) UILabel *label_1_1;
@property (strong, nonatomic) UILabel *label_1_2;
@property (strong, nonatomic) UILabel *label_2_1;
@property (strong, nonatomic) UILabel *label_3_1;
@property (strong, nonatomic) UILabel *label_4_1;
@property (strong, nonatomic) UILabel *label_4_2;
@property (strong, nonatomic) UILabel *label_5_1;
@property (strong, nonatomic) UILabel *label_6_1;



@property (strong, nonatomic) UIImageView *DFLogo;
@property (strong, nonatomic) UIImageView *DF1Img;
@property (strong, nonatomic) UIImageView *DF1PulseAnim;
@property (strong, nonatomic) UIImageView *DF1dataImg;
@property (strong, nonatomic) UIImageView *DF1codeImg;

@property (strong, nonatomic) UIImageView *DF1BuyImg;
@property (strong, nonatomic) UIImageView *DF1GithubImg;
@property (strong, nonatomic) UIImageView *DF1DoneImg;


@property NSTimer *checkAnimTimer;
@property NSTimer *cloudAnimTimer;
@property int imgIndex;
@property int imgIndex2;
@property (strong, nonatomic) UIImageView *backgroundImage;

@end

@implementation DF1TutorialController

-(id)init
{
    if ((self = [super init])) {
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.animator = [IFTTTAnimator new];
    self.scrollView.contentSize = CGSizeMake(NUMBER_OF_PAGES * CGRectGetWidth(self.view.frame),
                                             CGRectGetHeight(self.view.frame));
    self.navigationController.navigationBarHidden = YES;
    self.scrollView.backgroundColor = [UIColor DFBarColor];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.bounces = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self placeViews];
    [self configureAnimation];
    self.delegate = self;
    self.scrollView.delegate = self;


}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)placeViews
{
    self.pageCtrl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.scrollView.frame.size.height-60, self.scrollView.frame.size.width, 20)];
    self.pageCtrl.currentPage = 0;
    self.pageCtrl.numberOfPages = NUMBER_OF_PAGES;
    //self.pageCtrl.frame = CGRectOffset(self.pageCtrl.frame, timeForPage(1), -100);
    [self.view addSubview:self.pageCtrl];
    
    /////////////       1         ///////////////
    self.label_1_1 = [[UILabel alloc] init];
    self.label_1_1.text = @"welcome to";
    self.label_1_1.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:25.0f];
    [self.label_1_1 sizeToFit];
    self.label_1_1.center = self.view.center;
    self.label_1_1.frame = CGRectOffset(self.label_1_1.frame, timeForPage(1), -160);
    self.label_1_1.textColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.label_1_1];
    
    self.DFLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DFLogoRed.png"]];
    self.DFLogo.contentMode = UIViewContentModeScaleAspectFit;
    //[self.DFLogo sizeToFit];
    self.DFLogo.center = self.view.center;
    self.DFLogo.frame = CGRectOffset(self.DFLogo.frame, timeForPage(1), 0);
    [self.scrollView addSubview:self.DFLogo];
    
    self.label_1_2 = [[UILabel alloc] init];
    self.label_1_2.text = @"Device Factory";
    self.label_1_2.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:25.0f];
    self.label_1_2.textColor = [UIColor whiteColor];
    [self.label_1_2 sizeToFit];
    self.label_1_2.center = self.view.center;
    self.label_1_2.frame = CGRectOffset(self.label_1_2.frame, timeForPage(1), 160);
    [self.scrollView addSubview:self.label_1_2];
    
    
    
    /////////////       2         ///////////////
    self.label_2_1 = [[UILabel alloc] init];
    self.label_2_1.text = @"to use this app,\nyou will need a DF1";
    self.label_2_1.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:25.0f];
    self.label_2_1.numberOfLines = 0;
    self.label_2_1.textAlignment = NSTextAlignmentCenter;
    [self.label_2_1 sizeToFit];
    self.label_2_1.center = self.view.center;
    self.label_2_1.frame = CGRectOffset(self.label_2_1.frame, timeForPage(2), -160);
    self.label_2_1.textColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.label_2_1];
    
    self.DF1Img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"DF1Red.png"]];
    //self.DF1Img.contentMode = UIViewContentModeScaleAspectFit;
    [self.DFLogo sizeToFit];
    self.DF1Img.center = self.view.center;
    self.DF1Img.frame = CGRectOffset(self.DF1Img.frame, timeForPage(2), 0);
    [self.scrollView addSubview:self.DF1Img];
    
    self.DF1BuyImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BuyNowRed.png"]];
    self.DF1BuyImg.center = self.view.center;
    
    UIButton *buyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //[doneBtn setTitle:@"done" forState:UIControlStateNormal];
    self.DF1BuyImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BuyNowRed.png"]];
    self.DF1BuyImg.center = self.view.center;
    
    [buyBtn sizeToFit];
    buyBtn.center = self.view.center;
    buyBtn.frame = CGRectOffset(self.DF1BuyImg.frame, timeForPage(2), 150);
    [buyBtn setTintColor:[UIColor DFBlue]];
    [buyBtn setTitleColor:[UIColor DFBlue] forState:UIControlStateNormal];
    [buyBtn addTarget:self action:@selector(buyNowBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [buyBtn setBackgroundImage:[UIImage imageNamed:@"BuyNowRed.png"] forState:UIControlStateNormal];
    [self.scrollView addSubview:buyBtn];
    
    
    
    /////////////       3         ///////////////
    self.label_3_1 = [[UILabel alloc] init];
    self.label_3_1.text = @"the DF1 uses bluetooth LE\nto connect to an iPhone";
    self.label_3_1.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:25.0f];
    self.label_3_1.numberOfLines = 0;
    self.label_3_1.textAlignment = NSTextAlignmentCenter;
    [self.label_3_1 sizeToFit];
    self.label_3_1.center = self.view.center;
    self.label_3_1.frame = CGRectOffset(self.label_3_1.frame, timeForPage(3), -160);
    self.label_3_1.textColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.label_3_1];
    
    
    /////////////       4         ///////////////
    self.label_4_1 = [[UILabel alloc] init];
    self.label_4_1.text = @"what you do with the data\ncollected is completely\ncustomizeable";
    self.label_4_1.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:25.0f];
    self.label_4_1.numberOfLines = 0;
    self.label_4_1.textAlignment = NSTextAlignmentCenter;
    [self.label_4_1 sizeToFit];
    self.label_4_1.center = self.view.center;
    self.label_4_1.frame = CGRectOffset(self.label_4_1.frame, timeForPage(4), -160);
    self.label_4_1.textColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.label_4_1];
    
    self.DF1dataImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"graphRed.png"]];
    self.DF1dataImg.contentMode = UIViewContentModeScaleAspectFit;
    //[self.DFLogo sizeToFit];
    self.DF1dataImg.center = self.view.center;
    self.DF1dataImg.frame = CGRectOffset(self.DF1dataImg.frame, timeForPage(4), 0);
    [self.scrollView addSubview:self.DF1dataImg];
    
    self.label_4_2 = [[UILabel alloc] init];
    self.label_4_2.text = @"you can even export it as\na raw csv for use in Excel";
    self.label_4_2.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:25.0f];
    self.label_4_2.numberOfLines = 0;
    self.label_4_2.textAlignment = NSTextAlignmentCenter;
    [self.label_4_2 sizeToFit];
    self.label_4_2.center = self.view.center;
    self.label_4_2.frame = CGRectOffset(self.label_4_2.frame, timeForPage(4), 160);
    self.label_4_2.textColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.label_4_2];
    
    
    
    /////////////       5         ///////////////
    self.label_5_1 = [[UILabel alloc] init];
    self.label_5_1.text = @"the DF1 is open source,\nincluding this app";
    self.label_5_1.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:25.0f];
    self.label_5_1.numberOfLines = 0;
    self.label_5_1.textAlignment = NSTextAlignmentCenter;
    [self.label_5_1 sizeToFit];
    self.label_5_1.center = self.view.center;
    self.label_5_1.frame = CGRectOffset(self.label_5_1.frame, timeForPage(5), -160);
    self.label_5_1.textColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.label_5_1];
    
    self.DF1codeImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"codeTut.png"]];
    self.DF1codeImg.contentMode = UIViewContentModeScaleAspectFit;
    //[self.DFLogo sizeToFit];
    self.DF1codeImg.center = self.view.center;
    self.DF1codeImg.frame = CGRectOffset(self.DF1codeImg.frame, timeForPage(5), 0);
    [self.scrollView addSubview:self.DF1codeImg];
    
    UIButton *gitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //[doneBtn setTitle:@"done" forState:UIControlStateNormal];
    self.DF1GithubImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"VisitGithubBtn.png"]];
    self.DF1GithubImg.center = self.view.center;
    
    [gitBtn sizeToFit];
    gitBtn.center = self.view.center;
    gitBtn.frame = CGRectOffset(self.DF1GithubImg.frame, timeForPage(5), 150);
    [gitBtn setTintColor:[UIColor DFBlue]];
    [gitBtn setTitleColor:[UIColor DFBlue] forState:UIControlStateNormal];
    [gitBtn addTarget:self action:@selector(openGithub) forControlEvents:UIControlEventTouchUpInside];
    [gitBtn setBackgroundImage:[UIImage imageNamed:@"VisitGithubBtn.png"] forState:UIControlStateNormal];
    [self.scrollView addSubview:gitBtn];
    
    /////////////       6         ///////////////
    self.label_6_1 = [[UILabel alloc] init];
    self.label_6_1.text = @"the DF1 will continue to gain\nfeatures and grow with\ncommunity support";
    self.label_6_1.numberOfLines = 0;
    self.label_6_1.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:25.0f];
    self.label_6_1.textColor = [UIColor whiteColor];
    [self.label_6_1 sizeToFit];
    self.label_6_1.center = self.view.center;
    self.label_6_1.frame = CGRectOffset(self.label_6_1.frame, timeForPage(6), -50);
    self.label_6_1.textAlignment = NSTextAlignmentCenter;
    [self.scrollView addSubview:self.label_6_1];

    
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //[doneBtn setTitle:@"done" forState:UIControlStateNormal];
    self.DF1DoneImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"doneBtn.png"]];
    self.DF1DoneImg.center = self.view.center;

    [doneBtn sizeToFit];
    doneBtn.center = self.view.center;
    doneBtn.frame = CGRectOffset(self.DF1DoneImg.frame, timeForPage(6), 50);
    [doneBtn setTintColor:[UIColor DFBlue]];
    [doneBtn setTitleColor:[UIColor DFBlue] forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(doneWithTutorial) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setBackgroundImage:[UIImage imageNamed:@"doneBtn.png"] forState:UIControlStateNormal];
    [self.scrollView addSubview:doneBtn];

}

- (void)configureAnimation
{
    IFTTTFrameAnimation *DF1anim = [IFTTTFrameAnimation animationWithView:self.DF1Img];
    [DF1anim addKeyFrames:@[[IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(2) andFrame:self.DF1Img.frame],
                            [IFTTTAnimationKeyFrame keyFrameWithTime:timeForPage(3) andFrame:CGRectOffset(self.DF1Img.frame, timeForPage(2), 0)],
                            ]];
    [self.animator addAnimation:DF1anim];
    NSLog(@"hiiii");
}

-(void)doneWithTutorial{
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:true];
    self.navigationController.navigationBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    NSLog(@"DONE WITH TUT");
}

- (IBAction)changePage:(id)sender {
    CGFloat x = self.pageCtrl.currentPage * self.scrollView.frame.size.width;
    [self.scrollView setContentOffset:CGPointMake(x, 0) animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.isDragging || scrollView.isDecelerating){
        self.pageCtrl.currentPage = lround(self.scrollView.contentOffset.x / (self.scrollView.contentSize.width / self.pageCtrl.numberOfPages));
    }
    [super scrollViewDidScroll:scrollView];
    [self.animator animate:scrollView.contentOffset.x];
}

-(void) openGithub {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://github.com/devicefactory"]];
}

-(void) buyNowBtnPressed {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://devicefactory.com/product/df1/"]];
}

@end
