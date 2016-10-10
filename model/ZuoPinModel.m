//
//  ZuoPinModel.m
//  jingdongfang
//
//  Created by 郝志宇 on 16/7/11.
//  Copyright © 2016年 XuDong Jin. All rights reserved.
//

#import "ZuoPinModel.h"

#define PER_PAGE 30

@implementation ZuoPinModel
@synthesize recommends,currentPage;

#pragma mark -

- (void)firstPage
{
    [self gotoPage:1];
    currentPage = 1;
    self.loaded = NO;
}

- (void)nextPage
{
    currentPage = recommends.count/PER_PAGE+1;
    self.loaded = NO;
    [self gotoPage:currentPage];
}

- (void)gotoPage:(NSUInteger)page
{
//    [API_APP_PHP_USER_WORKS_LIST cancel];
    
    API_APP_PHP_USER_WORKS_LIST * api = [API_APP_PHP_USER_WORKS_LIST api];
    
    [[UserModel sharedInstance] loadCache];
    api.req.page = [NSString stringWithFormat:@"%@",@(page)];
    api.req.pagecount = [NSString stringWithFormat:@"%d",PER_PAGE];
    api.req.uid = kUserId.length>0 ? kUserId : @"";
    api.req.type = self.type;
    
    if (api.req.uid.length==0) {
        return;
    }
    
    @weakify(api);
    @weakify(self);
    
    
    api.whenUpdate = ^
    {
        @normalizex(api);
        @normalizex(self);
        
        if ( api.sending )
        {
            //			[self presentLoadingTips:@"加载中……"];
        }
        else
        {
            if ( api.succeed )
            {
                if ( nil == api.resp )
                {
                    api.failed = YES;
                    return;
                }
                if (![api.resp.result isEqualToString:@"succ"]) {
                    api.failed = YES;
                    return;
                }
                else
                {
                    if (currentPage==1) {
                        self.recommends = [NSMutableArray arrayWithArray:api.resp.info];
                    }
                    else{
                        [self.recommends addObjectsFromArray:api.resp.info];
                    }
                    
                    if (self.recommends.count!=0) {
                        if (api.resp.info.count<PER_PAGE) {
                            self.loaded = YES;
                        }
                    }
                    [self dismissTips];
                    [self sendUISignal:self.RELOADED];
                }
            }
            else{
                NSString *msg = api.resp.msg;
                [self presentMessageTips:msg.length>0?msg:@"获取信息失败"];
                [self sendUISignal:self.RELOADED];
            }
            NSLog(@"----API_APP_PHP_USER_WORKS_LIST---");
            NSLog(@"----%@",[api.resp objectToString]);
        }
    };
    
    [api send];
}

@end
