//
//  Shaders.metal
//  MetalTest
//
//  Created by Litherum on 7/18/15.
//  Copyright © 2015 com.apple. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexInput {
    float2 position [[ attribute(0) ]];
};

struct VertexOutput {
    float4 position [[ position ]];
};

struct FragmentOutput {
    float4 color [[ color(0) ]];
};

struct Uniforms {
    float time;
    float width;
    float height;
    float padding;
};

vertex VertexOutput vertexIdentity(VertexInput input [[ stage_in ]]) {
    VertexOutput output;
    output.position = float4(input.position, 0.5, 1);
    return output;
}

fragment FragmentOutput fragmentRed(VertexOutput input) {
    FragmentOutput output;
    output.color = float4(1, 0, 0, 1);
    return output;
}

kernel void increment(device float* buffer [[ buffer(0) ]], device Uniforms* uniforms [[ buffer(1) ]], uint pos [[ thread_position_in_grid ]]) {
    float speed = 10;
    switch (pos) {
        case 0:
            buffer[pos] = -0.5 + 0.3 * cos(speed * uniforms->time);
            break;
        case 1:
            buffer[pos] = -0.5 + 0.3 * sin(speed * uniforms->time);
            break;
        case 2:
            buffer[pos] = 0.5 + 0.3 * cos(speed * uniforms->time);
            break;
        case 3:
            buffer[pos] = -0.5 + 0.3 * sin(speed * uniforms->time);
            break;
        case 4:
            buffer[pos] = 0 + 0.3 * cos(speed * uniforms->time);
            break;
        case 5:
            buffer[pos] = 0.5 + 0.3 * sin(speed * uniforms->time);
            break;
    }
}
