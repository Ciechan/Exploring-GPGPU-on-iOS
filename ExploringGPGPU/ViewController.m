//
//  Created by Bartosz Ciechanowski on 23.12.2013.
//  Copyright (c) 2013 Bartosz Ciechanowski. All rights reserved.
//

#import <OpenGLES/ES3/gl.h>

#import "ViewController.h"

#import "LinearTester.h"
#import "ExponentTester.h"
#import "IterativeTester.h"


const int Count = 1 << 24;

const int ProfileIterations = 8;


@interface ViewController () {
    
    GLuint gpuReadBuffer;
    GLuint gpuWriteBuffer;
    GLuint vao;
    
    float *cpuReadBuffer;
    float *cpuWriteBuffer;
}

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) Tester *tester;

@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    
    if (!self.context) {
        NSLog(@"This application requires OpenGL ES 3.0");
        abort();
    }
    
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [EAGLContext setCurrentContext:self.context];
    
    //self.tester = [LinearTester new];
    //self.tester = [ExponentTester new];
    self.tester = [IterativeTester new];
    
    self.tester.valuesCount = Count;
    [self.tester loadShaders];
    
    [self setupCPUBuffers];
    [self setupGPUBuffers];
    [self fillBuffers];
}

- (void)setupCPUBuffers
{
    cpuReadBuffer = malloc(sizeof(float) * Count);
    cpuWriteBuffer = malloc(sizeof(float) * Count);
}

- (void)setupGPUBuffers
{
    glGenBuffers(1, &gpuReadBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, gpuReadBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(float) * Count, cpuReadBuffer, GL_STREAM_DRAW);

    glGenVertexArraysOES(1, &vao);
    glBindVertexArrayOES(vao);

    int vectorOutputs = [self.tester vectorOutputs];
    
    for (int i = 0; i < vectorOutputs; i++) {
        glEnableVertexAttribArray(i);
        glVertexAttribPointer(i, 4, GL_FLOAT, GL_FALSE, (4 * vectorOutputs) * sizeof(float), (void *)(i * 4 * sizeof(float)));
    }
    glBindVertexArrayOES(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);


    glGenBuffers(1, &gpuWriteBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, gpuWriteBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(float) * Count, NULL, GL_STREAM_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);    
}

- (void)fillBuffers
{
    glBindBuffer(GL_ARRAY_BUFFER, gpuReadBuffer);
    float *gpuRead = glMapBufferRange(GL_ARRAY_BUFFER, 0, sizeof(float) * Count, GL_MAP_WRITE_BIT);
    
    [self.tester fillCPUBuffer:cpuReadBuffer GPUBuffer:gpuRead];
    
    glUnmapBuffer(GL_ARRAY_BUFFER);
}

- (void)profileWithBlock:(void (^)(int count))profileBlock;
{
    NSTimeInterval last = 0.0f;
    for (int count = 1 << 12; count <= Count; count <<= 1) {
        NSDate *start = [NSDate date];
        
        for (int iter = 0; iter < ProfileIterations; iter++) {
            profileBlock(count);
        }
        
        last = [[NSDate date] timeIntervalSinceDate:start]/ProfileIterations;
        printf("%g\n", last);
    }
}


- (void)measureCPU
{
    printf("CPU\n");

    [self profileWithBlock:^(int count) {
        [self.tester calculateCPUWithReadBuffer:cpuReadBuffer writeBuffer:cpuWriteBuffer count:count];
    }];
}

- (void)measureGPU
{
    // shader warmup
    [self.tester calculateGPUWithReadVAO:vao writeBuffer:gpuWriteBuffer count:128];
    
    printf("GPU\n");
    
    [self profileWithBlock:^(int count) {
        [self.tester calculateGPUWithReadVAO:vao writeBuffer:gpuWriteBuffer count:count];
    }];
}

- (void)measure
{
    [self measureCPU];
    [self measureGPU];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self measure];
    
    glBindBuffer(GL_ARRAY_BUFFER, gpuWriteBuffer);
    float *gpuMemoryBuffer = glMapBufferRange(GL_ARRAY_BUFFER, 0, sizeof(float) * Count, GL_MAP_READ_BIT);
    
    [self compareCPUBuffer:cpuWriteBuffer withGPUBuffer:gpuMemoryBuffer];
    
    glUnmapBuffer(GL_ARRAY_BUFFER);
}

// based on
// http://randomascii.wordpress.com/2012/02/25/comparing-floating-point-numbers-2012-edition/
//
- (void)compareCPUBuffer:(float *)cpuBuffer withGPUBuffer:(float *)gpuBuffer
{
    union Float_t {
        float f;
        int32_t i;
    };
    
    BOOL isCalculationCorrect = YES;
    
    float errorSum = 0.0f;
    float maxError = 0.0f;
    float minError = MAXFLOAT;
    
    int32_t ULPsum = 0;
    int32_t maxULP = 0;
    int32_t minULP = INT32_MAX;
    
    union Float_t cpu, gpu;
    
    for (int i = 0; i < Count; i++) {
        
        cpu.f = cpuBuffer[i];
        gpu.f = gpuBuffer[i];
        
        float error = fabsf((cpu.f - gpu.f)/cpu.f);
        
        maxError = MAX(maxError, error);
        minError = MIN(minError, error);
        
        errorSum += error;

        
        if ((cpu.i >> 31 != 0) != (gpu.i >> 31 != 0) ) {
            if (cpu.f != gpu.f) {
                isCalculationCorrect = NO; // different sings, can't compare, sorry
            }
        }
        
        int32_t ulpError = abs(cpu.i - gpu.i);
        maxULP = MAX(maxULP, ulpError);
        minULP = MIN(minULP, ulpError);
        
        ULPsum += ulpError;
    }

    if (isCalculationCorrect) {
        printf("ULP: avg:%g max: %d, min: %d\n", (double)ULPsum/Count, maxULP, minULP);
    } else {
        printf("WARNING: the ULP error evaluation failed due to sign mismatch\n");
    }
    
    printf("FLT: avg:%g max: %g, min: %g\n", errorSum/Count, maxError, minError);
}


@end
