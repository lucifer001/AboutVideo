//
//  GetImageViewController.m
//  Test
//
//  Created by Tianyu on 15/5/21.
//  Copyright (c) 2015年 com.hoolai. All rights reserved.
//

#import "GetImageViewController.h"
#import "SelectPicView.h"

#define TEST_URL @"http://220.194.199.184/3/k/y/q/p/kyqpkuuhqfbqbquxhfzlujolmxgyww/dd.yinyuetai.com/mb_52006C08.mp4?sc=a02b2f751b0b2977&br=547&rd=Android"

@interface GetImageViewController ()

@property (strong, nonatomic) UIImageView *imgView;

@end

@implementation GetImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"金熊" ofType:@"mp4"]];
//    NSURL *url = [NSURL URLWithString:TEST_URL];
    
    _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 74, CGRectGetWidth([UIScreen mainScreen].bounds) - 20, 200)];
    [self.view addSubview:self.imgView];
    
    __weak GetImageViewController *blockSelf = self;
    
    SelectPicView *seletView = [[SelectPicView alloc] initWithFrame:CGRectMake(0, 300, CGRectGetWidth([UIScreen mainScreen].bounds), 50)];
    seletView.seletImgBlock = ^(UIImage *img){
        [blockSelf.imgView setImage:img];
    };
    [seletView getVideoPreViewImageWithURL:url compate:^(BOOL finished) {
        if (finished) {
            NSLog(@"视频处理完成");
        } else {
            NSLog(@"视频处理失败，请检测网络配置");
        }
    }];
    [self.view addSubview:seletView];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
