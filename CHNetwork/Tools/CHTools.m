//
//  CHTools.m
//  AboutAFNetworking
//
//  Created by Cher on 16/7/12.
//  Copyright © 2016年 Hxc. All rights reserved.
//

#import "CHTools.h"

@implementation CHTools

+ (NSDictionary *)jsonToDictionary:(id)responseObject{
     
     NSDictionary *responseDic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:(NSData *)responseObject options:NSJSONReadingMutableLeaves error:nil];
     return responseDic;
}

@end
