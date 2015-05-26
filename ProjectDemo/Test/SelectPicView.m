//
//  SelectPicView.m
//  ProjectDemo
//
//  Created by Tianyu on 15/5/21.
//  Copyright (c) 2015年 com.hoolai. All rights reserved.
//

#import "SelectPicView.h"

#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetImageGenerator.h>
#import <AVFoundation/AVTime.h>
#import <AVFoundation/AVFoundation.h>

#import <mach/mach_time.h>

@interface SelectPicView ()

@property (strong, nonatomic) NSMutableArray *imgAry;

@end

@implementation SelectPicView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

/**
*  调试用
*
*/
CGFloat BNRTimeBlock (void (^block)(void)) {
    mach_timebase_info_data_t info;
    if (mach_timebase_info(&info) != KERN_SUCCESS) return -1.0;
    
    uint64_t start = mach_absolute_time ();
    block ();
    uint64_t end = mach_absolute_time ();
    uint64_t elapsed = end - start;
    
    uint64_t nanos = elapsed * info.numer / info.denom;
    return (CGFloat)nanos / NSEC_PER_SEC;
    
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _imgAry = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)getVideoPreViewImageWithURL:(NSURL *)videoPath compate:(void (^)(BOOL))compate
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoPath options:nil];
        
        NSArray *trackAry = [asset tracksWithMediaType:AVMediaTypeVideo];
        
        if (trackAry.count > 0) {
            
            AVAssetTrack *videoTrack = trackAry[0];
            
            // 每秒的帧数
            float fps = [videoTrack nominalFrameRate];
            
            // 视频总时长（s）
            NSInteger totalTime = asset.duration.value / asset.duration.timescale;

            AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            gen.appliesPreferredTrackTransform = YES;
            gen.requestedTimeToleranceAfter = kCMTimeZero;
            gen.requestedTimeToleranceBefore = kCMTimeZero;
            
            NSError *error = nil;
            CMTime actualTime;
            
            for (float i = 0; i < totalTime; i++) {
                
                CMTime time = CMTimeMakeWithSeconds(i, totalTime * fps);
                CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
                UIImage *img = [[UIImage alloc] initWithCGImage:image];
                CGImageRelease(image);
                [self.imgAry addObject:img];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                for (int i = 0; i < self.imgAry.count; i++) {
                    
                    CGFloat width = CGRectGetWidth(self.bounds)/self.imgAry.count;
                    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(i * width, 0, width, CGRectGetHeight(self.bounds))];
                    imgView.tag = i;
                    [imgView setImage:self.imgAry[i]];
                    [self addSubview:imgView];
                }
                
                if (compate) {
                    compate(YES);
                }
                
                self.seletImgBlock(self.imgAry[0]);
            });
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (compate) {
                    compate(NO);
                }
            });
            
        }
        
    });

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self];
    
    if (self.imgAry.count > 0) {
        
        CGFloat width = CGRectGetWidth(self.bounds)/self.imgAry.count;
        
        if (point.x <= width) {
            
            self.seletImgBlock(self.imgAry[0]);
            
        } else {
            
            NSInteger index = point.x/width;
            
            self.seletImgBlock(self.imgAry[index]);
        }
    }
}


@end
