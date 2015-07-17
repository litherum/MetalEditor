//
//  Shaders.metal
//  MetalEditor
//
//  Created by Litherum on 7/16/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void increment(device uchar* buffer [[ buffer(0) ]], uint pos [[ thread_position_in_grid ]]) {
    ++buffer[pos];
}
