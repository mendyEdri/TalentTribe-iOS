//
//  StoryAttachmentCell.m
//  TalentTribe
//
//  Created by Anton Vilimets on 7/27/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "StoryAttachmentCell.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation StoryAttachmentCell

- (void)setupWithAttachObj:(NSDictionary *)obj
{
    UIImageView *imgView = self.contentView.subviews.firstObject;
    imgView.image = [self centerMaxSquareImageByCroppingImage:obj[@"image"]];
}

- (UIImage *)centerMaxSquareImageByCroppingImage:(UIImage *)image
{
    CGSize centerSquareSize;
    double oriImgWid = CGImageGetWidth(image.CGImage);
    double oriImgHgt = CGImageGetHeight(image.CGImage);
    if(oriImgHgt <= oriImgWid) {
        centerSquareSize.width = oriImgHgt;
        centerSquareSize.height = oriImgHgt;
    }else {
        centerSquareSize.width = oriImgWid;
        centerSquareSize.height = oriImgWid;
    }
    
    
    double x = (oriImgWid - centerSquareSize.width) / 2.0;
    double y = (oriImgHgt - centerSquareSize.height) / 2.0;
    
    CGRect cropRect = CGRectMake(x, y, centerSquareSize.height, centerSquareSize.width);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef scale:0.0 orientation:image.imageOrientation];
    CGImageRelease(imageRef);
    
    
    return cropped;
}

- (IBAction)closePressed:(id)sender
{
    if(self.closeHandler) self.closeHandler(self);
}



@end
