//
//  HomeHeaderView.h
//  WenZhouSports
//
//  Created by 何聪 on 2017/5/2.
//  Copyright © 2017年 何聪. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeHeaderView : UIView

/**
 校园排行榜点击事件
 */
@property (nonatomic, strong, readonly) RACSignal *rankingSignal;

@end