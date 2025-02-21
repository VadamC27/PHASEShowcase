//
//  MatrixTransformations.swift
//  PHASEShowcase
//
//  Created by Adam Czyżak on 09/01/2025.
//

import PHASE

/** Few extensions to the 4x4 matrix class for code readbility in PHASE Audio controller*/

extension simd_float4x4 {
    mutating func translate(x: Float = 0.0, y: Float = 0.0, z: Float = 0.0) {
        let translationMatrix = simd_float4x4([
            simd_float4(1, 0, 0, 0),
            simd_float4(0, 1, 0, 0),
            simd_float4(0, 0, 1, 0),
            simd_float4(x, y, z, 1)
        ])
        self = matrix_multiply(self, translationMatrix)
    }
    
    mutating func setPosition(x: Float = 0.0, y: Float = 0.0, z: Float = 0.0) {
        self.columns.3 = simd_float4(x, y, z, 1.0)
    }
}
