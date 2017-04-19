//
//  NSString+Add.m
//  demo
//
//  Created by 张俊 on 14/04/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "NSString+Add.h"

@implementation NSString (Add)


+ (NSString *)stringWithHMS:(int)duration
{
    int s = duration%60;
    int m = (duration/60)%60;
    int h = duration/3600;
    if(h <=0){
        return [NSString stringWithFormat:@"%02d:%02d", m, s];
    }else{
        return [NSString stringWithFormat:@"%02d:%02d:%02d",h, m, s];
    }
    
}


@end
