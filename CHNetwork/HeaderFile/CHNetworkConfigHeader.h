//
//  CHNetworkConfigHeader.h
//  AboutAFNetworking
//
//  Created by Cher on 16/7/19.
//  Copyright © 2016年 Hxc. All rights reserved.
//

#ifndef CHNetworkConfigHeader_h
#define CHNetworkConfigHeader_h

#define SHOW_ALERT(_msg_,_delegate_,_ViewTag_)  \
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:_msg_ delegate:_delegate_ cancelButtonTitle:nil otherButtonTitles:@"确定", nil];\
        alert.tag = _ViewTag_;\
        [alert show];

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self

#import "CHNetwork.h"
#import "CHTools.h"

#endif /* CHNetworkConfigHeader_h */
