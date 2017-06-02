//
//  KSS3ObjectACLXMLParser.m
//  KS3SDK
//
//  Created by JackWong on 12/15/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3ObjectACLXMLParser.h"
#import "KS3Grant.h"

@interface KS3ObjectACLXMLParser ()
@property (strong, nonatomic) NSString *currentTag;
@property (strong, nonatomic) NSMutableString *currentText;
@property (strong, nonatomic) KS3Grant *grant;
@property (strong, nonatomic) KS3Grantee *grantee;
@property (nonatomic) BOOL isOwnerParser;
@property (nonatomic) BOOL isGrantParser;
@end

@implementation KS3ObjectACLXMLParser
- (void)kSS3XMLarse:(NSData *)dataXml
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:dataXml];
    [parser setDelegate:self];
    [parser parse];
    
}


#pragma mark - Xml delegate

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    _listBuctkResult = [[KS3BucketACLResult alloc] init];
}

- (void) parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
     attributes:(NSDictionary *)attributeDict
{
    if (nil != _currentText) {
        _currentText = nil;
    }
    _currentTag = elementName;
    
    if ([elementName isEqualToString:@"Owner"]) {
        _listBuctkResult.owner = [KS3Owner new];
        _isOwnerParser = YES;
        _isGrantParser = NO;
    }
    if ([elementName isEqualToString:@"Grant"]) {
        if (nil != _grant) {
            _grant = nil;
        }
        if (nil != _grantee) {
            _grantee = nil;
        }
        _grantee = [KS3Grantee new];
        _grant = [KS3Grant new];
        
        _isGrantParser = YES;
        _isOwnerParser = NO;
        
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (nil == _currentText) {
        _currentText = [[NSMutableString alloc] init];
    }
    [_currentText appendString:string];
}

- (void) parser:(NSXMLParser *)parser
  didEndElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
{
    if (_isOwnerParser) {
        if ([elementName isEqualToString:@"ID"]) {
            _listBuctkResult.owner.ID = _currentText;
        }
        if ([elementName isEqualToString:@"DisplayName"]) {
            _listBuctkResult.owner.displayName = _currentText;
        }
    }
    if (_isGrantParser) {
        if ([elementName isEqualToString:@"ID"]) {
            _grantee.ID = _currentText;
        }
        if ([elementName isEqualToString:@"DisplayName"]) {
            _grantee.displayName = _currentText;
        }
        if ([elementName isEqualToString:@"URI"]) {
            _grantee.URI = _currentText;
        }
        if ([elementName isEqualToString:@"Permission"]) {
            _grant.permission = _currentText;
        }
    }
    if ([elementName isEqualToString:@"Owner"]) {
        _isOwnerParser = NO;
    }
    if ([elementName isEqualToString:@"Grant"]) {
        _isGrantParser = NO;
        _grant.grantee = _grantee;
        [_listBuctkResult.accessControlList addObject:_grant];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    
    
}

@end
