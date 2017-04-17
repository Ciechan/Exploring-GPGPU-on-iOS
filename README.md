Exploring GPGPU on iOS
======================

This is a companion repo for my [blog post on GPGPU computing on iOS](http://ciechanowski.me/blog/2014/01/05/exploring_gpgpu_on_ios/). It contains three computation examples that were presented in the post as well as benchmarks used for performance measurements. 

For the record, in the extreme case, the GPU performed **over 64 times** faster than CPU.

## Requirements

#### OpenGL ES 3.0 capable device
This basically boils down to A7 chip (iPhone 5s, iPad Air, Retina iPad mini).

#### iOS 7.1 
While this code uses a new feature of OpenGL ES 3.0 (namely Transform Feedback) and the feature itself does work in iOS 7.0.x, it is somehow dysfunctional. Due to a [confirmed bug](https://devforums.apple.com/message/929561#929561) (Apple dev account required), shaders that contain and *call* user defined functions do crash when used for Transform Feedback. While I could manually inline the function's body into the source code, my implementation generates shaders with variable number of `in` and `out` vectors and having a single function to call made shader generator significantly easier to create. While I've tested the code on iOS 7.1 beta 2, it should work on beta 1 as well.

Note, that if you are willing to write the shader manually or create a smarter shader generator that will not use user defined functions, you can make the code work on iOS 7.0.x.

## Important

This application doesn't display anything, it merely runs calculations on the CPU and the GPU then prints the benchmark output to the console.
