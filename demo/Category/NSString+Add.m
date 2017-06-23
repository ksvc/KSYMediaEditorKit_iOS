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

+ (NSString *)stringWithTrimFormat:(long)duration
{
    //FIXME 忽略小时
    int min = (int)((duration%(1000 * 60 * 60))/(1000 * 60));
    int sec = (int)(((duration%(1000 * 60 * 60))%(1000 * 60))/1000);
    int ms  = (int)(duration%1000/100);
    
    return [NSString stringWithFormat:@"%02d:%02d.%d", min, sec, ms];
}


@end
