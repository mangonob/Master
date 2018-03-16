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
    float4 position [[ attribute(0) ]];
    float4 color [[ attribute(1) ]];
};

struct VertexOutput {
    float4 position [[ position ]];
    float4 color;
    float pointSize [[ point_size ]];
};

typedef VertexOutput FragmentInput;

vertex VertexOutput basic_vertex(VertexInput in [[ stage_in ]],
                                 constant packed_float4 *positions [[ buffer(0) ]],
                                 constant packed_float4 *colors [[ buffer(1) ]],
                                 uint index [[ vertex_id ]]) {
    VertexOutput out;
    out.position = float4(positions[index]);
    out.color = in.color;
    out.pointSize = 42;
    return out;
}

fragment float4 basic_fragment(FragmentInput in [[ stage_in ]],
                              constant packed_float4 *positions [[ buffer(0) ]]) {
    return float4(in.color);
}
