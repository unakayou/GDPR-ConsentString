//
//  VendorListViewController.m
//  GDPR
//
//  Created by unakayou on 10/23/18.
//  Copyright © 2018 unakayou. All rights reserved.
//

#import "VendorListViewController.h"
#import "VendorTableViewCell.h"
#import "ViewController.h"

@interface VendorListViewController ()
@property (nonatomic, strong) UILabel * titleLabel; //标题
@property (nonatomic, strong) UILabel * infoLabel;  //介绍
@end

@implementation VendorListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.navigationItem.rightBarButtonItem = ({
        UIBarButtonItem * rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                                style:UIBarButtonItemStyleDone
                                                                               target:self
                                                                               action:@selector(doneClick:)];
        rightBarButtonItem;
    });
    
    self.view = ({
        UIScrollView * scrollView = [[UIScrollView alloc] init];
        scrollView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        scrollView;
    });
    
    self.titleLabel = ({
        UILabel * label = [[UILabel alloc] init];
        label.text = @"Our Partners";
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:20];
        [self.view addSubview:label];
        label;
    });
    
    self.infoLabel = ({
        UILabel * label = [[UILabel alloc] init];
        label.text = @"Help us provide you with a better online experience! Our partners set cookies and collect information from your browser across the web to provide you with website content,deliver relevant advertising and understand web audiences.";
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:12];
        label.numberOfLines = 0;
        [self.view addSubview:label];
        label;
    });
    
    self.vendorTableView = ({
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
    
    self.vendorListDataSource = [[ConsentManager shareInstance] vendorArray];
    [self.vendorTableView reloadData];
}

- (void)doneClick:(UIBarButtonItem *)sender
{
    [[ConsentManager shareInstance] makeNewConsentString:ConsentStringSave_Vendor];

    [self.navigationController popViewControllerAnimated:YES];
}

- (NSDictionary *)readLocalFileWithName:(NSString *)name
{
    NSString * path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    NSData * data = [[NSData alloc] initWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    VendorTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(tableView.class)];
    if (cell == nil)
    {
        cell = [[VendorTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(tableView.class)];
    }
    VendorItem * item = self.vendorListDataSource[indexPath.row];
    cell.textLabel.text = item.name;
    cell.accessoryType  = item.selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.vendorListDataSource.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    VendorItem * item = self.vendorListDataSource[indexPath.row];
    item.selected = !item.selected;
    [tableView reloadData];
}

#define CELL_HEIGHT 50
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    CGFloat useWidth = self.view.frame.size.width - SPACE * 2;
    
    CGFloat x = SPACE, y = SPACE;
    CGFloat titleLabelHeight = [self.titleLabel sizeThatFits:CGSizeMake(useWidth, MAXFLOAT)].height;
    self.titleLabel.frame = CGRectMake(x, y, useWidth, titleLabelHeight);
    y += self.titleLabel.frame.size.height + SPACE;
    
    CGFloat infoLabelHeight = [self.infoLabel sizeThatFits:CGSizeMake(useWidth, MAXFLOAT)].height;
    self.infoLabel.frame = CGRectMake(x, y, useWidth, infoLabelHeight);
    y += infoLabelHeight + SPACE;
    
    self.vendorTableView.frame = CGRectMake(x, y, useWidth, self.vendorListDataSource.count * CELL_HEIGHT);
    y += self.vendorTableView.frame.size.height;
    
    UIScrollView * scrollView = (UIScrollView *)self.view;
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, y + SPACE);
}

@end
