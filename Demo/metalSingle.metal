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

vertex VertexOutput basic_vertex(VertexInput in [[ stage_in ]]) {
    VertexOutput out;
    out.position = in.position;
    out.color = in.color;
    out.pointSize = 42;
    return out;
}

fragment half4 basic_fragment(FragmentInput in [[ stage_in ]]) {
    return half4(in.color);
}
