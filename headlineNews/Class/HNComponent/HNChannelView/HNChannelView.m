//
//  HNChannelView.m
//  headlineNews
//
//  Created by dengweihao on 2017/11/21.
//  Copyright © 2017年 vcyber. All rights reserved.
//

#import "HNChannelView.h"
#import "HNChannelModel.h"
#import "HNTitleView.h"
#import "HNButton.h"
#import "UIView+Frame.h"
#import "HNHeader.h"


#define MYCHANNEL_FRAME(i) CGRectMake(itemSpace + (i % column)* (_labelWidth + itemSpace), CGRectGetMaxY(wself.header1.frame) + lineSpace + (i / column)*(labelHeight + lineSpace), _labelWidth, labelHeight)
#define RECOMMEND_FRAME(i)  CGRectMake(itemSpace + ((i) % column)* (_labelWidth + itemSpace),CGRectGetMaxY(wself.divisionModel.frame) + wself.header1.frame.size.height + lineSpace + ((i) / column)*(labelHeight + lineSpace), _labelWidth, labelHeight)

static CGFloat itemSpace = 10;
static CGFloat lineSpace = 10;
static int column = 4;
static CGFloat labelHeight = 40;


@interface HNChannelView ()<UIScrollViewDelegate>

@property (nonatomic , strong)NSMutableArray *myChannelArr;
@property (nonatomic , strong)NSMutableArray *recommendChannelArr;
// iOS6 之后不用自己手动回收 
@property (nonatomic , strong)dispatch_queue_t queue;
@property (nonatomic , strong)NSMutableArray *datas;
@property (nonatomic , assign)CGFloat labelWidth;
@property (nonatomic , weak)HNTitleView *header1;
@property (nonatomic , weak)HNTitleView *header2;
@property (nonatomic , weak)HNChannelModel *divisionModel;
@end

@interface HNHeaderView : UIView
@property (nonatomic , copy) void(^callBack)(void);

@end

@implementation HNChannelView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _myChannelArr = [[NSMutableArray alloc]initWithArray:@[
                                                               @"推荐",@"热点",@"北京",@"视频",
                                                               @"社会",@"图片",@"娱乐",@"问答",
                                                               @"科技",@"汽车",@"财经",@"军事",
                                                               @"体育",@"段子",@"国际",@"趣图",
                                                               @"健康",@"特卖",@"房产",@"小说",
                                                               @"时尚",@"直播",@"育儿",@"搞笑",
                                                               ]];
        _recommendChannelArr = [[NSMutableArray alloc]initWithArray:@[
                                                                      @"历史",@"数码",@"美食",@"养生",
                                                                      @"电影",@"手机",@"旅游",@"宠物",
                                                                      @"情感",@"家具",@"教育",@"三农",
                                                                      @"孕产",@"文化",@"游戏",@"股票",
                                                                      @"科学",@"动漫",@"故事",@"收藏",
                                                                      @"精选",@"语录",@"星座",@"美图",
                                                                      @"辟谣",@"中国新唱将",@"微头条",@"正能量",
                                                                      @"互联网法院",@"彩票",@"快乐男声",@"中国好表演",
                                                                      @"传媒"
                                                                      ]];
        [self setUI];
        _labelWidth = (self.frame.size.width - itemSpace *(column + 1))/column;
        _datas = [NSMutableArray array];
        _queue = dispatch_queue_create("com.headlineNews.queue", DISPATCH_QUEUE_SERIAL);
        self.delegate = self;
        [self configData];
    }
    return self;
}

- (void)setUI {
    __weak typeof(self) wself = self;
    HNTitleView *header1 = [[HNTitleView alloc]initWithTitle:@"我的频道" subTitle:@"点击进入频道" needEditBtn:YES];
    header1.frame = CGRectMake(0, 40, self.frame.size.width, 54);
    _header1 = header1;
    [wself.header1 setCallBack:^(BOOL selected) {
        [wself refreshEidtBtnWithStatus:selected];
    }];
    HNTitleView *header2 = [[HNTitleView alloc]initWithTitle:@"推荐频道" subTitle:@"点击添加频道" needEditBtn:NO];
    _header2 = header2;
    _header2.hidden = YES;
    _header2.frame = _header2.bounds;
    
    HNHeaderView *headerView = [[HNHeaderView alloc]initWithFrame:CGRectMake(0, 0, HN_SCREEN_WIDTH, 40)];
    [headerView setCallBack:^{
        [wself hide];
    }];
    
    [self addSubview:headerView];
    [self addSubview:_header1];
    [self addSubview:_header2];
    self.backgroundColor = [UIColor whiteColor];
}


- (void)configData {
    __weak typeof(self) wself = self;
    dispatch_async(_queue, ^{
        for (int i = 0 ; i < wself.myChannelArr.count; i++) {
            HNChannelModel *model = [[HNChannelModel alloc]init];
            model.name = wself.myChannelArr[i];
            model.isMyChannel = YES;
            [wself.datas addObject:model];
        }
        for (int i = 0 ; i < wself.recommendChannelArr.count; i++) {
            HNChannelModel *model = [[HNChannelModel alloc]init];
            model.name = wself.recommendChannelArr[i];
            model.isMyChannel = NO;
            [wself.datas addObject:model];
        }
        [wself refreshFrames];
    });
}

- (void)refreshFrames {
    __weak typeof(self) wself = self;

    for (int i = 0 ; i < wself.datas.count; i++) {
        HNChannelModel *model = wself.datas[i];
        model.tag = i;
        if (model.isMyChannel) {
            model.frame = MYCHANNEL_FRAME(i); // [UIView frame] must be used from main thread only 这里是使用了view.frame导致的 后期会替换
            wself.divisionModel = model;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        wself.header2.top = CGRectGetMaxY(wself.divisionModel.frame) + lineSpace;
        wself.header2.hidden = NO;
    });
    
    for (int i = 0 ; i < wself.datas.count; i++) {
        HNChannelModel *model = wself.datas[i];
        if (!model.isMyChannel) {
            int index = i - wself.divisionModel.tag - 1;
             model.frame = RECOMMEND_FRAME(index);
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        for (HNChannelModel *model in wself.datas) {
            HNButton *button = [[HNButton alloc]initWithMyChannelHandleBlock:^(HNButton *btn) {
                if (!btn.deleImageView.hidden) {
                    [wself removeBtn:btn];
                }else {
                    // do something
                }
            } recommondChannelHandleBlock:^(HNButton *btn) {
                [wself addBtn:btn];
            }];
            
            [button addLongPressBeginBlock:^(HNButton *btn) {
                [wself addSubview:btn];
            } longPressMoveBlock:^(HNButton *btn, UILongPressGestureRecognizer *ges) {
                [wself adjustCenterForBtn:btn withGes:ges];
            } longPressEndBlock:^(HNButton *btn) {
                [wself resetBtnFrame:btn];
            }];
            button.model = model;
            if (button.model.name.length > 2) {
                button.titleLabel.adjustsFontSizeToFitWidth = YES;
            }
            if (model.tag == wself.datas.count - 1) {
                wself.contentSize = CGSizeMake(0, CGRectGetMaxY(model.frame) + 30);
            }
            [wself addSubview:button];
        }
        dispatch_async(_queue, ^{
            for (UIView *view in wself.subviews) {
                if ([view isKindOfClass:[HNButton class]]) {
                    [wself.datas replaceObjectAtIndex:view.tag withObject:view];
                }
            }
        });
    
    });
}

#pragma mark - 展示 和 隐藏
- (void)show {
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = CGRectMake(0, HN_STATUS_BAR_HEIGHT, self.width, self.height);
    }];
}

- (void)hide {
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = CGRectMake(0, self.height, self.width, self.height);
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}



#pragma mark - 刷新编辑按钮的状态

- (void)refreshEidtBtnWithStatus:(BOOL)show {
    __weak typeof(self) wself = self;
    if (!show) {
        for (HNButton *btn in wself.datas) {
            if (btn.model.isMyChannel) {
                btn.deleImageView.hidden = YES;
            }else {
                btn.deleImageView.hidden = YES;
            }
        }
    }else {
        for (HNButton *btn in wself.datas) {
            if (btn.model.isMyChannel) {
                btn.deleImageView.hidden = NO;
            }else {
                btn.deleImageView.hidden = YES;
            }
        }
    }
    
}

#pragma mark - 调整按钮的frame & 顺序

- (void)addBtn:(HNButton *)addbtn {
    __weak typeof(self) wself = self;
    [self.datas removeObject:addbtn];
    [self.datas insertObject:addbtn atIndex:self.divisionModel.tag + 1];
    addbtn.model.isMyChannel = YES;
    int divisionIndex = self.divisionModel.tag + 1;
    for (int i = 0 ; i < self.datas.count; i++) {
        HNButton *btn = self.datas[i];
        btn.tag = i;
        btn.model.tag = i;
        if (btn.model.isMyChannel) {
            [UIView animateWithDuration:0.25 animations:^{
                btn.frame = MYCHANNEL_FRAME(i);
                btn.model.frame = btn.frame;
                btn.deleImageView.hidden = wself.header1.editBtn.selected ? NO : YES;
            }];
        }else {
            [UIView animateWithDuration:0.25 animations:^{
                int index = i - self.divisionModel.tag - 1;
                btn.frame = RECOMMEND_FRAME(index);
                btn.model.frame = btn.frame;
                btn.deleImageView.hidden = YES;
            }];

        }
        if (i == divisionIndex) {
            self.divisionModel = btn.model;
        }
        [btn reloadData];

    }
}
- (void)removeBtn:(HNButton *)removeBtn {
    __weak typeof(self) wself = self;
    [self.datas removeObject:removeBtn];
    [self.datas insertObject:removeBtn atIndex:self.divisionModel.tag];
    removeBtn.model.isMyChannel = NO;
    int divisionIndex = self.divisionModel.tag - 1;
    for (int i = 0 ; i < self.datas.count; i++) {
        HNButton *btn = self.datas[i];
        btn.tag = i;
        btn.model.tag = i;
        if (btn.model.isMyChannel) {
            [UIView animateWithDuration:0.25 animations:^{
                btn.frame = MYCHANNEL_FRAME(i);
                btn.model.frame = btn.frame;
                btn.deleImageView.hidden = NO;
            }];
        }else {
            [UIView animateWithDuration:0.25 animations:^{
                int index = i - self.divisionModel.tag - 1;
                btn.frame = RECOMMEND_FRAME(index);
                btn.model.frame = btn.frame;
                btn.deleImageView.hidden = YES;
            }];

        }
        if (i == divisionIndex) {
            self.divisionModel = btn.model;
        }
        [btn reloadData];
    }

}


#pragma mark - 调整按钮的 header2 的尺寸
- (void)setDivisionModel:(HNChannelModel *)divisionModel {
    _divisionModel = divisionModel;
    __weak typeof(self) wself = self;
    if (![[NSThread currentThread] isMainThread]) {
        return;
    }
    [UIView animateWithDuration:0.25 animations:^{
        wself.header2.frame = CGRectMake(0, CGRectGetMaxY(self.divisionModel.frame)+lineSpace, wself.frame.size.width, 54);
    }];
}

#pragma mark - 交换两个按钮的位置
- (void)adjustCenterForBtn:(HNButton *)btn withGes:(UILongPressGestureRecognizer *)ges{
    CGPoint newPoint = [ges locationInView:self];
    btn.center = newPoint;
    __weak typeof(self) wself = self;
    [self newLocationTagForBtn:btn locationBlock:^(HNButton *targetBtn) {
        if (wself.divisionModel == btn.model) {
            HNButton *divisionBtn = self.datas[btn.tag - 1];
            wself.divisionModel = divisionBtn.model;
        }
        if (wself.divisionModel == targetBtn.model) {
            wself.divisionModel = btn.model;
        }
        
        [wself.datas removeObject:btn];
        [wself.datas insertObject:btn atIndex:targetBtn.tag];
        btn.tag = targetBtn.tag;
        btn.model.tag = btn.tag;
        dispatch_async(dispatch_get_main_queue(), ^{
            for (int i = 0 ; i < wself.datas.count; i++) {
                HNButton *moveBtn = wself.datas[i];
                if (moveBtn.model.isMyChannel && btn != moveBtn) {
                    [UIView animateWithDuration:0.25 animations:^{
                        moveBtn.frame = MYCHANNEL_FRAME(i);
                        moveBtn.model.frame = moveBtn.frame;
                        moveBtn.tag = i;
                        moveBtn.model.tag = i;
                    }];
                }
            }

        });
    }];
}
- (void)newLocationTagForBtn:(HNButton *)moveBtn locationBlock:(void(^)(HNButton * targetBtn))locationBlock {
    __weak typeof(self) wself = self;
    dispatch_async(_queue, ^{
        for (UIView *view in wself.subviews) {
            if (view == moveBtn) {
                continue;
            }
            if (![view isKindOfClass:[HNButton class]]) {
                continue;
            }
            HNButton *btn = (HNButton *)view;
            if (!btn.model.isMyChannel) {
                continue;
            }
            if (CGRectContainsPoint(view.frame, moveBtn.center)) {
                    locationBlock(btn);
            }
        }
    });
}
- (void)resetBtnFrame:(HNButton *)btn {
    __weak typeof(self) wself = self;
    [UIView animateWithDuration:0.25 animations:^{
        btn.frame = MYCHANNEL_FRAME(btn.tag);
        btn.model.frame = btn.frame;
    }];
}

#pragma mark - scrollView的代理方法

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < -50) {
            [self hide];
    }
    
}
@end

@implementation HNHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIButton *btn = UIButton.button(UIButtonTypeCustom).setShowImage([UIImage imageNamed:@"close_sdk_login_14x14_"],UIControlStateNormal);
        btn.frame = CGRectMake(15, 0, 40, 40);
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
    return self;
}

- (void)btnClick:(UIButton *)btn {
    if (_callBack) {
        _callBack();
    }
}
@end


