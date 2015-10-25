//
//  MyShopCell.m
//  Demo
//
//  Created by NengQuan on 15/10/25.
//  Copyright © 2015年 NengQuan. All rights reserved.
//

#import "MyShopCell.h"
#import "UIImageView+WebCache.h"
#import "MyShop.h"

@interface MyShopCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageview;

@property (weak, nonatomic) IBOutlet UILabel *pricelabel;
@end
@implementation MyShopCell

- (void)awakeFromNib
{
    self.pricelabel.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.4];
}

- (void)setShop:(MyShop *)shop
{
    _shop = shop;
    
    [self.imageview sd_setImageWithURL:[NSURL URLWithString:shop.img] placeholderImage:[UIImage imageNamed:@"bg"]];
    self.pricelabel.text = [NSString stringWithFormat:@"%@",shop.price];
    
}

@end
