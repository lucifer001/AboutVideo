//
//  MoviePlayerView.m
//  Test
//
//  Created by Tianyu on 15/5/20.
//  Copyright (c) 2015年 com.hoolai. All rights reserved.
//

#import "MoviePlayerView.h"
#import <MediaPlayer/MediaPlayer.h>

#define HIDDEN_TIME (0.3)

@interface MoviePlayerView ()

@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIView *controlView;

@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *zoomBtn;

@property (strong, nonatomic) MPMoviePlayerViewController *movie;

@property (strong, nonatomic) NSTimer *hideTimer; // 控制器View消失倒计时
@property (assign, nonatomic) BOOL isZoomed; // 是否放大（横屏显示）

@property (strong, nonatomic) NSTimer *refreshTimer; // 刷新slider进度条

@end

@implementation MoviePlayerView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
    }
    
    return self;
}

- (void)awakeFromNib
{
    _movie = [[MPMoviePlayerViewController alloc] init];
    
    self.movie.view.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.movie.view.backgroundColor = [UIColor clearColor];
    
    self.movie.view.frame = self.bounds;
    
    self.movie.moviePlayer.backgroundView.backgroundColor = [UIColor blackColor];
    
    self.movie.moviePlayer.controlStyle = MPMovieControlStyleNone;
    
    self.movie.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    
    [self insertSubview:self.movie.view atIndex:0];
    
    {
//    NSArray *constraints1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[tempView]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(tempView)];
//    NSArray *constraints2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[tempView]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(tempView)];
//    [self addConstraints:constraints1];
//    [self addConstraints:constraints2];
    }
    
    [self runTimer];
    [self addRefreshSliderTimer];
}

#pragma mark - buttons

- (IBAction)clickPlayBtn:(id)sender
{
    [self stopTimer];
    [self runTimer];
    
    switch (self.movie.moviePlayer.playbackState) {
            
        case MPMoviePlaybackStateStopped:
        case MPMoviePlaybackStatePaused:
            [self.movie.moviePlayer play];
            break;
        case MPMoviePlaybackStatePlaying:
            [self.movie.moviePlayer pause];
            break;
        default:
            break;
    }
}

- (IBAction)clickZoomBtn:(id)sender
{
    [self stopTimer];
    [self runTimer];
    
    if (self.clickZoomBtnBlock) {
        
        self.isZoomed = !self.isZoomed;
        self.titleView.hidden = self.isZoomed;
        
        self.clickZoomBtnBlock();
    }
}

#pragma mark - show and hidden

- (void)runTimer
{
    _hideTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                                  target:self
                                                selector:@selector(hideControlView:)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)stopTimer
{
    if (self.hideTimer) {
        [self.hideTimer invalidate];
        self.hideTimer = nil;
    }
}

- (void)hideControlView:(NSTimer *)timer
{
    if (self.controlView.alpha == 1) {
        
        [UIView animateWithDuration:HIDDEN_TIME animations:^{
            self.controlView.alpha = 0;
            self.titleView.alpha = 0;
        } completion:^(BOOL finished) {
            [self stopTimer];
        }];
        
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.controlView.alpha == 1) {
        
        [UIView animateWithDuration:HIDDEN_TIME animations:^{
            self.controlView.alpha = 0;
            self.titleView.alpha = 0;
        }];
        
    } else {
        
        [UIView animateWithDuration:HIDDEN_TIME animations:^{
            self.controlView.alpha = 1;
            self.titleView.alpha = 1;
        } completion:^(BOOL finished) {
            [self stopTimer];
            [self runTimer];
        }];
        
    }

}

#pragma mark - systom notification

- (void)addPlayerNotification
{
    // 监听播放器的状态
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playDidChangeNotification:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:self.movie.moviePlayer];
    
    // 监听视频加载状态
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStatusNotification:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:self.movie.moviePlayer];
}

- (void)playDidChangeNotification:(NSNotification *)noti
{
    MPMoviePlayerController *player = noti.object;
    
    switch (player.playbackState) {
        case MPMoviePlaybackStatePlaying:
            NSLog(@"播放");
            [self.playBtn setTitle:@"暂停" forState:UIControlStateNormal];
            break;
        case MPMoviePlaybackStatePaused:
            NSLog(@"暂停");
            [self.playBtn setTitle:@"播放" forState:UIControlStateNormal];
            break;
        case MPMoviePlaybackStateStopped:
            NSLog(@"停止");
            [self.playBtn setTitle:@"播放" forState:UIControlStateNormal];
            break;
        case MPMoviePlaybackStateInterrupted:
            NSLog(@"中断");
            break;
        case MPMoviePlaybackStateSeekingForward:
            NSLog(@"下一个");
            break;
        case MPMoviePlaybackStateSeekingBackward:
            NSLog(@"前一个");
            break;
        default:
            break;
    }
    
}

- (void)loadStatusNotification:(NSNotification *)noti
{
    MPMoviePlayerController *player = noti.object;
    if (player.loadState == MPMovieLoadStatePlayable) {
        
        NSLog(@"视频加载完成");
        [self.playBtn setTitle:@"暂停" forState:UIControlStateNormal];
        
    }
}

#pragma mark - movie play

- (void)playWithURL:(NSURL *)url
{
    [self addPlayerNotification];
    
    self.movie.moviePlayer.contentURL = url;
    
    [self.movie.moviePlayer prepareToPlay];
    
    [self.movie.moviePlayer play];
}

#pragma mark - slider touch
- (IBAction)sliderDidChanged:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    NSLog(@"%f",slider.value);
}

- (IBAction)sliderBeginTouch:(id)sender
{
    NSLog(@"touch begin");
    [self.movie.moviePlayer pause];
}

- (IBAction)sliderEndTouch:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    NSLog(@"touch end  %f",slider.value);
    
    NSTimeInterval targetTime = self.movie.moviePlayer.duration * slider.value;
    self.movie.moviePlayer.currentPlaybackTime = targetTime;
    [self.movie.moviePlayer play];
}

- (void)addRefreshSliderTimer
{
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshProgress:) userInfo:nil repeats:YES];
    [self.refreshTimer fire];
}

- (void)refreshProgress:(NSTimer *)timer
{
    NSTimeInterval currentPlayTime = self.movie.moviePlayer.currentPlaybackTime;
    NSTimeInterval movieTotalTime = self.movie.moviePlayer.duration;
    CGFloat progress = currentPlayTime / movieTotalTime;
    
    /*
    // 可播放的进度
    NSTimeInterval playableDuration = self.movie.moviePlayer.playableDuration;
    CGFloat bufferProgress = playableDuration / movieTotalTime;
    */
    
    self.slider.value = progress;
}


@end
