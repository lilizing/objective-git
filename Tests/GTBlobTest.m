//
//  GTBlobTest.m
//  ObjectiveGitFramework
//
//  Created by Timothy Clem on 2/25/11.
//
//  The MIT License
//
//  Copyright (c) 2011 Tim Clem
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "Contants.h"

@interface GTBlobTest : GHTestCase {
	
	GTRepository *repo;
	NSString *sha;
}
@end

@implementation GTBlobTest

- (void)setUp {
	
	NSError *error = nil;
	repo = [GTRepository repoByOpeningRepositoryInDirectory:[NSURL URLWithString:TEST_REPO_PATH] error:&error];
	sha = @"fa49b077972391ad58037050f2a75f74e3671e92";
}

- (void)testCanReadBlobData {
	
	NSError *error = nil;
	GTBlob *blob = (GTBlob *)[repo lookup:sha error:&error];
	GHAssertEquals(9, (int)blob.size, nil);
	GHAssertEqualStrings(@"new file\n", blob.content, nil);
	GHAssertEqualStrings(@"blob", blob.type, nil);
	GHAssertEqualStrings(sha, blob.sha, nil);
}

- (void)testCanRewriteBlobData {
	
	NSError *error = nil;
	GTBlob *blob = (GTBlob *)[repo lookup:sha error:&error];
	blob.content = @"my new content";
	GHAssertEqualStrings(sha, blob.sha, nil);
	
	[blob writeAndReturnError:&error];
	
	GHAssertNil(error, nil);
	GHAssertEqualStrings(@"2dd916ea1ff086d61fbc1c286079305ffad4e92e", blob.sha, nil);
	rm_loose(blob.sha);
}

- (void)testCanWriteNewBlobData {
	
	NSError *error = nil;
	GTBlob *blob = [[[GTBlob alloc] initInRepo:repo error:&error] autorelease];
	GHAssertNil(error, nil);
	GHAssertNotNil(blob, nil);
	blob.content = @"a new blob content";
	
	[blob writeAndReturnError:&error];
	GHAssertNil(error, nil);
	
	rm_loose(blob.sha);
}

- (void)testCanGetCompleteContentWithNulls {

	NSError *error = nil;
	char bytes[] = "100644 example_helper.rb\00\xD3\xD5\xED\x9D A4_\x00 40000 examples";
	NSData *content = [NSData dataWithBytes:bytes length:sizeof(bytes)];
	GTRawObject *obj = [GTRawObject rawObjectWithType:GIT_OBJ_BLOB data:content];

	NSString *newSha = [repo write:obj error:&error];

	GHAssertNil(error, nil);
	GHAssertNotNil(newSha, nil);
	GTBlob *blob = (GTBlob *)[repo lookup:newSha error:&error];
	GTRawObject *newObj = [blob readRawAndReturnError:&error];
	GHAssertNil(error, nil);
	GHTestLog(@"original content = %@", [obj data]);
	GHTestLog(@"lookup content   = %@", [newObj data]);
	GHAssertTrue([newObj.data isEqualToData:obj.data], nil);
	rm_loose(newSha);
}

@end