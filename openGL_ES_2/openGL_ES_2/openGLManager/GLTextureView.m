//
//  GLTextureView.m
//  openGL_ES_2
//
//  Created by zfan on 2018/9/16.
//  Copyright © 2018年 zfan. All rights reserved.
//

#import "GLTextureView.h"
#import <OpenGLES/ES2/gl.h>

#import "GLProgramUtil.h"
#import <AVFoundation/AVFoundation.h>

@interface GLTextureView() {
    
    CAEAGLLayer *_eaglLayer;
    EAGLContext *_context;
    
    GLuint       _framebuffer;
    GLuint       _renderbuffer;
    
    GLuint      _program;  //渲染program句柄
    
//纹理ID
    GLuint      _textureID;
    int         _textureVertCount; //6
    GLuint      _vboID;
    
//FBO
    GLuint       _framebufferObject;
    
}

@end

@implementation GLTextureView

+(Class)layerClass {
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configEnvironment];
        [self setUpGLProgram];
        
        _textureID = [self getTextureFromImage:[UIImage imageNamed:@"texture"]];
        
        [self setUpVertexBufferObject];
    
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


//render into screen
- (void)setUpFrameRenderBuffer {
    
    glGenRenderbuffers(1,&_renderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
    glGenFramebuffers(1, &_framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _renderbuffer);  //render 装配到 GL_COLOR_ATTACHMENT0上

}

- (void)setUpGLProgram {
    NSString *vertFile = [[NSBundle mainBundle] pathForResource:@"texturevert.glsl" ofType:nil];
    NSString *fragFile = [[NSBundle mainBundle] pathForResource:@"texturefrag.glsl" ofType:nil];
    _program = [GLProgramUtil createProgramVerFile:vertFile fraFile:fragFile];
    
    glUseProgram(_program);
}


- (GLuint)getTextureFromImage:(UIImage *)image {
    // CoreGraphics部分
    CGImageRef imageRef = [image CGImage];
    size_t width  = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    GLubyte *textureData = (GLubyte *)malloc(width * height * 4);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //    color-space
    //    CGImageGetColorSpace(image);
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(textureData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0f, -1.0f);   //纹理坐标转换
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    // 纹理部分
    glEnable(GL_TEXTURE_2D);
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
    
    //绑定在5 ，GL_TEXTURE5
    glBindTexture(GL_TEXTURE_2D, 0);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(textureData);
    return texName;
}


- (void)setUpVertexBufferObject {
    _textureVertCount = 6;
    
    UIImage *image = [UIImage imageNamed:@"texture"];
    CGRect realRect = AVMakeRectWithAspectRatioInsideRect(image.size, self.bounds);
    CGFloat widthRatio  = realRect.size.width/self.bounds.size.width;
    CGFloat heightRatio = realRect.size.height/self.bounds.size.height;
    
    //坐标相对位置计算
    GLfloat vertices[] = {
        widthRatio, -heightRatio, 0.0f, 1.0f, 1.0f,   // 右下
        widthRatio,  heightRatio, 0.0f, 1.0f, 0.0f,   // 右上
        -widthRatio,  heightRatio, 0.0f, 0.0f, 0.0f,  // 左上
        -widthRatio,  heightRatio, 0.0f, 0.0f, 0.0f,  // 左上
        -widthRatio, -heightRatio, 0.0f, 0.0f, 1.0f,  // 左下
        widthRatio, -heightRatio, 0.0f, 1.0f, 1.0f,   // 右下
    };

    glGenBuffers(1, &_vboID);
    glBindBuffer(GL_ARRAY_BUFFER, _vboID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(glGetAttribLocation(_program, "position"));
    glVertexAttribPointer(glGetAttribLocation(_program, "position"), 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, NULL);
    
    glEnableVertexAttribArray(glGetAttribLocation(_program, "texcoord"));
    glVertexAttribPointer(glGetAttribLocation(_program, "texcoord"), 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, NULL+sizeof(GL_FLOAT)*3);
}


- (void)activeTexture {
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _textureID);
    //    glUniform1i(_texture, 5);
    glUniform1i(glGetUniformLocation(_program, "image"), 0);  //可以通过脚本程序获取 纹理对应location
    glDrawArrays(GL_TRIANGLES, 0, _textureVertCount);
}


- (void)unbindRenderAndFrameBuffer {
    
    glDeleteFramebuffers(1, &_framebuffer);
    _framebuffer = 0;
    glDeleteRenderbuffers(1, &_renderbuffer);
    _renderbuffer = 0;
    
}

- (void)render {
    
    glClearColor(0.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    [self activeTexture];
    [_context presentRenderbuffer:GL_RENDERBUFFER];

}


#pragma mark --FBO

//render into texture
- (void)setUpoffScreenframeBuffer {
    
    glGenFramebuffers(1, &_framebufferObject);
    glBindFramebuffer(GL_FRAMEBUFFER, _framebufferObject);
    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _textureID, 0);
    
    glGenRenderbuffers(1,&_renderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
//    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, 512, 512);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT,
                              GL_RENDERBUFFER, _renderbuffer);
    //状态检查
    GLenum state = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (state != GL_FRAMEBUFFER_COMPLETE ) {
        NSLog(@"This is error\n");
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
}

- (void)renderToFBO {
    
    glBindFramebuffer(GL_FRAMEBUFFER, _framebufferObject);
    
    glEnable(GL_DEPTH_TEST);
    glClearDepthf(1.0f);
    
    
    glClearColor(0.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);

    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _textureID);
    
    glUniform1i(glGetUniformLocation(_program, "image"), 0);  //可以通过脚本程序获取 纹理对应location
    glDrawArrays(GL_TRIANGLES, 0, _textureVertCount);

    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
    //再重新使用 渲染到fbo的纹理进行绘制
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _framebufferObject);
    
}


- (void)destroyFBO {
    
    glBindFramebuffer(GL_FRAMEBUFFER, _framebufferObject);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, 0, 0);
    glDeleteTextures(1, &_textureID);
    
    glDeleteFramebuffers(1, &_framebufferObject);
    _framebufferObject = 0;

}




@end
