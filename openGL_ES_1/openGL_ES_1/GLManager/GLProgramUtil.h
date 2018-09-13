//
//  GLProgramUtil.h
//  openGL_ES_1
//
//  Created by osborn on 2018/9/13.
//  Copyright © 2018年 osborn. All rights reserved.
//
// create program with shader file

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>

@interface GLProgramUtil : NSObject

+ (GLuint)createProgramVerFile:(NSString *)vShaderFilepath fraFile:(NSString *)fShaderFilepath;


@end
