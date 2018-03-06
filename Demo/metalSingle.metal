//
//  metalSingle.metal
//  Demo
//
//  Created by 高炼 on 2018/3/5.
//  Copyright © 2018年 高炼. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


vertex float4 basic_vertex(constant packed_float3* vertex_array[[buffer(0)]],
                           unsigned int vid[[vertex_id]]) {
    return float4(vertex_array[vid], 1.0);
}

fragment half4 basic_fragment() {
    return half4(0.5);
}
