//
//  Created by Bartosz Ciechanowski on 26.12.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "Tester.h"
#import <OpenGLES/ES3/gl.h>
#import <Accelerate/Accelerate.h>


@interface Tester() {
    
    GLuint program;
}

@end

@implementation Tester

#pragma mark - Abstract Methods

- (GLint)vectorOutputs
{
    return 4;
}

- (NSString *)shaderFunctionFileName
{
    return @"";
}

- (void)fillCPUBuffer:(float *)cpuBuffer GPUBuffer:(float *)gpuBuffer
{
    
}


- (void)calculateCPUWithReadBuffer:(float * restrict)readBuffer
                       writeBuffer:(float * restrict)writeBuffer
                             count:(int)count
{
    
}

- (void)calculateGPUWithReadVAO:(GLuint)readVAO
                    writeBuffer:(GLuint)writeBuffer
                          count:(int)count
{
    const int VectorOutputs = [self vectorOutputs];
    
    glUseProgram(program);
    
    glEnable(GL_RASTERIZER_DISCARD);
    
    glBindVertexArrayOES(readVAO);
    
    glBindBufferBase(GL_TRANSFORM_FEEDBACK_BUFFER, 0, writeBuffer);
    
    glBeginTransformFeedback(GL_POINTS);
    glDrawArrays(GL_POINTS, 0, count/(4 * VectorOutputs));
    glEndTransformFeedback();
    
    glDisable(GL_RASTERIZER_DISCARD);
    
    glFinish(); //force the calculations to happen NOW
}


#pragma mark - Shader Compilation

- (GLuint)createShaderWithType:(GLenum)type source:(GLchar const *)source
{
    GLuint shader = glCreateShader(type);
    glShaderSource(shader, 1, &source, 0);
    glCompileShader(shader);
    
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    GLint status;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(shader);
        return 0;
    }
    
    return shader;
}


- (void)loadShaders
{
    
    const int VectorOutputs = [self vectorOutputs];
    
    GLchar *fragmentShaderSource = (GLchar *)"#version 300 es\n\nvoid main() {}";
    
    GLuint programHandle = glCreateProgram();
    GLuint vertexShader = [self createShaderWithType:GL_VERTEX_SHADER source:[[self vertexShaderBody] UTF8String]];
    GLuint fragmentShader = [self createShaderWithType:GL_FRAGMENT_SHADER source:fragmentShaderSource];
    
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    
    
    char *varyings[VectorOutputs];
    
    for (int i = 0; i < VectorOutputs; i++) {
        NSString *inVector = [NSString stringWithFormat:InVectorFormat, i];
        NSString *outVector = [NSString stringWithFormat:OutVectorFormat, i];
        
        glBindAttribLocation(programHandle, i, [inVector UTF8String]);
        
        varyings[i] = malloc(100);
        strncpy(varyings[i], [outVector UTF8String], 100);
    }
    
    glTransformFeedbackVaryings(programHandle, [self vectorOutputs], (const char * const *)varyings, GL_INTERLEAVED_ATTRIBS);
    
    glLinkProgram(programHandle);
    
    for (int i = 0; i < VectorOutputs; i++) {
        free(varyings[i]);
    }
    
    
#if defined(DEBUG)
    GLint logLength;
    
    glGetProgramiv(programHandle, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(programHandle, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    GLint status;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &status);
    if (status == 0) {
        NSLog(@"Link error");
        return;
    }
    
    program = programHandle;
    
    return;
}

#pragma mark - Shader Generation

static NSString * const InVectorFormat = @"InV%d";
static NSString * const OutVectorFormat = @"OutV%d";

- (NSString *)vertexShaderBody
{
    const int VectorOutputs = [self vectorOutputs];
    
    NSMutableString *string = [NSMutableString string];
    [string appendString:@"#version 300 es\n\n"];
    
    for (int i = 0; i < VectorOutputs; i++) {
        NSString *inVector = [NSString stringWithFormat:InVectorFormat, i];
        [string appendFormat:@"in vec4 %@;\n", inVector];
    }
    
    for (int i = 0; i < VectorOutputs; i++) {
        NSString *outVector = [NSString stringWithFormat:OutVectorFormat, i];
        [string appendFormat:@"out vec4 %@;\n", outVector];
    }
    
    NSString *functionShaderPath = [[NSBundle mainBundle] pathForResource:[self shaderFunctionFileName] ofType:@"vsh"];
    [string appendString:[NSString stringWithContentsOfFile:functionShaderPath encoding:NSUTF8StringEncoding error:nil]];
    
    [string appendString:@"\nvoid main() {\n"];
    
    for (int i = 0; i < VectorOutputs; i++) {
        NSString *inVector = [NSString stringWithFormat:InVectorFormat, i];
        NSString *outVector = [NSString stringWithFormat:OutVectorFormat, i];
        [string appendFormat:@"%@ = f(%@);\n", outVector, inVector];
    }
    
    [string appendString:@"\n}\n"];
    
    return string;
}


@end
