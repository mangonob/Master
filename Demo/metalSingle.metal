//
//  metalSingle.metal
//  Demo
//
//  Created by 高炼 on 2018/3/5.
//  Copyright © 2018年 高炼. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct VertexInput {
    float3 position [[ attribute(0) ]];
    float3 color [[ attribute(1) ]];
};

struct VertexOutput {
    float4 position [[ position ]];
    float4 color;
    float pointSize [[ point_size ]];
};

typedef VertexOutput FragmentInput;

vertex VertexOutput basic_vertex(VertexInput in [[ stage_in ]],
                                 constant packed_float3 *positions [[ buffer(0) ]],
                                 constant packed_float3 *colors [[ buffer(1) ]],
                                 uint index [[ vertex_id ]]) {
    VertexOutput out;
    out.position = float4(in.position, 1.0);
    out.color = float4(in.color, 1.0);
    out.pointSize = 42;
    return out;
}

fragment float4 basic_fragment(FragmentInput in [[ stage_in ]]) {
    return float4(in.color);
}
