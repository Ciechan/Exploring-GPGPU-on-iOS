//
//  Created by Bartosz Ciechanowski on 26.12.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "LinearTester.h"

@implementation LinearTester

- (GLint)vectorOutputs
{
    return 16;
}

- (NSString *)shaderFunctionFileName
{
    return @"Linear";
}

- (void)fillCPUBuffer:(float *)cpuBuffer GPUBuffer:(float *)gpuBuffer
{
    for (int i = 0; i < self.valuesCount; i++) {
        float value = 100.0 * drand48();
        cpuBuffer[i] = value;
        gpuBuffer[i] = value;
    }
}


- (void)calculateCPUWithReadBuffer:(float * restrict)readBuffer
                       writeBuffer:(float * restrict)writeBuffer
                             count:(int)count
{
    for (int i = 0; i < count; i++) {
        
        writeBuffer[i] = readBuffer[i] * 3.4f + 10.2f;
    }
}

@end
