//
//  ViewController.m
//  Test
//
//  Created by Tianyu on 15/5/18.
//  Copyright (c) 2015年 com.hoolai. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MoviePlayerView.h"

#define TEST_URL @"http://220.194.199.184/3/k/y/q/p/kyqpkuuhqfbqbquxhfzlujolmxgyww/dd.yinyuetai.com/mb_52006C08.mp4?sc=a02b2f751b0b2977&br=547&rd=Android"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) MoviePlayerView *moviePlayerView;
@property (assign, nonatomic) BOOL isZoom;
@property (strong, nonatomic) UIView *headerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 250)];
    self.headerView.backgroundColor = [UIColor redColor];
    
    self.moviePlayerView = [[NSBundle mainBundle] loadNibNamed:@"MoviePlayerView" owner:nil options:nil][0];
    self.moviePlayerView.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 250);
    __weak ViewController *blockSelf = self;
    self.moviePlayerView.clickZoomBtnBlock = ^{
        
        if (blockSelf.isZoom) {
            
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
            
            [UIView animateWithDuration:0.3 animations:^{
                
                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
                blockSelf.moviePlayerView.transform = CGAffineTransformMakeRotation(M_PI*2);
                blockSelf.moviePlayerView.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 250);
                [blockSelf.headerView addSubview:blockSelf.moviePlayerView];
                
            } completion:^(BOOL finished) {
                blockSelf.isZoom = NO;
            }];
            
            /*
            [blockSelf postNotification:NO];
            blockSelf.isZoom = NO;
            */
        } else {
            
            
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
            
            [UIView animateWithDuration:0.3 animations:^{
                
                [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
                blockSelf.moviePlayerView.transform = CGAffineTransformMakeRotation(M_PI/2);
                blockSelf.moviePlayerView.frame = blockSelf.view.bounds;
                [[UIApplication sharedApplication].keyWindow addSubview:blockSelf.moviePlayerView];
                
            } completion:^(BOOL finished) {
                blockSelf.isZoom = YES;
            }];
            
            /*
            [blockSelf postNotification:YES];
            blockSelf.isZoom = YES;
             */
        }
        
        
    };

    [self.headerView addSubview:self.moviePlayerView];
    self.tableView.tableHeaderView = self.headerView;
}

- (void)viewDidAppear:(BOOL)animated
{
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"金熊" ofType:@"mp4"]];
//    NSURL *url = [NSURL URLWithString:TEST_URL];
    [self.moviePlayerView playWithURL:url];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark - Table View Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = @"test";
    return cell;
}

// 手动旋转（自动旋转开启的情况下）
- (void)postNotification:(BOOL)flag
{
    if ([[UIDevice currentDevice]respondsToSelector:@selector(setOrientation:)])
    {
        NSNumber *num = [[NSNumber alloc]initWithInt:(flag?UIInterfaceOrientationLandscapeRight:UIInterfaceOrientationPortrait)];
        [[UIDevice currentDevice]performSelector:@selector(setOrientation:)withObject:(id)num];
        [UIViewController attemptRotationToDeviceOrientation];//这行代码是关键
    }
    SEL selector = NSSelectorFromString(@"setOrientation:");
    NSInvocation *invocation =[NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:[UIDevice currentDevice]];
    int val = flag ? UIInterfaceOrientationLandscapeRight:UIInterfaceOrientationPortrait;
    [invocation setArgument:&val atIndex:2];
    [invocation retainArguments];
    [invocation invoke];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
