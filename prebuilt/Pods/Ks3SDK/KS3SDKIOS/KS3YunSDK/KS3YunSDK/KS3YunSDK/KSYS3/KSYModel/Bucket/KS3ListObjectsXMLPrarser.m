//
//  KSS3ListObjectsXMLPrarser.m
//  KS3SDK
//
//  Created by JackWong on 12/14/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3ListObjectsXMLPrarser.h"
#import "KS3ListObjectsResult.h"
#import "KS3ObjectSummary.h"
#import "KS3Owner.h"

@interface KS3ListObjectsXMLPrarser ()

@property (strong, nonatomic) NSString *currentTag;
@property (strong, nonatomic) NSMutableString *currentText;
@property (strong, nonatomic) KS3ObjectSummary *objectSummary;

@property (nonatomic) BOOL isContents;
@property (nonatomic) BOOL isOwner;
@property (nonatomic) BOOL isCommonPrefixes;

@end


@implementation KS3ListObjectsXMLPrarser


- (void)kSS3XMLarse:(NSData *)dataXml
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:dataXml];
    [parser setDelegate:self];
    [parser parse];
    
}


#pragma mark - Xml delegate

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    _listBuctkResult = [[KS3ListObjectsResult alloc] init];
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
    
    if ([elementName isEqualToString:@"Contents"]) {
        _isContents = YES;
        _isCommonPrefixes = NO;
        if (nil != _objectSummary ) {
            _objectSummary = nil;
        }
        _objectSummary = [KS3ObjectSummary new];
        
    }
    if ([elementName isEqualToString:@"Owner"]) {
        if (nil != _objectSummary.owner) {
            _objectSummary.owner = nil;
        }
        _objectSummary.owner = [KS3Owner new];
    }
    if ([elementName isEqualToString:@"CommonPrefixes"]) {
        _isCommonPrefixes = YES;
        _isContents = NO;
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

        if (_isContents) {
        if ([elementName isEqualToString:@"Key"]) {
            _objectSummary.Key = _currentText;
        }else if ([elementName isEqualToString:@"LastModified"]){
            _objectSummary.LastModified = _currentText;
        }else if ([elementName isEqualToString:@"ETag"]){
            _objectSummary.ETag = _currentText;
            
        }else if ([elementName isEqualToString:@"Size"]){
            _objectSummary.size = (int32_t)[_currentText integerValue];
            
        }else if ([elementName isEqualToString:@"ID"]){
            _objectSummary.owner.ID = _currentText;
            
        }else if ([elementName isEqualToString:@"DisplayName"]){
            _objectSummary.owner.displayName = _currentText;
            
        }else if ([elementName isEqualToString:@"StorageClass"]){
            _objectSummary.storageClass = _currentText;
        }else if ([elementName isEqualToString:@"Contents"]){
            [_listBuctkResult.objectSummaries addObject:_objectSummary];
            _isContents = NO;
            
        }
    }else if (_isCommonPrefixes){
        if ([elementName isEqualToString:@"Prefix"]) {
            [_listBuctkResult.commonPrefixes addObject:_currentText];
        }else if ([elementName isEqualToString:@"CommonPrefixes"]){
            _isCommonPrefixes = NO;
        }
        
    }else{
        if ([elementName isEqualToString:@"Name"]) {
            _listBuctkResult.bucketName = _currentText;
        }else if ([elementName isEqualToString:@"Marker"]) {
            _listBuctkResult.marker = _currentText;
        }else if ([elementName isEqualToString:@"NextMarker"]) {
            _listBuctkResult.NextMarker = _currentText;
        }else if ([elementName isEqualToString:@"MaxKeys"]) {
            _listBuctkResult.maxKeys = (int32_t)[_currentText integerValue];
        }else if ([elementName isEqualToString:@"Delimiter"]) {
            _listBuctkResult.delimiter = _currentText;
        }else if ([elementName isEqualToString:@"IsTruncated"]) {
            _listBuctkResult.IsTruncated = [_currentText boolValue];
        }

    }
    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    
    
}


@end
