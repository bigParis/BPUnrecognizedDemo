//
//  ViewController.m
//  BPUnrecognizedDemo
//
//  Created by yy on 16/6/2.
//  Copyright © 2016年 BP. All rights reserved.
//

#import "ViewController.h"
#import "MethodHook.h"
#import "TestObject.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [MethodHook hookNotRecognizeSelector];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    TestObject *testObject = [[TestObject alloc] init];
    [testObject performSelector:@selector(notExistSelector:test:) withObject:@(2) withObject:@(4)];
}
@end
