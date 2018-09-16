//
//  GLProgramUtil.m
//  openGL_ES_1
//
//  Created by osborn on 2018/9/13.
//  Copyright © 2018年 osborn. All rights reserved.
//

#import "GLProgramUtil.h"

@implementation GLProgramUtil

+ (GLuint)createProgramVerFile:(NSString *)vShaderFilepath fraFile:(NSString *)fShaderFilepath {
    
    NSError  *error;
    NSString *vShaderString = [NSString stringWithContentsOfFile:vShaderFilepath encoding:NSUTF8StringEncoding error:&error];
    NSString *fShaderString = [NSString stringWithContentsOfFile:fShaderFilepath encoding:NSUTF8StringEncoding error:&error];
    if (!vShaderString || !fShaderString) {
        NSLog(@"Error: loading shader file:%@", error.localizedDescription);
        return 0;
    }
    
    //create shader
    GLuint  vertShader ,fragShader;
    vertShader = [self createGLShader:vShaderString shaderType:GL_VERTEX_SHADER];
    fragShader = [self createGLShader:fShaderString shaderType:GL_FRAGMENT_SHADER];
    if (vertShader == 0 || fragShader == 0) {
        return 0;
    }
    
    GLuint programHandle = glCreateProgram();
    if( !programHandle ) {
        NSLog(@"Failed creat");
        return 0;
    }
    glAttachShader(programHandle, vertShader);
    glAttachShader(programHandle, fragShader);
    
    glLinkProgram( programHandle );
    
    // Check the link status
    GLint linked;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linked );
    if (!linked) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"program  :%@", messageString);
        
        glDeleteShader(vertShader);
        glDeleteShader(fragShader);
        glDeleteProgram(programHandle);
        return 0;
    }
    
    glDetachShader(programHandle, vertShader);
    glDetachShader(programHandle, fragShader);
    glDeleteShader(vertShader);
    glDeleteShader(fragShader);
    
    return programHandle;
}


+ (GLuint)createGLShader:(NSString *)shaderString shaderType:(GLenum)type {
    GLuint shader = glCreateShader(type);
    if (shader == 0) {
        NSLog(@"Error: failed to create shader.");
        return 0;
    }
    //Load the shader source
    const GLchar *shaderStringUTF8 = (GLchar *)[shaderString UTF8String];
    GLint length = (GLint)[shaderString length];
    glShaderSource(shader, 1, &shaderStringUTF8, &length);
    glCompileShader(shader);
    
    // Check the compile status
    GLint compileSuccess;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shader, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"shader: %@", messageString);
        
        glDeleteShader(shader);
        return 0;
    }
    return shader;
}




@end
