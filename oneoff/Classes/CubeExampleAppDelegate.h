//
//  CubeExampleAppDelegate.h
//  CubeExample
//
//  Created by Brad Larson on 4/20/2010.
//

#import <UIKit/UIKit.h>

@class EAGLView;

@interface CubeExampleAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    EAGLView *glView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet EAGLView *glView;


@end

