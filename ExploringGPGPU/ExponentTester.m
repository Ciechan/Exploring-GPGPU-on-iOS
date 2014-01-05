//
//  Created by Bartosz Ciechanowski on 26.12.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "ExponentTester.h"

@implementation ExponentTester

- (GLint)vectorOutputs
{
    return 4;
}

- (NSString *)shaderFunctionFileName
{
    return @"Exponent";
}

- (void)fillCPUBuffer:(float *)cpuBuffer GPUBuffer:(float *)gpuBuffer
{
    NSUInteger count = self.valuesCount;
    
    for (int i = 0; i < count; i++) {
        float value = 10.0f * i / (count - 1);
        cpuBuffer[i] = value;
        gpuBuffer[i] = value;
    }
}


- (void)calculateCPUWithReadBuffer:(float * restrict)readBuffer
                       writeBuffer:(float * restrict)writeBuffer
                             count:(int)count
{
    for (int i = 0; i < count; i++) {
        float x = readBuffer[i];
        writeBuffer[i] = 2.3f * expf(-3.0f * x) * (sinf(0.4f * x) + cosf(-1.7f * x)) + 3.7f;
    }
}


@end
