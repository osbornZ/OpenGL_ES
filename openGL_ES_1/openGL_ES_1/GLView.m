//
//  GLView.m
//  openGL_ES_1
//
//  Created by osborn on 2018/9/13.
//  Copyright © 2018年 osborn. All rights reserved.
//

#import "GLView.h"
#import <OpenGLES/ES2/gl.h>

#import "GLProgramUtil.h"

typedef struct {
    float Position[3];
    float Color[3];
} Vertex;

const GLubyte Indices[] = {
    0, 1, 2,
    2, 3, 0
};

//顶点+颜色
const Vertex vertices[] = {
    {{0.5f,   -0.5f, 0.0f}, {1.0f, 0.0f, 0.0f}},
    {{0.5f,    0.5f, 0.0f}, {0.0f, 1.0f, 0.0f}},
    {{-0.5f,   0.5f, 0.0f}, {0.0f, 0.0f, 1.0f}},
    {{-0.5f,  -0.5f, 0.0f}, {1.0f, 1.0f, 0.0f}}
};


@interface GLView()
{
    CAEAGLLayer *_eaglLayer;
    EAGLContext *_context;
    
    GLuint       _framebuffer;
    GLuint       _renderbuffer;
    
    GLuint      _program;  //渲染program句柄
    
    GLuint      _vboID;
    GLuint _positionSlot;
    GLuint _colorSlot;
    
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
        [self setUpGLProgram];
        [self setUpVertexBuffer];
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
    
//    glDeleteBuffers
    
}


//VBO
- (void)setUpVertexBuffer {

    glGenBuffers(1, &_vboID);
    glBindBuffer(GL_ARRAY_BUFFER, _vboID);
//    copy the data into the buffer object
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    
}


- (void)render {
    
//清屏
//    [self justClearScreenToRender];
    
//绘制图形
//    [self renderSomeRect];
    
//VBO+IBO
    [self renderWithVBO];
    
}


- (void)setUpGLProgram {
    NSString *vertFile = [[NSBundle mainBundle] pathForResource:@"vert.glsl" ofType:nil];
    NSString *fragFile = [[NSBundle mainBundle] pathForResource:@"frag.glsl" ofType:nil];
    _program = [GLProgramUtil createProgramVerFile:vertFile fraFile:fragFile];
    
    glUseProgram(_program);
    
//获取shader可编程位置
    _positionSlot = glGetAttribLocation(_program, "position");
    _colorSlot    = glGetAttribLocation(_program, "color");
    
}


//绘制图形单元配置图形数据信息
- (void)setupVertexData {

//    三角形
//    static GLfloat vertices[] = {
//        -1.0f,  1.0f, 0.0f,
//        -1.0f, -1.0f, 0.0f,
//        1.0f, -1.0f, 0.0f,
//    };
    
    static GLfloat vertices[] = {
        0.5f,   -0.5f, 0.0f,
        0.5f,    0.5f, 0.0f,
        -0.5f,   0.5f, 0.0f,
        -0.5f,  -0.5f, 0.0f,
    };
    
//    GLint posSlot = glGetAttribLocation(_program, "position");
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(_positionSlot);
    
    static GLfloat colors[] = {
        1.0f, 0.0f, 0.0f,
        0.0f, 1.0f, 0.0f,
        0.0f, 0.0f, 1.0f,
        1.0f, 1.0f, 0.0f
    };
    glVertexAttribPointer(_colorSlot, 3, GL_FLOAT, GL_FALSE, 0, colors);
    glEnableVertexAttribArray(_colorSlot);
    
}


#pragma mark -- render Methods

- (void)justClearScreenToRender {
    glClearColor(0.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}


- (void)renderSomeRect {
    glClearColor(0.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);

    [self setupVertexData];
    
    //不同的绘制方式,三角形
    //GL_TRIANGLES      独立三角形
    //GL_TRIANGLE_STRIP 交错绘制
    //GL_TRIANGLE_FAN   扇形绘制
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    //将指定 renderbuffer 呈现在屏幕上，在这里我们指定的是前面已经绑定为当前 renderbuffer 的那个，
    //在renderbuffer可以被呈现之前,必须调用renderbufferStorage:fromDrawable: 为之分配当前Layer为存储空间
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];

}


- (void)renderWithVBO {
    glClearColor(0.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    glEnableVertexAttribArray(_positionSlot);
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    
    glEnableVertexAttribArray(_colorSlot);
    glVertexAttribPointer(_colorSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), NULL+sizeof(GL_FLOAT)*3);

//    glDrawArrays(GL_TRIANGLES, 0, 6);

    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]),
                   GL_UNSIGNED_BYTE, 0);
    
    [_context  presentRenderbuffer: GL_RENDERBUFFER ];
    
}





@end
