//
//  LWAssumeNonnullSourceEditorCommand.m
//  Extensions
//
//  Created by allensun on 06/12/2017.
//  Copyright © 2017 Uncle Wang Tech. All rights reserved.
//

#import "LWAssumeNonnullSourceEditorCommand.h"

NS_ASSUME_NONNULL_BEGIN

NSString *const LWAssumeNonnullBegin = @"NS_ASSUME_NONNULL_BEGIN";
NSString *const LWAssumeNonnullEnd = @"NS_ASSUME_NONNULL_END";

@interface LWClass : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSUInteger line;

@end

@implementation LWClass

@end

@interface LWAssumeNonnullSourceEditorCommand ()

@property (nullable, nonatomic, strong) NSMutableArray<NSString *> *lines;

@end

NS_ASSUME_NONNULL_END

@implementation LWAssumeNonnullSourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    NSString *contentUTI = invocation.buffer.contentUTI;
    
    if (![contentUTI isEqualToString:@"public.objective-c-source"] &&
        ![contentUTI isEqualToString:@"public.objective-c-plus-plus-source"] &&
        ![contentUTI isEqualToString:@"public.c-header"]) {
        
        [self handleError:LWAssumeNonnullErrorTypeUnsupportedFileType withCompletionHandler:completionHandler];
        return;
    }
    
    self.lines = invocation.buffer.lines;
    
    if ([contentUTI isEqualToString:@"public.objective-c-source"] ||
        [contentUTI isEqualToString:@"public.objective-c-plus-plus-source"]) {
        
        [self updateImplementations];
    }
    
    [self updateInterfaces];
    
    self.lines = nil;
    
    completionHandler(nil);
}

- (void)updateImplementations
{
    NSArray<LWClass *> *implementations = [self allImplementations];
    
    NSUInteger delta = 0;
    
    for (LWClass *classObject in implementations) {
        
        if ([self shouldAddCategoryForClass:classObject]) {
            
            [self addCategoryForClass:classObject withDelta:&delta];
        }
    }
}

- (void)updateInterfaces
{
    NSArray<NSValue *> *allInterfaces = [self allInterfaces];
    
    NSUInteger delta = 0;
    
    for (NSValue *value in allInterfaces) {
        
        NSRange range = value.rangeValue;
        
        if ([self shouldAssumeNonnullBeginForInterface:range]) {
            
            [self assumeNonnullBeginForInterface:range withDelta:&delta];
        }
        
        if ([self shouldAssumeNonnullEndForInterface:range]) {
            
            [self assumeNonnullEndForInterface:range withDelta:&delta];
        }
    }
}

- (NSArray<NSValue *> *)allInterfaces
{
    NSMutableArray<NSValue *> *interfaces = [NSMutableArray new];
    
    NSUInteger startLine = 0;
    
    for (NSUInteger i = 0; i < self.lines.count; i++) {
        
        NSString *line = self.lines[i];
        
        if ([line hasPrefix:@"@interface "]) {
            
            if (startLine == 0) {
                startLine = i;
            }
            continue;
        }
        
        if (startLine > 0 && [line hasPrefix:@"@end"]) {
            
            NSRange range = NSMakeRange(startLine, i - startLine);
            
            [interfaces addObject:[NSValue valueWithRange:range]];
            
            startLine = 0;
            
            continue;
        }
    }
    
    return interfaces;
}

- (BOOL)shouldAssumeNonnullBeginForInterface:(NSRange)rangeOfInterface
{
    NSUInteger line = rangeOfInterface.location;
    
    if (line > 0) {
        
        NSString *string = self.lines[line - 1];
        
        if ([string hasPrefix:LWAssumeNonnullBegin]) {
            return NO;
        }
    }
    
    if (line > 1) {
        
        NSString *string = self.lines[line - 2];
        
        if ([string hasPrefix:LWAssumeNonnullBegin]) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)shouldAssumeNonnullEndForInterface:(NSRange)rangeOfInterface
{
    NSUInteger line = rangeOfInterface.location + rangeOfInterface.length;
    
    if (line + 1 < self.lines.count) {
        
        NSString *string = self.lines[line + 1];
        
        if ([string hasPrefix:LWAssumeNonnullEnd]) {
            return NO;
        }
    }
    
    if (line + 2 < self.lines.count) {
        
        NSString *string = self.lines[line + 2];
        
        if ([string hasPrefix:LWAssumeNonnullEnd]) {
            return NO;
        }
    }
    
    return YES;
}

- (void)assumeNonnullBeginForInterface:(NSRange)range withDelta:(NSUInteger *)aDelta
{
    NSUInteger index = range.location;
    NSUInteger delta = *aDelta;
    
    if (index + delta == 0 || (self.lines[index + delta - 1].length > 0 && ![self.lines[index + delta - 1] isEqualToString:@"\n"])) {
        
        [self.lines insertObject:@"\n" atIndex:index + delta];
        delta ++;
    }
    
    [self.lines insertObject:LWAssumeNonnullBegin atIndex:index + delta];
    delta++;
    
    [self.lines insertObject:@"\n" atIndex:index + delta];
    delta++;
    
    *aDelta = delta;
}

- (void)assumeNonnullEndForInterface:(NSRange)range withDelta:(NSUInteger *)aDelta
{
    NSUInteger index = range.location + range.length + 1;
    NSUInteger delta = *aDelta;
    
    [self insertOrAddString:@"\n" atIndex:index + delta];
    delta++;
    
    [self insertOrAddString:LWAssumeNonnullEnd atIndex:index + delta];
    delta++;
    
    *aDelta = delta;
}

- (void)insertOrAddString:(NSString *)string atIndex:(NSUInteger)index
{
    if (index >= self.lines.count) {
        [self.lines addObject:string];
    } else {
        [self.lines insertObject:string atIndex:index];
    }
}

- (NSArray<LWClass *> *)allImplementations
{
    NSMutableArray<LWClass *> *array = [NSMutableArray new];
    
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet alphanumericCharacterSet];
    [characterSet addCharactersInString:@"_"];
    
    for (NSUInteger i = 0; i < self.lines.count; i++) {
        
        @autoreleasepool {
            
            NSString *line = self.lines[i];
            
            NSString *const prefix = @"@implementation ";
            
            if ([line hasPrefix:prefix]) {
                
                NSUInteger startIndex = prefix.length;
                
                for (NSUInteger j = startIndex; j < line.length; j++) {
                    
                    unichar c = [line characterAtIndex:j];
                    
                    if (![characterSet characterIsMember:c]) {
                        
                        if (j > startIndex) {
                            
                            NSString *className = [line substringWithRange:NSMakeRange(startIndex, j - startIndex)];
                            
                            LWClass *object = [LWClass new];
                            object.name = className;
                            object.line = i;
                            
                            [array addObject:object];
                        }
                        break;
                    } //endif
                } //endfor
            } //endif
        } //endautoreleasepool
    } //endfor
    
    return array;
}

- (BOOL)shouldAddCategoryForClass:(LWClass *)classObject
{
    NSString *interfaceString = [NSString stringWithFormat:@"@interface %@", classObject.name];
    
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet alphanumericCharacterSet];
    [characterSet addCharactersInString:@"_"];
    
    for (NSString *line in self.lines) {
        
        if ([line hasPrefix:interfaceString]) {
            
            //Illegal interface
            if (line.length == interfaceString.length) {
                continue;
            }
            
            //Not the same class
            unichar c = [line characterAtIndex:interfaceString.length];
            
            if ([characterSet characterIsMember:c]) {
                continue;
            }
            
            return NO;
        }
    }
    
    return YES;
}

- (void)addCategoryForClass:(LWClass *)classObject withDelta:(NSUInteger *)aDelta
{
    NSUInteger delta = *aDelta;
    NSUInteger line = classObject.line;
    
    //Add an empty line if needed
    if (line + delta == 0 || (self.lines[line + delta - 1].length > 0 && ![self.lines[line + delta - 1] isEqualToString:@"\n"])) {
        
        [self.lines insertObject:@"\n" atIndex:line + delta];
        delta ++;
    }
    
    //Add default category
    [self.lines insertObject:[NSString stringWithFormat:@"@interface %@ ()", classObject.name] atIndex:line + delta];
    delta++;
    
    [self.lines insertObject:@"\n" atIndex:line + delta];
    delta++;
    
    [self.lines insertObject:@"@end" atIndex:line + delta];
    delta++;
    
    [self.lines insertObject:@"\n" atIndex:line + delta];
    delta++;
    
    *aDelta = delta;
}

- (void)handleError:(LWAssumeNonnullErrorType)errorType withCompletionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    NSString *errorDescription = @"";
    
    switch (errorType) {
        case LWAssumeNonnullErrorTypeUnsupportedFileType: {
            errorDescription = @"Only support Objective-C files like .h, .m, .mm. ";
            break;
        }
        default:
            break;
    }
    
    NSError *error = [NSError errorWithDomain:@"LWAssumeNonnull" code:errorType userInfo:@{NSLocalizedDescriptionKey : errorDescription}];
    
    if (completionHandler) {
        completionHandler(error);
    }
}

@end
