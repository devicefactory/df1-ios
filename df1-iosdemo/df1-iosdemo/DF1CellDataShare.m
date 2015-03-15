//
//  DF1CellDataShare.m
//  df1-iosdemo
//
//  Created by JB Kim on 4/27/14.
//  Copyright (c) 2013 JB Kim. All rights reserved.
//
#define DF_LEVEL 0

#import "DF1Cell.h"
#import "DF1CellDataShare.h"
#import "DF1DevDetailController.h"

@interface DF1CellDataShare ()
{
    NSUInteger accSliderValuePrevious;
    // https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSFileHandle_Class/index.html#//apple_ref/occ/clm/NSFileHandle/fileHandleForWritingAtPath:
    NSFileHandle *_fh;
    NSDateFormatter *_formatter;
}
@end


@implementation DF1CellDataShare

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
  parentController:(DF1DevDetailController*) parent
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(!self) return self;
    self.parent = parent;
    self.height = 90;
    _fh = nil;
    
    _formatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [_formatter setLocale:enUSPOSIXLocale];
    [_formatter setDateFormat:@"yyyyMMdd'T'HH':'mm':'ss.SSS"];

    // Initialization code
    self.mainLabel = [[UILabel alloc] init];
    self.mainLabel.textAlignment = NSTextAlignmentRight;
    self.mainLabel.font = [UIFont systemFontOfSize:16];
    self.mainLabel.textColor = [UIColor grayColor];
    self.mainLabel.backgroundColor = [UIColor clearColor];
    
    self.fileNameField = [[UITextField alloc] init];
    self.fileNameField.delegate = self;
    self.fileNameField.placeholder = @"df1_data.csv";
    [self.fileNameField addTarget:self action:@selector(handleTextFieldEdit:) forControlEvents:UIControlEventEditingDidEnd];

    self.recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.recordButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    [self.recordButton setImage:[UIImage imageNamed:@"stop.png"] forState:UIControlStateSelected];
    [self.recordButton addTarget:self action:@selector(recordAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shareButton setImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];
    [self.shareButton setImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateSelected];
    [self.shareButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:self.fileNameField];
    [self.contentView addSubview:self.mainLabel];
    [self.contentView addSubview:self.recordButton];
    [self.contentView addSubview:self.shareButton];
    
    [self listAllLocalFiles]; // list the local docs first
    
    return self;
}

-(void)layoutSubviews
{ 
    [super layoutSubviews];
    CGFloat boundsX = self.contentView.bounds.origin.x;
    CGFloat width = self.contentView.bounds.size.width;

    self.mainLabel.frame     = CGRectMake(boundsX + 5,   5, width-50, 25);
    self.fileNameField.frame = CGRectMake(boundsX + 30,  35, 200, 25);
    self.recordButton.frame  = CGRectMake(boundsX + 180, 35, 40, 40);
    self.shareButton.frame   = CGRectMake(boundsX + 240, 35, 40, 40);
}

-(NSString*) getFilename
{
    NSString *filename = ([self.fileNameField.text isEqualToString:@""]) ?
    self.fileNameField.placeholder : self.fileNameField.text;
    return filename;
}

-(IBAction) handleTextFieldEdit:(UITextField*) sender
{
    DF_DBG(@"setting _filename to %@", sender.text);
    [sender resignFirstResponder];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if(textField==self.fileNameField)
        [self.fileNameField resignFirstResponder];
    return NO;
}


-(void)recordAction:(UIButton *)sender
{
    if(sender.selected){
        // pause action
        [self closeFile];
    } else {
        // play action
        NSString *filename = [self getFilename];
        if(![self openFile:filename]) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Failed to open file!"
                                                               message:@"Could not create file for writing data."
                                                              delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    }
    sender.selected = !sender.selected;
}

/*
Resource 1:
http://stackoverflow.com/questions/11078647/how-to-read-write-file-with-ios-in-simulator-as-well-as-on-device

NSString *dataFile = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"txt"];

NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/YourFile.txt"];

NSString *dataFile = [NSString stringWithContentsOfFile:docPath 
                                           usedEncoding:NSUTF8StringEncoding 
                                                  error:NULL];

NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/YourFile.txt"];
[dataFile writeToFile:docPath 
          atomically:YES 
            encoding:NSUTF8StringEncoding 
               error:NULL];

Resource 2:
http://mobile.antonio081014.com/2013/06/create-rename-delete-read-and-write.html
*/


- (void)listAllLocalFiles
{
    // Fetch directory path of document for local application.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // NSFileManager is the manager organize all the files on device.
    NSFileManager *manager = [NSFileManager defaultManager];
    // This function will return all of the files' Name as an array of NSString.
    NSArray *files = [manager contentsOfDirectoryAtPath:documentsDirectory error:nil];
    // Log the Path of document directory.
    NSLog(@"Directory: %@", documentsDirectory);
    // For each file, log the name of it.
    for (NSString *file in files) {
        NSLog(@"File at: %@", file);
    }
}

-(NSString*) filePathFromFilename:(NSString*) filename
{
    // Fetch directory path of document for local application.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // Have the absolute path of file named fileName by joining the document path with fileName, separated by path separator.
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:filename];
    return filePath;
}

-(bool) openFile:(NSString*) filename
{
    DF_DBG(@"passed in filename: %@", filename);
    NSString *filePath = [self filePathFromFilename:filename];
    // NSFileManager is the manager organize all the files on device.
    NSFileManager *manager = [NSFileManager defaultManager];
    // Check if the file named fileName exists.
    if ([manager fileExistsAtPath:filePath]) {
        _fh = [NSFileHandle fileHandleForWritingAtPath:filePath];
        if (_fh==nil) {
            DF_DBG(@"Error opening existing path: %@", filePath);
            return false;
        }
        [_fh truncateFileAtOffset: 0];
    } else {
        DF_DBG(@"File %@ doesn't exist", filePath);
        [manager createFileAtPath:filePath contents:nil attributes:nil];
        _fh = [NSFileHandle fileHandleForWritingAtPath:filePath];
        if (_fh==nil) {
            DF_DBG(@"Error opening new file: %@", filePath);
            return false;
        }
    }
    return true;
}

-(void) recordData:(NSArray*) data
{
    [self recordX:[data[0] floatValue] Y:[data[1] floatValue] Z:[data[2] floatValue]];
}

-(void) recordX:(float)x Y:(float)y Z:(float)z
{
    if(_fh==nil) {
        DF_DBG(@"filehandle is invalid");
        return;
    }

    NSString *ts = [_formatter stringFromDate:[NSDate date]];
    // NSString *timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    // convert the data into string so we can make it into ascii byte stream.
    NSString *line = [NSString stringWithFormat:@"%@,%f,%f,%f\n", ts,x,y,z];
    //NSData *bytes = [line dataUsingEncoding:NSUTF8StringEncoding];
    NSData *bytes = [line dataUsingEncoding:NSASCIIStringEncoding];
    [_fh writeData:bytes];
}

-(bool) closeFile
{
    if(_fh!=nil) {
        [_fh closeFile];
        DF_DBG(@"closed filehandle");
        _fh = nil;
        return true;
    }
    return false;
}

-(bool) isFileReady
{
    return _fh!=nil;
}


- (NSURL *) fileToURL:(NSString*)filename
{
    // NSArray *fileComponents = [filename componentsSeparatedByString:@"."];
    // NSString *filePath = [[NSBundle mainBundle] pathForResource:[fileComponents objectAtIndex:0] ofType:[fileComponents objectAtIndex:1]];

    NSString *filePath = [self filePathFromFilename:filename];
    return [NSURL fileURLWithPath:filePath];
}


// Amazing how easy apple made it to share data....
- (IBAction)share:(id)sender
{
    NSString *filename = [self getFilename];
    NSString *filePath = [self filePathFromFilename:[self getFilename]];
    NSFileManager *manager = [NSFileManager defaultManager];
    // Check if the file named fileName exists.
    if (![manager fileExistsAtPath:filePath]) {
        DF_DBG(@"file does not exist!!");
        return;
    }
    // if the file is currently being written, close it.
    if([self isFileReady]) {
        [self.recordButton sendActionsForControlEvents:UIControlEventTouchUpInside]; // turn it off
        [self closeFile];
    }
    
    NSURL *url = [self fileToURL:filename];
    DF_DBG(@"fileURL: %@", url);
    NSArray *objectsToShare = @[url];

    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    // Exclude all activities except AirDrop.
    /*
    NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypeMessage, UIActivityTypeMail,
                                    UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                    UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
     */
    NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
    controller.excludedActivityTypes = excludedActivities;
    [controller setValue:@"Data from DF1" forKey:@"subject"];

    // Present the controller
    [self.parent presentViewController:controller animated:YES completion:nil];
    
    if ([controller respondsToSelector:@selector(popoverPresentationController)])
    {
        // iOS 8+
        UIPopoverPresentationController *presentationController = [controller popoverPresentationController];
        presentationController.sourceView = sender; // if button or change to self.view.
    }
}

/*
-(void) show
{
    NSURL *url = [self fileToURL:self.documentName];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:urlRequest];
}
*/

@end

