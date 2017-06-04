//
//  HomeController.m
//  WenZhouSports
//
//  Created by 何聪 on 2017/5/3.
//  Copyright © 2017年 何聪. All rights reserved.
//

#import "HomeController.h"
#import "PersonalCenterView.h"
#import "RankingController.h"
#import "SportsDetailsController.h"
#import "SportsDetailViewModel.h"
#import "SportsHistoryController.h"
#import "HomeItemCell.h"
#import "HomeTotalCell.h"
#import "HomeRankCell.h"
#import "HomeSportsTypeCell.h"
#import "PersonInfoController.h"
#import "SportsPerformanceController.h"
#import "ApproveController.h"

#import "LoginController.h"
#import "ForgetPasswordController.h"

@interface HomeController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) PersonalCenterView *personalCenterView;
@property (nonatomic, strong) UIView *midView;// 个人中心被色背景层

@end

CGFloat proportion = 0.84;

@implementation HomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"课外体育锻炼";
    self.view.backgroundColor = cFFFFFF;
    [self initSubviews];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationItem setLeftBarButtonItemWithImage:[UIImage imageNamed:@"btn_menu"] target:self action:@selector(showPersonalCenter)];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar lt_setBackgroundColor:c66A7FE];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    // 标题白色
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:cFFFFFF,NSFontAttributeName:S(19)}];
    [self.navigationController.navigationBar setTintColor:cFFFFFF];
    
    // 状态栏颜色白色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)initSubviews {
    _tableView = ({
        UITableView *tv = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, WIDTH, HEIGHT) style:UITableViewStyleGrouped];
        tv.delegate = self;
        tv.dataSource = self;
        tv.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [tv registerClass:[HomeItemCell class]
           forCellReuseIdentifier:NSStringFromClass([HomeItemCell class])];
        [tv registerClass:[HomeTotalCell class]
           forCellReuseIdentifier:NSStringFromClass([HomeTotalCell class])];
        [tv registerClass:[HomeRankCell class]
           forCellReuseIdentifier:NSStringFromClass([HomeRankCell class])];
        [tv registerClass:[HomeSportsTypeCell class]
           forCellReuseIdentifier:NSStringFromClass([HomeSportsTypeCell class])];
        
        tv;
    });
    [self.view addSubview: _tableView];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] init];
    panGesture.delegate = self;
    RACSignal *signal = [panGesture rac_gestureSignal];
    [self.tableView addGestureRecognizer:panGesture];
    
    _midView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(WIDTH * proportion, 0.0, WIDTH * (1 - proportion), HEIGHT)];
        view.hidden = YES;
        view.backgroundColor = [UIColor blackColor];
        view.alpha = 0.5;
        
        view;
    });
    [self.view addSubview:_midView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    UIPanGestureRecognizer *midPanGesture = [[UIPanGestureRecognizer alloc] init];
    [_midView addGestureRecognizer:midPanGesture];
    [_midView addGestureRecognizer:tapGesture];
    [[tapGesture rac_gestureSignal] subscribeNext:^(UIGestureRecognizer * x) {
        [self showHomePage];
    }];
    
    _personalCenterView = ({
        PersonalCenterView *view = [[PersonalCenterView alloc] initWithFrame:CGRectMake(-WIDTH * proportion, 0.0, WIDTH * proportion, HEIGHT)];
        
        view;
    });
    [[UIApplication sharedApplication].keyWindow addSubview:_personalCenterView];
    
    //监听个人中心
    @weakify(self);
    [[RACObserve(_personalCenterView, selectedIndex) skip:1] subscribeNext:^(id x) {
        @strongify(self);
        switch (self.personalCenterView.selectedIndex) {
            case 0:// 运动历史
            {
                SportsHistoryController *vc = [[SportsHistoryController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 1:// 体侧数据
            {
                PersonInfoController *vc = [[PersonInfoController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 2:// 体育成绩
            {
                SportsPerformanceController *vc = [[SportsPerformanceController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 3:// 审批
            {
                ApproveController *vc = [[ApproveController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }

            default:
                break;
        }
        [self showHomePage];
        
    }];
    
    [[signal merge:[midPanGesture rac_gestureSignal]] subscribeNext:^(UIPanGestureRecognizer *recognizer) {
        CGFloat x = [recognizer translationInView:self.tableView].x;
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            if (x > WIDTH * 0.42) {
                [self showPersonalCenter];
            } else {
                [self showHomePage];
            }
        }
    }];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    SportsDetailViewModel *viewModel = [[SportsDetailViewModel alloc] init];
//    UIImage *image = [UIImage imageNamed:@"btn_back"];
//    NSDictionary *dic = @{@"face1":image,
//                          @"face2":image};
//    [[viewModel.compareFaceCommand execute:dic] subscribeNext:^(id  _Nullable x) {
//        [WToast showWithText:@"x"];
//    }];
//    SportsDetailsController *controller = [[SportsDetailsController alloc] init];
//    [self.navigationController pushViewController:controller animated:YES];
    
//    ForgetPasswordController *vc = [[ForgetPasswordController alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
    
    LoginController *vc = [[LoginController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            HomeTotalCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HomeTotalCell class]) forIndexPath:indexPath];
            [cell setupWithData:nil];
            return cell;
        } else {
            HomeRankCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HomeRankCell class]) forIndexPath:indexPath];
            return cell;
        }
    } else {
        if (indexPath.row == 0) {
            HomeSportsTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HomeSportsTypeCell class]) forIndexPath:indexPath];
            return cell;
        } else {
            HomeItemCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HomeItemCell class]) forIndexPath:indexPath];
            switch (indexPath.row) {
                case SportsTypeJogging:
                {
                    [cell initWithSportsType:SportsTypeJogging data:nil];
                    break;
                }
                case SportsTypeRun:
                {
                    [cell initWithSportsType:SportsTypeRun data:nil];
                    break;
                }
                case SportsTypeWalk:
                {
                    [cell initWithSportsType:SportsTypeWalk data:nil];
                    break;
                }
                case SportsTypeStep:
                {
                    [cell initWithSportsType:SportsTypeStep data:nil];
                    break;
                }
            }
            return cell;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.1;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 156;
        } else {
            return 44;
        }
    } else {
        if (indexPath.row == 0) {
            return 40;
        } else {
            return FIX(162);
        }
    }
}

#pragma mark - Event
- (void)showPersonalCenter {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _tableView.center = CGPointMake(self.view.center.x+ WIDTH * proportion, self.view.center.y);
        _personalCenterView.center = CGPointMake(WIDTH / 2 * proportion, self.view.center.y);
    } completion:^(BOOL finished) {
        if (finished) {
            _midView.hidden = NO;
        }
    }];
}

- (void)showHomePage {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _tableView.center = CGPointMake(self.view.center.x, self.view.center.y);
        _personalCenterView.center = CGPointMake(-WIDTH / 2 * proportion, self.view.center.y);
    } completion:nil];
    _midView.hidden = YES;
}

@end
