//
//  VideoMgrButton.m
//  demo
//
//  Created by 张俊 on 15/05/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "VideoMgrButton.h"
#import "PreviewView.h"


@implementation VideoMgrButton : UIButton


- (instancetype)init
{
    self = [super init];
    if (self){
        
        //[self setImage:[UIImage imageNamed:@"album"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"album"] forState:kLoadfileState];
        [self setImage:[UIImage imageNamed:@"album"] forState:(kLoadfileState | UIControlStateHighlighted )];
        [self setImage:[UIImage imageNamed:@"album"] forState:(kLoadfileState | UIControlStateDisabled )];
        //[self setImage:[UIImage imageNamed:@"album"] forState:(kLoadfileState | UIControlStateDisabled)];
        [self setImage:[UIImage imageNamed:@"delete"] forState:kDeleteState];
        [self setImage:[UIImage imageNamed:@"delete"] forState:(kDeleteState | UIControlStateHighlighted)];
        [self setImage:[UIImage imageNamed:@"delete"] forState:(kDeleteState | UIControlStateDisabled )];
        [self setImage:[UIImage imageNamed:@"back"] forState:kBackSelect];
        [self setImage:[UIImage imageNamed:@"back"] forState:(kBackSelect | UIControlStateHighlighted)];
        [self setImage:[UIImage imageNamed:@"back"] forState:(kBackSelect | UIControlStateDisabled )];
    }
    return self;
}

-(void)setVideoMgrState:(NSUInteger)videoMgrState
{
    if (videoMgrState == kLoadfileState){
        self.tag = PreViewSubViewIdx_LoadFile;
    }else if (videoMgrState == kDeleteState){
        self.tag = PreViewSubViewIdx_DeleteRecFile;
    }else if (videoMgrState == kBackSelect){
        self.tag = PreViewSubViewIdx_BackRecFile;
    }
    _videoMgrState = videoMgrState;
    
    [self setNeedsLayout];
}

- (UIControlState)state
{
    return ( [super state] | self.videoMgrState );
}

@end
