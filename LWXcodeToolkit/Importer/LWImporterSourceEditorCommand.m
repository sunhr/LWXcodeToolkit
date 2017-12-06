//
//  LWImporterSourceEditorCommand.m
//  Extensions
//
//  Created by allensun on 06/12/2017.
//  Copyright © 2017 Uncle Wang Tech. All rights reserved.
//

#import "LWImporterSourceEditorCommand.h"

@implementation LWImporterSourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    NSString *contentUTI = invocation.buffer.contentUTI;
    
    if (![contentUTI isEqualToString:@"public.objective-c-source"] &&
        ![contentUTI isEqualToString:@"public.objective-c-plus-plus-source"] &&
        ![contentUTI isEqualToString:@"public.c-header"]) {
        
        [self handleError:LWImporterErrorTypeUnsupportedFileType withCompletionHandler:completionHandler];
        return;
    }
    
    XCSourceTextRange *selectedRange = invocation.buffer.selections.firstObject;
    
    XCSourceTextPosition start = selectedRange.start;
    XCSourceTextPosition end = selectedRange.end;
    
    if (start.line != end.line) {
        [self handleError:LWImporterErrorTypeMultipleSelection withCompletionHandler:completionHandler];
        return;
    }
    
    if (start.column >= end.column) {
        [self handleError:LWImporterErrorTypeEmptySelection withCompletionHandler:completionHandler];
        return;
    }
    
    NSMutableArray<NSString *> *lines = invocation.buffer.lines;
    
    NSString *selectedString = [lines[start.line] substringWithRange:NSMakeRange(start.column, end.column - start.column)];
    
    if (selectedString.length == 0) {
        [self handleError:LWImporterErrorTypeNoSelectedString withCompletionHandler:completionHandler];
        return;
    }
    
    NSUInteger importLine = 0;
    NSUInteger lastImportLine = 0;
    
    NSString *importString = [NSString stringWithFormat:@"#import \"%@.h\"", selectedString];
    
    for (NSUInteger i = 0; i < lines.count; i++) {
        
        NSString *line = lines[i];
        
        if ([line hasPrefix:@"#import"]) {
            lastImportLine = i;
            
            if ([line hasPrefix:importString]) {
                [self handleError:LWImporterErrorTypeAlreadyImported withCompletionHandler:completionHandler];
                return;
            }
        }
    }
    
    if (lastImportLine == 0) {
        importLine = [self firstCodingLineOfLines:lines];
    } else {
        importLine = lastImportLine + 1;
    }
    
    [lines insertObject:importString atIndex:importLine];
    
    completionHandler(nil);
}

- (NSUInteger)lastImportLineOfLines:(NSMutableArray<NSString *> *)lines
{
    NSUInteger lastImportLine = 0;
    
    for (NSUInteger i = 0; i < lines.count; i++) {
        
        NSString *line = lines[i];
        
        if ([line hasPrefix:@"#import"]) {
            lastImportLine = i;
        }
    }
    
    return lastImportLine;
}

- (NSUInteger)firstCodingLineOfLines:(NSMutableArray<NSString *> *)lines
{
    //No comments in the start of the file
    if (![lines.firstObject hasPrefix:@"//"]) {
        return 0;
    }
    
    NSUInteger firstCodingLine = 0;
    
    for (NSUInteger i = 0; i < lines.count; i++) {
        
        NSString *line = lines[i];
        
        if ([line hasPrefix:@"//"]) {
            firstCodingLine = i + 1;
        }
    }
    
    return firstCodingLine;
}

- (void)handleError:(LWImporterErrorType)errorType withCompletionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    NSString *errorDescription = @"";
    
    switch (errorType) {
        case LWImporterErrorTypeMultipleSelection: {
            errorDescription = @"You should only select the class name which will be imported. ";
            break;
        }
        case LWImporterErrorTypeNoSelectedString: {
            errorDescription = @"No selected string found. ";
            break;
        }
        case LWImporterErrorTypeEmptySelection: {
            errorDescription = @"Select the class name, please. ";
            break;
        }
        case LWImporterErrorTypeUnsupportedFileType: {
            errorDescription = @"Only support Objective-C files like .h, .m, .mm. ";
            break;
        }
        case LWImporterErrorTypeAlreadyImported: {
            errorDescription = @"You have already imported this class. ";
            break;
        }
        default:
            break;
    }
    
    NSError *error = [NSError errorWithDomain:@"LWImporter" code:errorType userInfo:@{NSLocalizedDescriptionKey : errorDescription}];
    
    if (completionHandler) {
        completionHandler(error);
    }
}

@end
