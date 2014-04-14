//  HTMLElement.m
//
//  Public domain. https://github.com/nolanw/HTMLReader

#import "HTMLElement.h"
#import "HTMLOrderedDictionary.h"
#import "HTMLSelector.h"

@implementation HTMLElement
{
    HTMLOrderedDictionary *_attributes;
}

- (id)initWithTagName:(NSString *)tagName attributes:(NSDictionary *)attributes
{
    self = [super init];
    if (!self) return nil;
    
    _tagName = [tagName copy];
    _attributes = [HTMLOrderedDictionary new];
    [_attributes addEntriesFromDictionary:attributes];
    
    return self;
}

- (id)init
{
    return [self initWithTagName:nil attributes:nil];
}

- (NSDictionary *)attributes
{
    return [_attributes copy];
}

- (id)objectForKeyedSubscript:(id)attributeName
{
    return _attributes[attributeName];
}

- (void)setObject:(NSString *)attributeValue forKeyedSubscript:(NSString *)attributeName
{
    _attributes[attributeName] = attributeValue;
}

- (void)removeAttributeWithName:(NSString *)attributeName
{
    [_attributes removeObjectForKey:attributeName];
}

- (BOOL)hasClass:(NSString *)className
{
    NSArray *classes = [self[@"class"] componentsSeparatedByCharactersInSet:HTMLSelectorWhitespaceCharacterSet()];
    return [classes containsObject:className];
}

- (void)toggleClass:(NSString *)className
{
    NSMutableArray *classes = [[self[@"class"] componentsSeparatedByCharactersInSet:HTMLSelectorWhitespaceCharacterSet()] mutableCopy];
    if (!classes) classes = [NSMutableArray new];
    NSUInteger i = [classes indexOfObject:className];
    if (i == NSNotFound) {
        [classes addObject:className];
    } else {
        [classes removeObjectAtIndex:i];
    }
    self[@"class"] = [classes componentsJoinedByString:@" "];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    HTMLElement *copy = [super copyWithZone:zone];
    copy->_tagName = self.tagName;
    copy->_attributes = [_attributes copy];
    return copy;
}

@end
