//
//  Created by Bartosz Ciechanowski on 26.12.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import "IterativeTester.h"

@implementation IterativeTester

- (GLint)vectorOutputs
{
    return 2;
}

- (NSString *)shaderFunctionFileName
{
    return @"Iterative";
}

- (void)fillCPUBuffer:(float *)cpuBuffer GPUBuffer:(float *)gpuBuffer
{
    NSUInteger count = self.valuesCount;
    for (int i = 0; i < count; i += 2) {
        float x = 2.0 * drand48() - 1.0;
        float y = 2.0 * drand48() - 1.0;
        
        float len = sqrtf(x*x + y*y);
        
        x /= len;
        y /= len;
        
        cpuBuffer[i] = x;
        cpuBuffer[i + 1] = y;
        
        gpuBuffer[i] = x;
        gpuBuffer[i + 1] = y;
    }
}


- (void)calculateCPUWithReadBuffer:(float * restrict)readBuffer
                       writeBuffer:(float * restrict)writeBuffer
                             count:(int)count
{
    for (int i = 0; i < count; i += 2) {
        float vx = readBuffer[i];
    	float vy = readBuffer[i+1];
        float x = 123.0f;
        float y = 456.0f;

        const float dt = 0.1f;

        for (int i = 0; i < 100; i++) {

            float l = 1.0f/sqrtf(x*x + y*y);
            float ax = -x*l*l*l;
            float ay = -y*l*l*l;

            x += vx*dt;
            y += vy*dt;

            vx += ax*dt;
            vy += ay*dt;
        }
        
        writeBuffer[i] = x;
        writeBuffer[i+1] = y;
    }
}

@end
