//
//  MyWaterFlowView.m
//  瀑布流
//
//  Created by NengQuan on 15/10/24.
//  Copyright © 2015年 NengQuan. All rights reserved.
//

#import "MyWaterFlowView.h"
#import "UIView+Extension.h"
#import "MyWaterFlowVIiewCell.h"

#define MyWaterFlowViewDefaultColumns 3
#define MyWaterFlowViewDefaultMagin 5
#define MyWaterFlowViewDefaultHeight 80

@interface MyWaterFlowView ()
/**
 *  所有cell的frame数据
 */
@property (nonatomic,strong) NSMutableArray *cellFrames;
/**
 *  正在展示的cell
 */
@property (nonatomic,strong) NSMutableDictionary *displayingCells;

/**
 *  缓存池（存放离开屏幕的cell）
 */
@property (nonatomic,strong) NSMutableSet *reusableCells;

@end
@implementation MyWaterFlowView

- (NSMutableArray *)cellFrames
{
    if (_cellFrames == nil) {
        self.cellFrames = [NSMutableArray array];
    }
    return _cellFrames;
}

- (NSMutableDictionary *)displayingCells
{
    if (_displayingCells == nil){
        self.displayingCells = [NSMutableDictionary dictionary];
    }
    return _displayingCells;
}

- (NSMutableSet *)reusableCells
{
    if (_reusableCells == nil) {
        self.reusableCells = [NSMutableSet set];
    }
    return _reusableCells;
}

#pragma mark - 公共接口
- (void)reloadDate
{
    // cell的总数'
    int numberOfCells = [self.dataSource numberOfcellsinWaterFlowView:self];
    
    // 总列数
    int numerOfColumns = [self numberOfColumns];
    
    // 间距
    CGFloat topM = [self maginForType:MyWaterFlowViewTop];
    CGFloat buttomM = [self maginForType:MyWaterFlowViewButtom];
    CGFloat leftM = [self maginForType:MyWaterFlowViewLeft];
    CGFloat rightM = [self maginForType:MyWaterFlowViewRight];
    CGFloat columnM = [self maginForType:MyWaterFlowViewCulumn];
    CGFloat rowM = [self maginForType:MyWaterFlowViewRow];
    
    // cell 的宽度
    CGFloat cellW = (self.width - leftM - rightM - (numerOfColumns - 1) * columnM) / numerOfColumns;
    
    // 存储所有列的最大Y值
    CGFloat maxYOfColumns[numerOfColumns];
    for (int i = 0 ; i < numerOfColumns ; i++) {
        maxYOfColumns[i] = 0.0;
    }
    
    // 计算所有cell的frame
    for (int i = 0 ;i < numberOfCells ; i ++) {
        // cell所处在哪一列（最短的）
        NSUInteger cellColumn = 0;
        // cell 所处那一列的最大Y值
        CGFloat maxYOfCellColumn = maxYOfColumns[cellColumn];
        // 求出最短的一列
        for (int j = 1;j < numerOfColumns ;j ++) {
            if (maxYOfColumns[j] < maxYOfCellColumn) {
                cellColumn = j;
                maxYOfCellColumn = maxYOfColumns[j];
            }
        }
        
        // 求i位置的高度
        CGFloat cellH = [self heightAtIndex:i];
        
        // cell的位置 (最短cell的位置)
        CGFloat cellX = leftM + cellColumn * (columnM + cellW);
        CGFloat cellY = 0;
        if (maxYOfCellColumn == 0.0) {
            cellY = topM;
        } else {
            cellY = maxYOfCellColumn + rowM;
        }
        
        // 添加frame到数组中
        CGRect cellFrame = CGRectMake(cellX, cellY, cellW, cellH);
        [self.cellFrames addObject:[NSValue valueWithCGRect:cellFrame]];
        
        // 更新最短那列的最大Y值
        maxYOfColumns[cellColumn] = CGRectGetMaxY(cellFrame);
    }
    
    // 设置contensize
    CGFloat contenH = maxYOfColumns[0];
    for (int j = 1;j<numerOfColumns;j ++) {
        if (maxYOfColumns[j] > contenH) {
            contenH = maxYOfColumns[j];
        }
    }
    contenH += buttomM;
    self.contentSize = CGSizeMake(0, contenH);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 向数据源索要对应位置的cell
    NSUInteger numberOfCells = self.cellFrames.count;
    for (int i = 0;i <numberOfCells; i++) {
        // 取出i位置的frame
        CGRect cellFrame = [self.cellFrames[i] CGRectValue];
        
        //优先从字典取出i位置的cell
        MyWaterFlowVIiewCell *cell = self.displayingCells[@(i)];
        
        // 判断对应位置的frame在不在屏幕上
        if ([self isInScreen:cellFrame]) { // 在屏幕上
            if (cell == nil) {
                cell = [self.dataSource warterFlowView:self cellAtIndex:i];
                
                cell.frame = cellFrame;
                [self addSubview:cell];
                
                // 存到字典中
                self.displayingCells[@(i)] = cell;
            }
        } else { // 不在屏幕上
            if (cell) {
                // 从scrollview和字典中移除
                [cell removeFromSuperview];
                [self.displayingCells removeObjectForKey:@(i)];
                
                // 存放进缓存池
                [self.reusableCells addObject:cell];
            }
        }
    }
    
}

- (id)dequeueReusabelCellWithIdentifile:(NSString *)identifile
{
    __block MyWaterFlowVIiewCell *reusableCell = nil;
    
    [self.reusableCells enumerateObjectsUsingBlock:^(MyWaterFlowVIiewCell  *cell, BOOL * _Nonnull stop) {
        
        if ([cell.identifile isEqualToString:identifile]){
            reusableCell = cell;
            *stop = YES;
        }
        
    }];
    
    if (reusableCell) { // 从缓存池中移除
        [self.reusableCells removeObject:reusableCell];
    }
    return reusableCell;
}

#pragma mark - 私有方法
/**
 *  总列数
 *
 */
- (NSUInteger)numberOfColumns
{
    if ([self.dataSource respondsToSelector:@selector(numberOFColumnInWaterflowView:)]) {
        
       return  [self.dataSource numberOFColumnInWaterflowView:self];
    } else {
        
        return MyWaterFlowViewDefaultColumns;
    }
}
/**
 *  计算间距
 *
 */
- (CGFloat)maginForType:(MyWaterFlowViewMaginType)type
{
    if ([self.delegate respondsToSelector:@selector(waterflowVIew:MaginForTtype:)]) {
        return [self.delegate waterflowVIew:self MaginForTtype:type];
    } else {
        return MyWaterFlowViewDefaultMagin;
    }
}

/**
 *  返回对于index位置cell的高度
 *
 */
- (CGFloat)heightAtIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(waterflowView:HeightForRowAtIndex:)]) {
        return [self.delegate waterflowView:self HeightForRowAtIndex:index];
    } else {
        return MyWaterFlowViewDefaultHeight;
    }
}

- (BOOL)isInScreen:(CGRect)frame
{
    return (CGRectGetMaxY(frame) > self.contentOffset.y) && (CGRectGetMidY(frame) < self.contentOffset.y + self.height);
}

#pragma mark - 事件处理
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    CGPoint poin = [touch locationInView:self];
    
    __block NSNumber *selectIndex = nil;
    [self.displayingCells enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, MyWaterFlowVIiewCell *cell, BOOL * _Nonnull stop) {
        
        if (CGRectContainsPoint(cell.frame, poin)) {
            selectIndex = key;
            *stop = YES;
        }
    }];
    
    if (selectIndex) {
        [self.delegate waterflowView:self DidSelectRowAtIndex:selectIndex.unsignedIntegerValue];
    }
}
@end
