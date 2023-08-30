//
//  NINEPATCHViewController.m
//  iOSNinePatch
//
//  Created by ipangth on 08/30/2023.
//  Copyright (c) 2023 ipangth. All rights reserved.
//

#import "NINEPATCHViewController.h"
#import <iOSNinePatch/PNGNinePatch.h>

@interface NINEPATCHViewController ()

@property (nonatomic, strong) UIImageView *imageView1;
@property (nonatomic, strong) UIImageView *imageView2;

@property (nonatomic, assign) NSInteger imageScale;

@end

@implementation NINEPATCHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [actionButton setTitle:@"拉伸" forState:UIControlStateNormal];
    [actionButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    actionButton.frame = CGRectMake(50, 50, 100, 40);
    [actionButton addTarget:self action:@selector(onAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:actionButton];
    
    
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(20, 100, 329/3, 193/3)];
    [self.view addSubview:view];
    self.imageView1 = view;
    
    UIImageView *view2 = [[UIImageView alloc] initWithFrame:CGRectMake(20, 100 + view.frame.size.height + 20, 271, 403)];
    [self.view addSubview:view2];
    self.imageView2 = view2;
}


- (void)onAction
{
    NSString *file = [[NSBundle mainBundle] pathForResource:@"top1" ofType:@"png"];
    NSData *data = [NSData dataWithContentsOfFile:file];
    PNGNinePatch *ninePatch = [PNGNinePatch ninePatchWithPNGFileData:data];
    UIEdgeInsets insets = [ninePatch resizableCapInsets];
    NSLog(@"%@, %@", NSStringFromUIEdgeInsets(insets), file);
    
    
    UIImage *image = [UIImage imageWithData:data];
    
    
    self.imageScale = 3;
    
    CGFloat ratio = 1.0 / self.imageScale;
    CGSize scaleSize = CGSizeMake(image.size.width * ratio, image.size.height * ratio);
    UIImage *scaleImage = [self resizedImageWithBounds:scaleSize image:image];
    
    // 构造一个像素的可拉伸区域 + 3是预留多一些拉伸区域
    UIEdgeInsets capInsets;
    capInsets.top = insets.top * ratio + 3;
    capInsets.left = insets.left * ratio + 3;
    capInsets.bottom = scaleSize.height - capInsets.top - 1;
    capInsets.right = scaleSize.width - capInsets.left - 1;
    
    
    self.imageView1.image = image;
    self.imageView2.image = [scaleImage resizableImageWithCapInsets:capInsets resizingMode:UIImageResizingModeStretch];
    
    
}

- (UIImage *)resizedImageWithBounds:(CGSize)bounds image:(UIImage *)image {
    CGFloat horizontalRatio = bounds.width / image.size.width;
    CGFloat verticalRatio = bounds.height / image.size.height;
    CGFloat ratio = MIN(horizontalRatio, verticalRatio);
    
    CGSize newSize = CGSizeMake(image.size.width * ratio, image.size.height * ratio);
    
    //creates a new image context and draws the image into that
    UIGraphicsBeginImageContextWithOptions(newSize, NO, self.imageScale);
    
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
