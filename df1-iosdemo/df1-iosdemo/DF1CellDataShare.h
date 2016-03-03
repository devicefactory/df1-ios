//
//  DF1CellDataShare.h
//  df1-iosdemo
//
//  Created by JB Kim on 4/27/14.
//  Copyright (c) 2013 JB Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "F3PlotStrip.h"
#import "DF1Lib.h"
#import "DF1Cell.h"

@class DF1DevDetailController;

@interface DF1CellDataShare : DF1Cell<UITextFieldDelegate>
@property (nonatomic,strong) DF1DevDetailController *parent;
@property (nonatomic,retain) UITextField *fileNameField;
@property (nonatomic,retain) UILabel *mainLabel;
@property (nonatomic,retain) UIButton *recordButton;
@property (nonatomic,retain) UIButton *shareButton;
// @property (nonatomic,retain) UIImageView *accIcon;
// @property (nonatomic,retain) UIProgressView *accBarX;
// @property (nonatomic,retain) UIView *accBarHolder;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
  parentController:(DF1DevDetailController*) parent;
-(IBAction) handleTextFieldEdit:(UITextField*) sender;
-(bool) openFile:(NSString*) file;
-(bool) closeFile;
-(bool) isFileReady;
-(void) recordData:(NSArray*) data;
-(void) recordX:(float)x Y:(float)y Z:(float)z;
@end

