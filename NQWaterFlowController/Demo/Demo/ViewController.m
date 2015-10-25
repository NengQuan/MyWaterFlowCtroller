//
//  ViewController.m
//  Demo
//
//  Created by NengQuan on 15/10/25.
//  Copyright © 2015年 NengQuan. All rights reserved.
//  仿蘑菇街瀑布流Demo 

#import "ViewController.h"
#import "MyWaterFlowView.h"
#import "MyWaterFlowVIiewCell.h"
#import "MyShop.h"
#import "MJExtension.h"
#import "MyShopCell.h"
#import "MJRefresh.h"

@interface ViewController () <MyWaterFlowViewDataSource,MyWaterFlowViewDelegate>

@property (nonatomic,weak) MyWaterFlowView *waterflowView;

@property (nonatomic,strong) NSMutableArray *shops;

@end

@implementation ViewController

#pragma mark - 懒加载
- (NSMutableArray *)shops
{
    if (_shops == nil) {
        self.shops = [NSMutableArray array];
    }
    return _shops;
}

#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 瀑布流控件
    MyWaterFlowView *waterflowView = [[MyWaterFlowView alloc]init];
    waterflowView.frame = self.view.bounds;
    waterflowView.delegate = self;
    waterflowView.dataSource = self;
    waterflowView.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
    [self.view addSubview:waterflowView];
    self.waterflowView = waterflowView;
    
    // 集成刷新控件
    [self startRefresh];
    
}

- (void)startRefresh
{
    self.waterflowView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNew)];
    [self.waterflowView.header beginRefreshing];
    
    self.waterflowView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMore)];
    
}

- (void)loadMore
{
    // 只加载一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 初始化数据
        NSArray *shop = [MyShop objectArrayWithFilename:@"1.plist"];
        [self.shops addObjectsFromArray:shop];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 刷新瀑布流控件
        [self.waterflowView reloadDate];
        
        // 停止刷新
        [self.waterflowView.footer endRefreshing];
    });

}

- (void)loadNew
{
    // 只加载一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 初始化数据
        NSArray *shop = [MyShop objectArrayWithFilename:@"2.plist"];
        [self.shops addObjectsFromArray:shop];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 刷新瀑布流控件
        [self.waterflowView reloadDate];
        
        // 停止刷新
        [self.waterflowView.header endRefreshing];
    });
}

#pragma mark - 数据源方法
- (NSInteger)numberOfcellsinWaterFlowView:(MyWaterFlowView *)waterflowView
{
    return self.shops.count;
}

- (MyWaterFlowVIiewCell *)warterFlowView:(MyWaterFlowView *)waterFlowView cellAtIndex:(NSInteger)index
{
    static NSString *ID = @"cell";
    MyShopCell *cell = [waterFlowView dequeueReusabelCellWithIdentifile:ID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"MyShopCell" owner:nil options:nil]lastObject];
        cell.identifile = ID;
    }
    cell.shop = self.shops[index];
    
    return cell;
}

#pragma mark - 代理方法
- (CGFloat)waterflowView:(MyWaterFlowView *)waterflowView HeightForRowAtIndex:(NSInteger)index
{
    MyShop *shop = self.shops[index];
    //由cell的宽度和图片的宽高比计算
    return waterflowView.cellWidth * shop.h / shop.w;
}

- (void)waterflowView:(MyWaterFlowView *)waterflowView DidSelectRowAtIndex:(NSUInteger)index
{
    
}
@end
