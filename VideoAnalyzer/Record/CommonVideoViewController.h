//
//  CommonVideoViewController.h
//  VideoAnalyzer
//
//  Created by Nguyễn Đức Thọ on 11/5/18.
//  Copyright © 2018 Nguyễn Đức Thọ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommonVideoViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property(nonatomic, strong) AVAsset *videoAsset;

- (BOOL)startMediaBrowserFromViewController:(UIViewController*)controller usingDelegate:(id)delegate;
- (void)exportDidFinish:(AVAssetExportSession*)session;
- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size;
- (void)videoOutput;

@end

NS_ASSUME_NONNULL_END
