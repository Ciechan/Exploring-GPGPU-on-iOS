//
//  Created by Bartosz Ciechanowski on 26.12.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tester : NSObject

@property (nonatomic) NSUInteger valuesCount;

- (void)fillCPUBuffer:(float *)cpuBuffer GPUBuffer:(float *)gpuBuffer;


- (void)calculateCPUWithReadBuffer:(float * restrict)readBuffer
                       writeBuffer:(float * restrict)writeBuffer
                             count:(int)count;

- (void)calculateGPUWithReadVAO:(GLuint)readVAO
                       writeBuffer:(GLuint)writeBuffer
                             count:(int)count;

- (NSString *)shaderFunctionFileName;
- (void)loadShaders;
- (GLint)vectorOutputs;

@end
