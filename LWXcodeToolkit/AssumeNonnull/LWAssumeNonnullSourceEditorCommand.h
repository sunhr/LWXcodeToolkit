//
//  LWAssumeNonnullSourceEditorCommand.h
//  Extensions
//
//  Created by allensun on 06/12/2017.
//  Copyright © 2017 Uncle Wang Tech. All rights reserved.
//

#import <XcodeKit/XcodeKit.h>

typedef NS_ENUM(NSInteger, LWAssumeNonnullErrorType) {
    LWAssumeNonnullErrorTypeUnsupportedFileType = 1,
};


@interface LWAssumeNonnullSourceEditorCommand : NSObject <XCSourceEditorCommand>

@end
