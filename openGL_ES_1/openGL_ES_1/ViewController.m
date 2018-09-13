//
//  ViewController.m
//  openGL_ES_1
//
//  Created by osborn on 2018/9/13.
//  Copyright © 2018年 osborn. All rights reserved.
//

#import "ViewController.h"

#import "GLView.h"

@interface ViewController ()

@property (nonatomic, strong) GLView *glView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.glView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (GLView *)glView {
    if (!_glView) {
        _glView = [[GLView alloc]initWithFrame:self.view.frame];
    }
    return _glView;
}



@end
