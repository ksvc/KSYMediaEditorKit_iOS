//
//  KSS3ListPartsResultXMLParser.m
//  KS3SDK
//
//  Created by JackWong on 12/16/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3ListPartsResultXMLParser.h"
#import "KS3Part.h"

@interface KS3ListPartsResultXMLParser ()
@property (strong, nonatomic) NSString *currentTag;
@property (strong, nonatomic) NSMutableString *currentText;
@property (assign, nonatomic) BOOL isInitiator;
@property (assign, nonatomic) BOOL isOwner;
@property (strong, nonatomic) KS3Part *part;
@end

@implementation KS3ListPartsResultXMLParser

- (void)kSS3XMLarse:(NSData *)dataXml
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:dataXml];
    [parser setDelegate:self];
    [parser parse];
    
}


#pragma mark - Xml delegate

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    _listPartsResult = [[KS3ListPartsResult alloc] init];
    
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
 if ([elementName isEqualToString:@"ns2:Initiator"]){
        _isInitiator = YES;
        _isOwner = NO;
        if (nil != _listPartsResult.initiator) {
            _listPartsResult.initiator = nil;
        }
        _listPartsResult.initiator = [[KS3Owner alloc] init];
        
    }else if ([elementName isEqualToString:@"ns2:Owner"]){
        _isOwner = YES;
        _isInitiator = NO;
        if (nil != _listPartsResult.owner) {
            _listPartsResult.owner = nil;
        }
        _listPartsResult.owner = [[KS3Owner alloc] init];
    }else if ([elementName isEqualToString:@"ns2:Part"]){
        if (nil != _part) {
            _part = nil;
        }
        _part = [KS3Part new];
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
    
    
    if (!_isInitiator && !_isOwner) {
        if ([elementName isEqualToString:@"ns2:Bucket"]) {
            _listPartsResult.Bucket = _currentText;
        }else if ([elementName isEqualToString:@"ns2:Key"]){
            _listPartsResult.key = _currentText;
        }else if ([elementName isEqualToString:@"ns2:UploadId"]){
            _listPartsResult.UploadId = _currentText;
        }else if ([elementName isEqualToString:@"ns2:PartNumberMarker"]){
            _listPartsResult.partNumberMarker = (int32_t)[_currentText integerValue];
        }else if ([elementName isEqualToString:@"ns2:MaxParts"]){
            _listPartsResult.maxParts = (int32_t)[_currentText integerValue];
        }else if ([elementName isEqualToString:@"PartNumber"]) {
            _part.partNumber = (int32_t)[_currentText integerValue];
        }else if ([elementName isEqualToString:@"ETag"]){
            _part.etag = _currentText;
        }else if ([elementName isEqualToString:@"LastModified"]){
            _part.lastModified = _currentText;
        }else if ([elementName isEqualToString:@"Size"]){
            _part.size = [_currentText longLongValue];
        }else if ([elementName isEqualToString:@"ns2:Part"]){
            [_listPartsResult.parts addObject:_part];
        }
    }else if (_isInitiator && !_isOwner) {
        if ([elementName isEqualToString:@"ns2:ID"]) {
            _listPartsResult.initiator.ID = _currentText;
        }else if ([elementName isEqualToString:@"ns2:DisplayName"]){
            _listPartsResult.initiator.displayName = _currentText;
        }else if ([elementName isEqualToString:@"ns2:Initiator"]){
            _isInitiator = NO;
        }
        
    }else if (_isOwner && !_isInitiator){
        if ([elementName isEqualToString:@"ns2:ID"]) {
            _listPartsResult.initiator.ID = _currentText;
        }else if ([elementName isEqualToString:@"ns2:DisplayName"]){
            _listPartsResult.initiator.displayName = _currentText;
        }else if ([elementName isEqualToString:@"ns2:Owner"]){
            _isOwner =  NO;
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
