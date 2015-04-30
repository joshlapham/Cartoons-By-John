//
//  KJVideoCellTests.m
//  Kidney John
//
//  Created by jl on 30/04/2015.
//  Copyright (c) 2015 Josh Lapham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "KJVideo.h"
#import "KJVideoCell.h"

@interface KJVideoCellTests : XCTestCase

// Properties
@property (nonatomic) KJVideo *testVideo;
@property (nonatomic) KJVideoCell *testCell;

@end

@implementation KJVideoCellTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // Init video
    // TODO: update to use Core Data
    _testVideo = [[KJVideo alloc] init];
    _testVideo.videoName = @"Test Video";
    _testVideo.videoDate = @"2015-06-14";
    _testVideo.videoDescription = @"This is the greatest and best video in the world.";
    _testVideo.videoDuration = @"3:00";
    _testVideo.videoId = @"0001";
    
    // Init cell
    _testCell = [[KJVideoCell alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//- (void)testConfigureVideoCell {
    // Configure cell
//    [_testCell configureCellWithData:_testVideo];
    
//    XCTAssertNotNil(_testCell.videoTitle.text, @"Video title label text is empty");
//    XCTAssertNotNil(_testCell.videoDescription.text, @"Video description label text is empty");
//}

@end
