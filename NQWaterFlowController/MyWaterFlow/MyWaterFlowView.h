//
//  MyWaterFlowView.h
//  瀑布流
//
//  Created by NengQuan on 15/10/24.
//  Copyright © 2015年 NengQuan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyWaterFlowView,MyWaterFlowVIiewCell;

typedef enum : NSUInteger {
    MyWaterFlowViewTop,
    MyWaterFlowViewButtom,
    MyWaterFlowViewLeft,
    MyWaterFlowViewRight,
    MyWaterFlowViewRow,
    MyWaterFlowViewCulumn,
} MyWaterFlowViewMaginType;

/**
 *  数据源
 */
@protocol MyWaterFlowViewDataSource <NSObject>

@required

/** 一共有多少个cell **/
- (NSInteger)numberOfcellsinWaterFlowView:(MyWaterFlowView *)waterflowView;

/** 返回每个位置对应的cell **/
- (MyWaterFlowVIiewCell *)warterFlowView:(MyWaterFlowView *)waterFlowView cellAtIndex:(NSInteger)index;

@optional
/** 一共有几列 **/
- (NSInteger)numberOFColumnInWaterflowView:(MyWaterFlowView *)waterFlowView;

@end

/**
 *  代理方法
 */
@protocol MyWaterFlowViewDelegate <UIScrollViewDelegate>

@optional
/** 返回cell的高度 **/
- (CGFloat)waterflowView:(MyWaterFlowView *)waterflowView HeightForRowAtIndex:(NSInteger)index;

/** 选中index位置的cell **/
- (void)waterflowView:(MyWaterFlowView *)waterflowView DidSelectRowAtIndex:(NSInteger)index;

/** 返回cell的间距 **/
- (CGFloat)waterflowVIew:(MyWaterFlowView *)waterflowView MaginForTtype:(MyWaterFlowViewMaginType)type;

@end
@interface MyWaterFlowView : UIScrollView

@property (nonatomic,weak) id <MyWaterFlowViewDataSource> dataSource;

@property (nonatomic,weak) id <MyWaterFlowViewDelegate> delegate;

- (void)reloadDate;

/**
 *  根据标识去缓存池中查找可循环利用的cell
 */
- (id)dequeueReusabelCellWithIdentifile:(NSString *)identifile;

@end
