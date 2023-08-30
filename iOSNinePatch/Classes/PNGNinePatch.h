//
//  PNGNinePatch.h
//  podDemo
//
//  Created by asterpang on 2023/7/20.
//  Copyright © 2023 asterpang. All rights reserved.
//

#ifndef PNGNinePatch_h
#define PNGNinePatch_h

NS_ASSUME_NONNULL_BEGIN


@interface PNGNinePatch : NSObject

@property (nonatomic, assign) int32_t width;
@property (nonatomic, assign) int32_t height;

@property (nonatomic, assign) int8_t numXDivs;
@property (nonatomic, assign) int8_t numYDivs;
@property (nonatomic, assign) int8_t numColors;

@property (nonatomic, assign) int32_t paddingLeft;
@property (nonatomic, assign) int32_t paddingRight;
@property (nonatomic, assign) int32_t paddingTop;
@property (nonatomic, assign) int32_t paddingBottom;

@property (nonatomic, strong) NSArray<NSNumber *> *xDivsArray;
@property (nonatomic, strong) NSArray<NSNumber *> *yDivsArray;


+ (nullable instancetype)ninePatchWithPNGFileData:(NSData *)data;

/// 获取点九图bitmap中的可拉伸区域，如果返回UIEdgeInsetsZero，则表示没有可以拉伸的区域
/// 点九图可能包含多个不连续的可拉伸区域，本函数只取第一个
- (UIEdgeInsets)resizableCapInsets;

@end


NS_ASSUME_NONNULL_END

#endif /* PNGNinePatch_h */
