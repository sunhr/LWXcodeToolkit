//
//  SourceEditorExtension.m
//  Extensions
//
//  Created by allensun on 06/12/2017.
//  Copyright © 2017 Uncle Wang Tech. All rights reserved.
//

#import "SourceEditorExtension.h"
#import "Definition.h"
#import "LWImporterSourceEditorCommand.h"
#import "LWAssumeNonnullSourceEditorCommand.h"

@implementation SourceEditorExtension

/*
- (void)extensionDidFinishLaunching
{
    // If your extension needs to do any work at launch, implement this optional method.
}
*/

- (NSArray <NSDictionary <XCSourceEditorCommandDefinitionKey, id> *> *)commandDefinitions
{
    return @[
             @{XCSourceEditorCommandNameKey : @"Add NS_ASSUME_NONNULL",
               XCSourceEditorCommandClassNameKey : NSStringFromClass([LWAssumeNonnullSourceEditorCommand class]),
               XCSourceEditorCommandIdentifierKey : LWAssumeNonnullBundleIdentifier,
               },
             @{XCSourceEditorCommandNameKey : @"Import Header",
               XCSourceEditorCommandClassNameKey : NSStringFromClass([LWImporterSourceEditorCommand class]),
               XCSourceEditorCommandIdentifierKey : LWImporterBundleIdentifier,
               },
             ];
}


@end
