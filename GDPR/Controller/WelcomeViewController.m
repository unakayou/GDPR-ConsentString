//
//  WelcomeViewController.m
//  GDPR
//
//  Created by unakayou on 10/24/18.
//  Copyright © 2018 unakayou. All rights reserved.
//

#import "WelcomeViewController.h"
#import "PurposeViewController.h"
#import "VendorListViewController.h"

@interface WelcomeViewController ()
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * infoLabel;
@property (nonatomic, strong) UIButton * settingButton;
@property (nonatomic, strong) UIButton * backButton;
@end

@implementation WelcomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.view = ({
        UIScrollView * scrollView = [[UIScrollView alloc] init];
        scrollView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        scrollView;
    });
    
    self.titleLabel = ({
        UILabel * label = [[UILabel alloc] init];
        label.text = @"Thanks for using AdView";
        label.textAlignment = NSTextAlignmentCenter;
        [label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
        [self.view addSubview:label];
        label;
    });
    
    self.infoLabel = ({
        UILabel * label = [[UILabel alloc] init];
        label.text = @"In order to run a successful SDK,we and certain third parties are setting cookies and accessing and storing information on you device for various purposes.Various third parties are also collecting data to show you personalized content and ads.Some third parties require your consent to collect data to serve you personalized content and ads.";
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:15];
        label.numberOfLines = 0;
        [self.view addSubview:label];
        label;
    });
    
    self.settingButton = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"MANAGE YOUR CHOICES" forState:UIControlStateNormal];
        [self.view addSubview:button];
        button.layer.cornerRadius = 10.0f;
        button.layer.borderWidth = 2.0f;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setTitleColor:THEME_BLUE forState:UIControlStateNormal];
        button.layer.borderColor = THEME_BLUE.CGColor;
        button.titleLabel.numberOfLines = 0;
        [button addTarget:self action:@selector(reviewVendorList) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    
    self.backButton = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"GOT IT,THANKS!" forState:UIControlStateNormal];
        button.titleLabel.numberOfLines = 0;
        button.layer.cornerRadius = 10.0f;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setBackgroundColor:THEME_BLUE];
        [button addTarget:self action:@selector(dismissWelComeViewController) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        button;
    });
}

- (void)reviewVendorList
{    
    PurposeViewController * pvc = [[PurposeViewController alloc] init];
    UINavigationController * navc = [[UINavigationController alloc] initWithRootViewController:pvc];
    [self presentViewController:navc animated:YES completion:nil];
}

- (void)dismissWelComeViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGFloat useWidth = self.view.frame.size.width - SPACE * 2;
    CGFloat x = SPACE, y = SPACE;
    
    CGFloat titleLabelHeight = [self.titleLabel sizeThatFits:CGSizeMake(useWidth, MAXFLOAT)].height;
    self.titleLabel.frame = CGRectMake(x, y, useWidth, titleLabelHeight);
    y += titleLabelHeight + SPACE;
    
    CGFloat infoLabelHeight = [self.infoLabel sizeThatFits:CGSizeMake(useWidth, MAXFLOAT)].height;
    self.infoLabel.frame = CGRectMake(x, y, useWidth, infoLabelHeight);
    y += infoLabelHeight + SPACE;
    
    CGFloat buttonWidth = (useWidth - SPACE) / 2;
    self.backButton.frame = CGRectMake(x, y, buttonWidth, buttonWidth / 1.5);
    x += buttonWidth + SPACE;
    
    self.settingButton.frame = CGRectMake(x, y, buttonWidth, buttonWidth / 1.5);
}
@end
