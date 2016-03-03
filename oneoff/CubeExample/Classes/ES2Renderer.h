//
//  ES2Renderer.h
//  CubeExample
//
//  Created by Brad Larson on 4/20/2010.
//

#import "ESRenderer.h"

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <QuartzCore/QuartzCore.h>

@class PVRTexture;

@interface ES2Renderer : NSObject <ESRenderer>
{
@private
    EAGLContext *context;
	
	PVRTexture *pvrTexture;
	PVRTexture *pvrTexture2;

    // The pixel dimensions of the CAEAGLLayer
    GLint backingWidth;
    GLint backingHeight;

    // The OpenGL ES names for the framebuffer and renderbuffer used to render to this view
    GLuint defaultFramebuffer, colorRenderbuffer, msaaFramebuffer, msaaRenderbuffer, msaaDepthbuffer;

	CATransform3D currentCalculatedMatrix;

    GLuint program;
}

- (void)renderByRotatingAroundX:(float)xRotation rotatingAroundY:(float)yRotation;
- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer;
- (void)convert3DTransform:(CATransform3D *)transform3D toMatrix:(GLfloat *)matrix;

@end

