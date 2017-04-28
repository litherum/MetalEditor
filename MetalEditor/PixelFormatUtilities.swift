//
//  PixelFormatUtilities.swift
//  MetalEditor
//
//  Created by Litherum on 8/16/15.
//  Copyright © 2015 Litherum. All rights reserved.
//

import Cocoa

let pixelFormatMenuOrder: [MTLPixelFormat] = [.invalid, .a8Unorm, .r8Unorm, .r8Snorm, .r8Uint, .r8Sint, .r16Unorm, .r16Snorm, .r16Uint, .r16Sint, .r16Float, .rg8Unorm, .rg8Snorm, .rg8Uint, .rg8Sint, .r32Uint, .r32Sint, .r32Float, .rg16Unorm, .rg16Snorm, .rg16Uint, .rg16Sint, .rg16Float, .rgba8Unorm, .rgba8Unorm_srgb, .rgba8Snorm, .rgba8Uint, .rgba8Sint, .bgra8Unorm, .bgra8Unorm_srgb, .rgb10a2Unorm, .rgb10a2Uint, .rg11b10Float, .rgb9e5Float, .rg32Uint, .rg32Sint, .rg32Float, .rgba16Unorm, .rgba16Snorm, .rgba16Uint, .rgba16Sint, .rgba16Float, .rgba32Uint, .rgba32Sint, .rgba32Float, .bc1_rgba, .bc1_rgba_srgb, .bc2_rgba, .bc2_rgba_srgb, .bc3_rgba, .bc3_rgba_srgb, .bc4_rUnorm, .bc4_rSnorm, .bc5_rgUnorm, .bc5_rgSnorm, .bc6H_rgbFloat, .bc6H_rgbuFloat, .bc7_rgbaUnorm, .bc7_rgbaUnorm_srgb, .gbgr422, .bgrg422, .depth32Float, .stencil8, .depth24Unorm_stencil8, .depth32Float_stencil8]

let pixelFormatNameMap: [MTLPixelFormat : String] = [.invalid: "Invalid", .a8Unorm: "A8Unorm", .r8Unorm: "R8Unorm", .r8Snorm: "R8Snorm", .r8Uint: "R8Uint", .r8Sint: "R8Sint", .r16Unorm: "R16Unorm", .r16Snorm: "R16Snorm", .r16Uint: "R16Uint", .r16Sint: "R16Sint", .r16Float: "R16Float", .rg8Unorm: "RG8Unorm", .rg8Snorm: "RG8Snorm", .rg8Uint: "RG8Uint", .rg8Sint: "RG8Sint", .r32Uint: "R32Uint", .r32Sint: "R32Sint", .r32Float: "R32Float", .rg16Unorm: "RG16Unorm", .rg16Snorm: "RG16Snorm", .rg16Uint: "RG16Uint", .rg16Sint: "RG16Sint", .rg16Float: "RG16Float", .rgba8Unorm: "RGBA8Unorm", .rgba8Unorm_srgb: "RGBA8Unorm_sRGB", .rgba8Snorm: "RGBA8Snorm", .rgba8Uint: "RGBA8Uint", .rgba8Sint: "RGBA8Sint", .bgra8Unorm: "BGRA8Unorm", .bgra8Unorm_srgb: "BGRA8Unorm_sRGB", .rgb10a2Unorm: "RGB10A2Unorm", .rgb10a2Uint: "RGB10A2Uint", .rg11b10Float: "RG11B10Float", .rgb9e5Float: "RGB9E5Float", .rg32Uint: "RG32Uint", .rg32Sint: "RG32Sint", .rg32Float: "RG32Float", .rgba16Unorm: "RGBA16Unorm", .rgba16Snorm: "RGBA16Snorm", .rgba16Uint: "RGBA16Uint", .rgba16Sint: "RGBA16Sint", .rgba16Float: "RGBA16Float", .rgba32Uint: "RGBA32Uint", .rgba32Sint: "RGBA32Sint", .rgba32Float: "RGBA32Float", .bc1_rgba: "BC1_RGBA", .bc1_rgba_srgb: "BC1_RGBA_sRGB", .bc2_rgba: "BC2_RGBA", .bc2_rgba_srgb: "BC2_RGBA_sRGB", .bc3_rgba: "BC3_RGBA", .bc3_rgba_srgb: "BC3_RGBA_sRGB", .bc4_rUnorm: "BC4_RUnorm", .bc4_rSnorm: "BC4_RSnorm", .bc5_rgUnorm: "BC5_RGUnorm", .bc5_rgSnorm: "BC5_RGSnorm", .bc6H_rgbFloat: "BC6H_RGBFloat", .bc6H_rgbuFloat: "BC6H_RGBUfloat", .bc7_rgbaUnorm: "BC7_RGBAUnorm", .bc7_rgbaUnorm_srgb: "BC7_RGBAUnorm_sRGB", .gbgr422: "GBGR422", .bgrg422: "BGRG422", .depth32Float: "Depth32Float", .stencil8: "Stencil8", .depth24Unorm_stencil8: "Depth24Unorm_Stencil8", .depth32Float_stencil8: "Depth32Float_Stencil8"]

func pixelFormatMenu(_ includeNone: Bool) -> NSMenu {
    let result = NSMenu()
    if (includeNone) {
        result.addItem(NSMenuItem(title: "None", action: nil, keyEquivalent: ""))
    }
    for i in MTLPixelFormat.invalid.rawValue ... MTLPixelFormat.depth32Float_stencil8.rawValue {
        guard let format = MTLPixelFormat(rawValue: i) else {
            continue
        }
        guard let name = pixelFormatNameMap[format] else {
            continue
        }
        result.addItem(NSMenuItem(title: name, action: nil, keyEquivalent: ""))
    }
    return result
}

func pixelFormatToIndex(_ pixelFormat: MTLPixelFormat) -> Int {
    for i in 0 ..< pixelFormatMenuOrder.count {
        if pixelFormatMenuOrder[i] == pixelFormat {
            return i
        }
    }
    return 0
}

func indexToPixelFormat(_ i: Int) -> MTLPixelFormat? {
    guard i > 0 && i < pixelFormatMenuOrder.count else {
        return nil
    }
    return pixelFormatMenuOrder[i]
}
