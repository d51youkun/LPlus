#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static NSString *LPlusLogPath(void) {
    NSString *library = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
    return [library stringByAppendingPathComponent:@"Caches/LPlusDiagnostics.log"];
}

static void LPlusWrite(NSString *line) {
    NSString *path = LPlusLogPath();
    NSString *directory = [path stringByDeletingLastPathComponent];
    [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *entry = [line stringByAppendingString:@"\n"];
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:path];
    if (!handle) {
        [entry writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        return;
    }
    [handle seekToEndOfFile];
    [handle writeData:[entry dataUsingEncoding:NSUTF8StringEncoding]];
    [handle closeFile];
}

static BOOL LPlusInterestingClass(NSString *name) {
    NSArray<NSString *> *terms = @[
        @"Advertise", @"Recommend", @"Tab", @"Sticker", @"MID",
        @"Settings", @"Call", @"Message", @"Search", @"Profile",
        @"Theme", @"Home"
    ];
    for (NSString *term in terms) {
        if ([name rangeOfString:term options:NSCaseInsensitiveSearch].location != NSNotFound) return YES;
    }
    return NO;
}

static void LPlusDumpMethods(Class cls, NSString *className) {
    unsigned int count = 0;
    Method *methods = class_copyMethodList(cls, &count);
    for (unsigned int i = 0; i < count; i++) {
        const char *name = sel_getName(method_getName(methods[i]));
        if (name) LPlusWrite([NSString stringWithFormat:@"METHOD %@ %@", className, @(name)]);
    }
    free(methods);
}

static void LPlusRunDiagnostics(void) {
    NSBundle *bundle = NSBundle.mainBundle;
    LPlusWrite(@"=== LPlus diagnostics start ===");
    LPlusWrite([NSString stringWithFormat:@"bundle=%@ version=%@ build=%@ os=%@",
                bundle.bundleIdentifier ?: @"",
                bundle.infoDictionary[@"CFBundleShortVersionString"] ?: @"",
                bundle.infoDictionary[@"CFBundleVersion"] ?: @"",
                UIDevice.currentDevice.systemVersion ?: @""]);

    int classCount = objc_getClassList(NULL, 0);
    if (classCount <= 0) return;
    Class *classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * classCount);
    classCount = objc_getClassList(classes, classCount);
    for (int i = 0; i < classCount; i++) {
        NSString *name = NSStringFromClass(classes[i]);
        if (name.length > 0 && LPlusInterestingClass(name)) {
            LPlusWrite([NSString stringWithFormat:@"CLASS %@", name]);
            LPlusDumpMethods(classes[i], name);
        }
    }
    free(classes);
    LPlusWrite([NSString stringWithFormat:@"Log path: %@", LPlusLogPath()]);
    LPlusWrite(@"=== LPlus diagnostics end ===");
}

%ctor {
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool { LPlusRunDiagnostics(); }
    });
}
