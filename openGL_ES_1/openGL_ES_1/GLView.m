//
//  GLView.m
//  openGL_ES_1
//
//  Created by osborn on 2018/9/13.
//  Copyright © 2018年 osborn. All rights reserved.
//

#import "GLView.h"
#import <OpenGLES/ES2/gl.h>

@interface GLView()
{
    CAEAGLLayer *_eaglLayer;
    EAGLContext *_context;
    
    GLuint       _framebuffer;
    GLuint       _renderbuffer;
}

@end


@implementation GLView

+(Class)layerClass {
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configEnvironment];
    }
    return self;
}

- (void)layoutSubviews
{
    [EAGLContext setCurrentContext:_context];
    [self unbindRenderAndFrameBuffer];
    [self setUpFrameRenderBuffer];
    [self render];
}

#pragma mark --

- (void)configEnvironment {
    
    _eaglLayer = (CAEAGLLayer *)self.layer;
    _eaglLayer.opaque = YES;
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!_context) {
        NSLog(@"initialize openGL context error");
    }
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"set openGL context error");
    }
}

- (void)setUpFrameRenderBuffer {
    glGenRenderbuffers(1,&_renderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
    glGenFramebuffers(1, &_framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _renderbuffer);  //render 装配到 GL_COLOR_ATTACHMENT0 上
}

- (void)unbindRenderAndFrameBuffer {
    
    glDeleteFramebuffers(1, &_framebuffer);
    _framebuffer = 0;
    glDeleteRenderbuffers(1, &_renderbuffer);
    _renderbuffer = 0;
}


- (void)render {
    
//清屏
    glClearColor(0.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}







@end
