//
//  ViewController.m
//  openGL_ES_2
//
//  Created by zfan on 2018/9/16.
//  Copyright © 2018年 zfan. All rights reserved.
//

#import "ViewController.h"

#import "GLTextureView.h"

@interface ViewController ()
@property (nonatomic,strong) GLTextureView *textureView;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.textureView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark --

- (GLTextureView *)textureView {
    if (!_textureView) {
        _textureView = [[GLTextureView alloc]initWithFrame:self.view.frame];
    }
    return _textureView;
}




@end
