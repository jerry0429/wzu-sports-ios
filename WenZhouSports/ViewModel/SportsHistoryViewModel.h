//
//  SportsHistoryViewModel.h
//  WenZhouSports
//
//  Created by 郭佳 on 2017/6/20.
//  Copyright © 2017年 何聪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HomePageModel.h"

@interface SportsHistoryViewModel : NSObject

@property (nonatomic, strong) HomePageModel *homePage;

@property (nonatomic, strong) RACCommand *cmdGetSportsHistory;

@end
