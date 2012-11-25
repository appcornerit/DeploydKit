//
//  NSData+DeploydKit.m
//  DeploydKit
//
//  Created by Denis Berton
//  Copyright (c) 2012 clooket.com. All rights reserved.
//
//  DeploydKit is based on DataKit (https://github.com/eaigner/DataKit)
//  Created by Erik Aigner
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "NSData+DeploydKit.h"

#import <CommonCrypto/CommonCryptor.h>

@implementation NSData (Hex)

+ (NSData *)dataWithHexString:(NSString *)hex {
  NSMutableData *data = [NSMutableData new];
  for (NSUInteger i=0; i<hex.length; i+=2) {
    char high = (char)[hex characterAtIndex:i];
    char low = (char)[hex characterAtIndex:i+1];
    char bchars[3] = {high, low, '\0'};
    UInt8 byte = strtol(bchars, NULL, 16);
    [data appendBytes:&byte length:1];
  }
  
  return [NSData dataWithData:data];
}

- (NSString *)hexString {
  NSUInteger capacity = self.length * 2;
  NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:capacity];
  const unsigned char *dataBuffer = self.bytes;
  NSInteger i;
  for (i=0; i<self.length; ++i) {
    [stringBuffer appendFormat:@"%02X", (NSUInteger)dataBuffer[i]];
  }
  return [NSString stringWithString:stringBuffer];
}

@end

@implementation NSData (Base64)

// http://www.cocoadev.com/index.pl?BaseSixtyFour

static const char _DKNSDataBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

+ (id)dataWithBase64String:(NSString *)string {
	if (string == nil) {
		[NSException raise:NSInvalidArgumentException format:nil];
  }
	if ([string length] == 0) {
		return [NSData data];
  }
  
	static char *decodingTable = NULL;
	if (decodingTable == NULL) {
		decodingTable = malloc(256);
		if (decodingTable == NULL) {
			return nil;
    }
		memset(decodingTable, CHAR_MAX, 256);
		NSUInteger i;
		for (i = 0; i < 64; i++) {
			decodingTable[(short)_DKNSDataBase64EncodingTable[i]] = i;
    }
	}
  
	const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
	if (characters == NULL) { //  Not an ASCII string!
		return nil;
  }
	char *bytes = malloc((([string length] + 3) / 4) * 3);
	if (bytes == NULL) {
		return nil;
  }
	NSUInteger length = 0;
  
	NSUInteger i = 0;
	while (YES) {
		char buffer[4];
		short bufferLength;
		for (bufferLength = 0; bufferLength < 4; i++) {
			if (characters[i] == '\0') {
				break;
      }
			if (isspace(characters[i]) || characters[i] == '=') {
				continue;
      }
			buffer[bufferLength] = decodingTable[(short)characters[i]];
			if (buffer[bufferLength++] == CHAR_MAX) {      //  Illegal character!
				free(bytes);
				return nil;
			}
		}
    
		if (bufferLength == 0) {
			break;
    }
		if (bufferLength == 1) { //  At least two characters are needed to produce one byte!
			free(bytes);
			return nil;
		}
    
		//  Decode the characters in the buffer to bytes.
		bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
		if (bufferLength > 2) {
			bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
    }
		if (bufferLength > 3) {
			bytes[length++] = (buffer[2] << 6) | buffer[3];
    }
	}
  
	realloc(bytes, length);
	return [NSData dataWithBytesNoCopy:bytes length:length];
}

- (NSString *)base64String {
	if ([self length] == 0) {
		return @"";
  }
  
  char *characters = malloc((([self length] + 2) / 3) * 4);
	if (characters == NULL) {
		return nil;
  }
	NSUInteger length = 0;
  
	NSUInteger i = 0;
	while (i < [self length]) {
		char buffer[3] = {0,0,0};
		short bufferLength = 0;
		while (bufferLength < 3 && i < [self length]) {
			buffer[bufferLength++] = ((char *)[self bytes])[i++];
    }
    
		//  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
		characters[length++] = _DKNSDataBase64EncodingTable[(buffer[0] & 0xFC) >> 2];
		characters[length++] = _DKNSDataBase64EncodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
		if (bufferLength > 1) {
			characters[length++] = _DKNSDataBase64EncodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
    }
		else {
      characters[length++] = '=';
    }
		if (bufferLength > 2) {
			characters[length++] = _DKNSDataBase64EncodingTable[buffer[2] & 0x3F];
    }
		else {
      characters[length++] = '=';
    }
	}
  
	return [[NSString alloc] initWithBytesNoCopy:characters
                                        length:length
                                      encoding:NSASCIIStringEncoding
                                  freeWhenDone:YES];
}

@end

@implementation NSData (AES256)

- (NSData *)AES256EncryptWithKey:(NSData *)key {
  assert(key.length <= 32 && "AES key should be 32 bytes or less");
	char keyPtr[kCCKeySizeAES256+1] = {0};
  [key getBytes:keyPtr];
	
	NSUInteger dataLength = [self length];
	
	// See the doc: For block ciphers, the output size will always be less than or 
	// equal to the input size plus the size of one block.
	// That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesEncrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, 0,
                                        keyPtr, kCCKeySizeAES256,
                                        NULL, // initialization vector (optional)
                                        self.bytes, dataLength, // input
                                        buffer, bufferSize, // output
                                        &numBytesEncrypted);
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
	}
  
	free(buffer); //free the buffer;
	return nil;
}

- (NSData *)AES256DecryptWithKey:(NSData *)key {
  assert(key.length <= 32 && "AES key should be 32 bytes or less");
	char keyPtr[kCCKeySizeAES256+1] = {0};
  [key getBytes:keyPtr];
	
	NSUInteger dataLength = self.length;
	
	// See the doc: For block ciphers, the output size will always be less than or 
	// equal to the input size plus the size of one block.
	// That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesDecrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, 0,
                                        keyPtr, kCCKeySizeAES256,
                                        NULL, // initialization vector (optional)
                                        self.bytes, dataLength, // input
                                        buffer, bufferSize, // output
                                        &numBytesDecrypted);
	
	if (cryptStatus == kCCSuccess) {
		return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
	}
	
	free(buffer);
	return nil;
}

@end