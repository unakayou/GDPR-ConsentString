//
//  ViewController.m
//  GDPR
//
//  Created by unakayou on 10/23/18.
//  Copyright © 2018 unakayou. All rights reserved.
//

#import "ViewController.h"
#import "WelcomeViewController.h"

@interface ViewController ()
@property (nonatomic, strong) UIButton * showToolButton;
@property (nonatomic, strong) UILabel * consentStringLabel;
@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated
{
    self.consentStringLabel.text = [[ConsentManager shareInstance] consentStringItem].valueString;
    [self viewDidLayoutSubviews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.view = ({
        UIScrollView * scrollView = [[UIScrollView alloc] init];
        scrollView.backgroundColor = [UIColor whiteColor];
        scrollView;
    });
    
    self.showToolButton = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"Show GDPR Consent Tool" forState:UIControlStateNormal];
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        button.layer.cornerRadius = 10.0f;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setBackgroundColor:THEME_BLUE];
        [button addTarget:self action:@selector(jumpWelcomViewcontroller) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        button;
    });
    
    self.consentStringLabel = ({
        UILabel * label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor groupTableViewBackgroundColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.numberOfLines = 0;
        [self.view addSubview:label];
        label;
    });
}

- (void)jumpWelcomViewcontroller
{
    WelcomeViewController * wvc = [[WelcomeViewController alloc] init];
    UINavigationController * navc = [[UINavigationController alloc] initWithRootViewController:wvc];
    [self presentViewController:navc animated:YES completion:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGFloat x = SPACE, y = self.view.frame.size.height / 3;
    self.showToolButton.frame = CGRectMake(x, y, self.view.frame.size.width - SPACE * 2, SPACE * 4);
    y += self.showToolButton.frame.size.height + SPACE * 3;
    
    CGFloat contentStringLableHeight = [self.consentStringLabel sizeThatFits:CGSizeMake(self.view.frame.size.width - SPACE * 2, MAXFLOAT)].height;
    self.consentStringLabel.frame = CGRectMake(x, y, self.view.frame.size.width - SPACE * 2, contentStringLableHeight < 40 ? 40 : contentStringLableHeight);
    y += self.consentStringLabel.frame.size.height;
    
    UIScrollView * scrollView = (UIScrollView *)self.view;
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, y + SPACE);
}

@end
