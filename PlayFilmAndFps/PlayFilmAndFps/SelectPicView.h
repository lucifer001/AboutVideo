//
//  SelectPicView.h
//  ProjectDemo
//
//  Created by Tianyu on 15/5/21.
//  Copyright (c) 2015年 com.hoolai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SeletImage)(UIImage *img);

@interface SelectPicView : UIView

@property (copy, nonatomic) SeletImage seletImgBlock;

- (void)getVideoPreViewImageWithURL:(NSURL *)videoPath compate:(void(^)(BOOL finished))compate;

@end
