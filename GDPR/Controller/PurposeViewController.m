//
//  PurposeViewController.m
//  GDPR
//
//  Created by unakayou on 10/24/18.
//  Copyright © 2018 unakayou. All rights reserved.
//

#import "PurposeViewController.h"
#import "VendorListViewController.h"

@interface PurposeViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIButton * backButton;            //返回
@property (nonatomic, strong) UIButton * saveButton;            //保存并返回
@property (nonatomic, strong) UIButton * showVendorListButton;  //显示供应商列表
@property (nonatomic, strong) UILabel  * titleLabel;            //权限标题

@property (nonatomic, strong) UILabel  * switchLabel;           //开关文字
@property (nonatomic, strong) UISwitch * consentSwitch;         //许可开关

@property (nonatomic, strong) UITableView * purposesTableview;
@property (nonatomic, strong) NSArray * purposesListDataSource;
@end

@implementation PurposeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    self.title = @"USER PRIVACY PREFERENCES";
    
    self.view = ({
        UIScrollView * scrollView = [[UIScrollView alloc] init];
        scrollView.backgroundColor = [UIColor whiteColor];
        scrollView;
    });
    
    self.titleLabel = ({
        UILabel * label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
        label.numberOfLines = 0;
        [self.view addSubview:label];
        label;
    });
    
    self.switchLabel = ({
        UILabel * label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"Active";
        label.textColor = THEME_BLUE;
        [self.view addSubview:label];
        label;
    });
    
    self.consentSwitch = ({
        UISwitch * theSwitch = [[UISwitch alloc] init];
        theSwitch.onTintColor = THEME_BLUE;
        theSwitch.on = YES;
        [theSwitch addTarget:self action:@selector(switchValueChange:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:theSwitch];
        theSwitch;
    });
    
    self.showVendorListButton = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"show full vendor list" forState:UIControlStateNormal];
        [button setTitleColor:THEME_BLUE forState:UIControlStateNormal];
        [self.view addSubview:button];
        [button addTarget:self action:@selector(showVendorListButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    
    self.purposesTableview = ({
        UITableView * tableview = [[UITableView alloc] init];
        tableview.tableFooterView = [UIView new];
        tableview.showsVerticalScrollIndicator = NO;
        tableview.showsHorizontalScrollIndicator = NO;
        tableview.delegate = self;
        tableview.dataSource = self;
        tableview.scrollEnabled = NO;
        [self.view addSubview:tableview];
        tableview;
    });
    
    self.backButton = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"BACK" forState:UIControlStateNormal];
        [self.view addSubview:button];

        button.titleLabel.numberOfLines = 0;
        button.layer.cornerRadius = 10.0f;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setBackgroundColor:THEME_BLUE];
        [button addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    
    self.saveButton = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"SAVE AND EXIT" forState:UIControlStateNormal];
        button.layer.borderWidth = 2.0f;
        button.layer.cornerRadius = 10.0f;
        button.layer.borderColor = THEME_BLUE.CGColor;
        [button setTitleColor:THEME_BLUE forState:UIControlStateNormal];
        [button addTarget:self action:@selector(saveButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        button;
    });
    
    self.purposesListDataSource = [[ConsentManager shareInstance] purposeItemArray];
    [self.purposesTableview reloadData];

    
    [self.purposesTableview selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    [self tableView:self.purposesTableview didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

- (void)switchValueChange:(UISwitch *)sender
{
    NSIndexPath * index = [self.purposesTableview indexPathForSelectedRow];
    PurposeItem * item = [self.purposesListDataSource objectAtIndex:index.row];
    item.bActive = sender.on;
    self.switchLabel.text = item.bActive ? @"Active" : @"Inactive";
}

- (void)showVendorListButtonClick:(UIButton *)sender
{
    VendorListViewController * vlvc = [[VendorListViewController alloc] init];
    [self.navigationController pushViewController:vlvc animated:YES];
}

- (void)saveButtonClick:(UIButton *)sender
{
    [self dismissAll];
    
    [[ConsentManager shareInstance] makeNewConsentString:ConsentStringSave_Purpose];
}

- (void)backButtonClick:(UIButton *)sender
{
    [self dismissAll];
}

- (void)dismissAll
{
    UIViewController *viewController = self;
    while (viewController.presentingViewController)
    {
        if ([viewController isKindOfClass:[viewController class]])
        {
            viewController = viewController.presentingViewController;
        }
        else
        {
            break;
        }
    }
    if (viewController)
    {
        [viewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PurposeItem * item = [self.purposesListDataSource objectAtIndex:indexPath.row];
    self.titleLabel.text = item.name;
    self.consentSwitch.on = item.bActive;
    self.switchLabel.text = item.bActive ? @"Active" : @"Inactive";
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(tableView.class)];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(tableView.class)];
        cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        
        cell.preservesSuperviewLayoutMargins = NO;
        cell.separatorInset = UIEdgeInsetsZero;
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    PurposeItem * item = self.purposesListDataSource[indexPath.row];
    cell.textLabel.text = item.name;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.purposesListDataSource.count;
}

#define CELL_HEIGHT 60
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGFloat x = SPACE, y = 0;
    CGFloat useWidth = self.view.frame.size.width - SPACE * 2;
    
    self.purposesTableview.frame = CGRectMake(x, y, useWidth / 3,self.purposesListDataSource.count * CELL_HEIGHT);
    x += self.purposesTableview.frame.size.width + SPACE;
        
    self.titleLabel.frame = CGRectMake(x, y, useWidth / 3 * 2 - SPACE , self.purposesTableview.frame.size.height / 3);
    y += self.titleLabel.frame.size.height + SPACE;
    
    self.switchLabel.frame = CGRectMake(x, y, useWidth / 3, self.consentSwitch.frame.size.height);
    x += self.switchLabel.frame.size.width + SPACE;
    
    self.consentSwitch.frame = CGRectMake(x, y, 0, 0);
    x = self.switchLabel.frame.origin.x; y += self.consentSwitch.frame.size.height + SPACE;
    
    self.showVendorListButton.frame = CGRectMake(x, y, self.titleLabel.frame.size.width, self.purposesTableview.frame.size.height - y);
    x = SPACE; y += self.showVendorListButton.frame.size.height + SPACE;
    
    self.backButton.frame = CGRectMake(x, y, (useWidth - SPACE) / 2, 50);
    x += self.backButton.frame.size.width + SPACE;
    
    self.saveButton.frame = CGRectMake(x, y, (useWidth - SPACE) / 2, 50);
    
    UIScrollView * scrollView = (UIScrollView *)self.view;
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, y + SPACE);
}

@end
