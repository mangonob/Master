//
//  metalSingle.metal
//  Demo
//
//  Created by 高炼 on 2018/3/5.
//  Copyright © 2018年 高炼. All rights reserved.
//

#include <metal_stdlib>
#include <simd/simd.h>

#import "ShaderTypes.h"

using namespace metal;


typedef struct {
    float3 position [[ attribute(VertexAttributePosition) ]];
    float2 texCoord [[ attribute(VertexAttributeTexcoord) ]];
} VertexInput;

typedef struct {
    float4 position [[ position ]];
    float2 texCoord;
} VertexOutput;

typedef VertexOutput FragmentInput;

vertex VertexOutput vertexShader(VertexInput in [[ stage_in ]],
                                 constant Uniforms &uniforms [[ buffer(BufferIndexUniforms) ]])
{
    VertexOutput out;
    
    float4 position = float4(in.position, 1.0);
    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;
    out.texCoord = in.texCoord;

    return out;
}


fragment float4 fragmentShader(FragmentInput in [[ stage_in ]],
                               constant Uniforms & uniforms [[ buffer(BufferIndexUniforms) ]],
                               texture2d<half> texture  [[ texture(TextureIndexColor) ]])
{
    constexpr sampler colorSampler(mip_filter::linear,
                                   mag_filter::linear,
                                   min_filter::linear);
    
    half4 colorSample = texture.sample(colorSampler, in.texCoord.xy);
    return float4(colorSample);
}
