//
//  LWImporterSourceEditorCommand.h
//  Extensions
//
//  Created by allensun on 06/12/2017.
//  Copyright © 2017 Uncle Wang Tech. All rights reserved.
//

#import <XcodeKit/XcodeKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LWImporterErrorType) {
    LWImporterErrorTypeEmptySelection = 1,
    LWImporterErrorTypeMultipleSelection,
    LWImporterErrorTypeNoSelectedString,
    LWImporterErrorTypeUnsupportedFileType,
    LWImporterErrorTypeAlreadyImported,
};

@interface LWImporterSourceEditorCommand : NSObject <XCSourceEditorCommand>

@end

NS_ASSUME_NONNULL_END
