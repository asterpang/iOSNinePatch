
//
//  PNGNinePatch.m
//
//
//  Created by asterpang on 2023/7/20.
//  Copyright © 2023 asterpang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PNGNinePatch.h"

// test

static char bytes[8] = {0};


@implementation PNGNinePatch
// https://dev.exiv2.org/projects/exiv2/wiki/The_Metadata_in_PNG_files
// https://android.googlesource.com/platform/frameworks/base/+/56a2301c7a1169a0692cadaeb48b9a6385d700f5/include/androidfw/ResourceTypes.h

+ (instancetype)ninePatchWithPNGFileData:(NSData *)data
{
    if (data.length < 32) {
        return nil;
    }
    int index = 0;

    // 先判断是否png图片
    if ([[self class] readInt32:data fromIndex:&index] != 0x89504e47 || [[self class] readInt32:data fromIndex:&index] != 0x0D0A1A0A) {
        // 不是png图片，不再处理
        return nil;
    }

    const char ihdr[4] = {'I', 'H', 'D', 'R'};

    // NinePatch的chunk type
    // The PNG chunk type is "npTc"
    const char npTc[4] = {'n', 'p', 'T', 'c'};

    BOOL hasNinePatchChunk = NO;

    int32_t chunk_length = 0;

    int32_t width = 0;
    int32_t heigth = 0;

    while (YES) {
        if (index >= data.length - 8) {
            break;
        }
        // 获取chunk长度
        chunk_length = [[self class] readInt32:data fromIndex:&index];

        // 获取chunk type标记
        [data getBytes:bytes range:NSMakeRange(index, 4)];
        index += 4;

        if (memcmp(bytes, ihdr, 4) == 0) {
            // read width height
            width = [[self class] readInt32:data fromIndex:&index];
            heigth = [[self class] readInt32:data fromIndex:&index];
            index += chunk_length + 4 - 8;
            continue;
        }

        if (memcmp(bytes, npTc, 4) == 0) {
            // 表示读取到了NinePatch信息,index之后的数据是chunk data
            hasNinePatchChunk = YES;
            break;
        }

        // 跳过本chunk(数据长度 chunk_length + CRC 4bytes)
        index += chunk_length + 4;
    }

    PNGNinePatch *ninePatch = nil;

    if (hasNinePatchChunk && chunk_length > 0 && data.length > index + chunk_length) {
        ninePatch = PNGNinePatch.new;
        ninePatch.width = width;
        ninePatch.height = heigth;

        int8_t wasDeserialized = [[self class] readInt8:data fromIndex:&index];
        if (wasDeserialized == 0) {
            // nothing to do
        }

        ninePatch.numXDivs = [[self class] readInt8:data fromIndex:&index];
        ninePatch.numYDivs = [[self class] readInt8:data fromIndex:&index];
        ninePatch.numColors = [[self class] readInt8:data fromIndex:&index];

        // skip xDivsOffset/yDivsOffset
        index += 4 + 4;

        ninePatch.paddingLeft = [[self class] readInt32:data fromIndex:&index];
        ninePatch.paddingRight = [[self class] readInt32:data fromIndex:&index];
        ninePatch.paddingTop = [[self class] readInt32:data fromIndex:&index];
        ninePatch.paddingBottom = [[self class] readInt32:data fromIndex:&index];

        // skip colorOffset
        index += 4;

        // now xDivs，即点九图上方黑点标记数组，横向可拉伸区域
        NSMutableArray<NSNumber *> *xDivsArray = NSMutableArray.new;
        for (int count = 0; count < ninePatch.numXDivs; count++) {
            [data getBytes:bytes range:NSMakeRange(index, 4)];
            index += 4;
            int32_t x = ntohl(*(int32_t *)bytes);
            [xDivsArray addObject:@(x)];
        }

        // now yDivs，即点九图左边黑点标记数组，纵向可拉伸区域
        NSMutableArray<NSNumber *> *yDivsArray = NSMutableArray.new;
        for (int count = 0; count < ninePatch.numYDivs; count++) {
            [data getBytes:bytes range:NSMakeRange(index, 4)];
            index += 4;
            int32_t y = ntohl(*(int32_t *)bytes);
            [yDivsArray addObject:@(y)];
        }
        ninePatch.xDivsArray = xDivsArray;
        ninePatch.yDivsArray = yDivsArray;
    }

    return ninePatch;
}

- (UIEdgeInsets)resizableCapInsets
{
    if (self.xDivsArray.count < 2 || self.yDivsArray.count < 2) {
        return UIEdgeInsetsZero;
    }
    // 可以是多段分割，指定拉伸/压缩，不过我们约定需求没那么复杂，只需要拉伸第一段区域
    // 如需多段处理，则更该代码
    int32_t xStart = self.xDivsArray[0].intValue;
    int32_t xEnd = self.xDivsArray[1].intValue;
    int32_t yStart = self.yDivsArray[0].intValue;
    int32_t yEnd = self.yDivsArray[1].intValue;

    if (xEnd < xStart || yEnd < yStart) {
        return UIEdgeInsetsZero;
    }

    UIEdgeInsets insets;
    insets.top = yStart;
    insets.left = xStart;
    insets.bottom = self.height - yEnd;
    insets.right = self.width - xEnd;

    if (insets.bottom < 0 || insets.right < 0) {
        return UIEdgeInsetsZero;
    }

    return insets;
}

+ (int8_t)readInt8:(NSData *)data fromIndex:(int *)index
{
    [data getBytes:bytes range:NSMakeRange(*index, 1)];
    *index += 1;
    return (int8_t)bytes[0];
}

+ (int32_t)readInt32:(NSData *)data fromIndex:(int *)index
{
    [data getBytes:bytes range:NSMakeRange(*index, 4)];
    *index += 4;
    return ntohl(*(int32_t *)bytes);
}

@end
