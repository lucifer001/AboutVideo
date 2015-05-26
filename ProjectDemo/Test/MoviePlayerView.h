//
//  MoviePlayerView.h
//  Test
//
//  Created by Tianyu on 15/5/20.
//  Copyright (c) 2015年 com.hoolai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ClickBtnBlock)(void);

@interface MoviePlayerView : UIView

@property (copy, nonatomic) ClickBtnBlock clickZoomBtnBlock;

- (void)playWithURL:(NSURL *)url;

@end
