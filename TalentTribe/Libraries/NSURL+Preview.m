//
//  NSUrl+Preview.m
//  TalentTribe
//
//  Created by Anton Vilimets on 7/22/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "NSURL+Preview.h"

@implementation NSURL (Preview)

- (void)loadPreview:(void (^)(NSDictionary *result))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSError *error;
        NSString *html = [NSString stringWithContentsOfURL:self encoding:NSUTF8StringEncoding error:&error];
        if(!error)
        {
        
        NSString *title = [self getTitleFrom:html];
            NSString *descr = [self getDescriptionFrom:html];
            NSURL *imgLink = [NSURL URLWithString:[self getImgUrlFrom:html]];
            NSMutableDictionary *res = [NSMutableDictionary dictionary];
            if(title) res[@"title"] = title;
            if(descr) res[@"descr"] = descr;
            res[@"baseUrl"] = [self parseBaseUrl];
            if(imgLink)
            {
                NSData *imgData = [NSData dataWithContentsOfURL:imgLink];
                UIImage *img = [UIImage imageWithData:imgData];
                if(img)
                {
                    res[@"image"] = img;
                }

            }
            dispatch_async(dispatch_get_main_queue(), ^{
            completion(res);
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil);
            });
        }
      
    });
}

- (NSString *)parseBaseUrl
{
    NSError *regexError = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"http://.*/" options:NSRegularExpressionCaseInsensitive error:&regexError];
    
    if (regexError) {
        NSLog(@"regexError: %@", regexError);
        return nil;
    }
    
    NSTextCheckingResult *match = [regex firstMatchInString:self.absoluteString options:0 range:NSMakeRange(0, self.absoluteString.length)];
    
    NSString *baseURL = [self.absoluteString substringWithRange:match.range];
    if(baseURL.length) return baseURL;
    else return [self.absoluteString stringByReplacingOccurrencesOfString:@"http://" withString:@""];
}

- (NSString *)getTitleFrom:(NSString *)html
{
    __block NSString *title = [self openGraphValue:@"title" from:html];
    if(!title)
    {
        NSError *error = nil;
        NSString *pattern = @"((<title).*?(title>))";
        //    NSString *pattern = @"(<string-array)[\\s\\S]*?(</string-array>)";
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:pattern
                                      options:0
                                      error:&error];
        [regex enumerateMatchesInString:html options:0 range:NSMakeRange(0, [html length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
            
            NSString *str = [html substringWithRange:match.range];
            NSRange nameR = [str rangeOfString:@">(.*?)<" options:NSRegularExpressionSearch];
            NSString *content = [str substringWithRange:nameR];
            title = [content substringWithRange:NSMakeRange(1, content.length - 2)];
            
        }];

        
    }
    return title;
}

- (NSString *)getDescriptionFrom:(NSString *)html
{
    __block NSString *result = [self openGraphValue:@"description" from:html];
    if(!result)
    {
        NSError *error = nil;
        NSString *pattern = [NSString stringWithFormat:@"(<meta).*?(name=\"description\")[\\s\\S]*?>"];
        //    NSString *pattern = @"(<string-array)[\\s\\S]*?(</string-array>)";
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:pattern
                                      options:0
                                      error:&error];
        [regex enumerateMatchesInString:html options:0 range:NSMakeRange(0, [html length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
            
            NSString *str = [html substringWithRange:match.range];
            NSRange nameR = [str rangeOfString:@"content=\"([\\s\\S]*?)\"" options:NSRegularExpressionSearch];
            NSString *content = [str substringWithRange:nameR];
            if(!result)
            result = [content substringWithRange:NSMakeRange(9, content.length - 10)];
            
            
        }];
    }
    return result;
}

- (NSString *)getImgUrlFrom:(NSString *)html
{
    return [self openGraphValue:@"image" from:html];
}


- (NSString *)openGraphValue:(NSString *)value from:(NSString *)html
{
    __block NSString *result = nil;
    NSError *error = nil;
    NSString *pattern = [NSString stringWithFormat:@"(<meta).*?(property=\"og:%@\").*?>", value];
    //    NSString *pattern = @"(<string-array)[\\s\\S]*?(</string-array>)";
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:pattern
                                  options:0
                                  error:&error];
    [regex enumerateMatchesInString:html options:0 range:NSMakeRange(0, [html length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
        
        NSString *str = [html substringWithRange:match.range];
        NSRange nameR = [str rangeOfString:@"content=\"(.*?)\"" options:NSRegularExpressionSearch];
        NSString *content = [str substringWithRange:nameR];
        if(!result)
        {
        result = [content substringWithRange:NSMakeRange(9, content.length - 10)];
        }

        
    }];
    return result;
}


@end
