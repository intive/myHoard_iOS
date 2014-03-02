//
//  MHImagePickerViewControllerTest.m
//  MyHoard
//
//  Created by user on 3/2/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "MHImagePickerViewController.h"
#import "MHDatabaseManager.h"
#import "MHMedia.h"

@interface MHImagePickerViewControllerTest : XCTestCase {
    
    MHImagePickerViewController *_vc;
    UIStoryboard *storyboard;
    UIImagePickerController *pickerController;
}

@end

@implementation MHImagePickerViewControllerTest

- (void)setUp
{
    [super setUp];
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _vc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([MHImagePickerViewController class])];
    [_vc view];
}

- (void)tearDown
{
    _vc = nil;
    storyboard = nil;
    [super tearDown];
}

- (void)testStoryboardShouldExist {
    
    XCTAssertNotNil(storyboard, @"");
}

- (void)testViewControllerShouldExist {
    
    XCTAssertNotNil(_vc, @"");
}

- (void)testThatCameraButtonExist {
    
    XCTAssertNotNil(_vc.navigationItem.rightBarButtonItem, @"");
}

- (void)testThatLibraryButtonExist {
    
    XCTAssertNotNil(_vc.navigationItem.leftBarButtonItem, @"");
}

- (void)testShowImagePickerForPhotoLibrary {
    
    SEL selector = NSSelectorFromString(@"showImagePickerForPhotoLibrary:");
    XCTAssertTrue([_vc respondsToSelector:selector], @"_vc should respond to selector showImagePickerForPhotoLibrary");
}

- (void)testShowImagePickerForCamera {
    
    SEL selector = NSSelectorFromString(@"showImagePickerForCamera:");
    XCTAssertTrue([_vc respondsToSelector:selector], @"_vc should respond to selector showImagePickerForCamera");
}

- (void)testPickFromLibrary {
    
    pickerController = [[UIImagePickerController alloc]init];
    id mockPicker = [OCMockObject partialMockForObject:pickerController];
    [[[mockPicker stub] andReturn:@0]setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];

}

- (void)testPickFromCamera {
    
    pickerController = [[UIImagePickerController alloc]init];
    id mockPicker = [OCMockObject partialMockForObject:pickerController];
    [[[mockPicker stub] andReturn:@1]setSourceType:UIImagePickerControllerSourceTypeCamera];
    
}

- (void)testDidFinishPickingMediaWithInfo {
    
    id mockVC = [OCMockObject partialMockForObject:_vc];
    
    pickerController = [[UIImagePickerController alloc]init];
    id mockPicker = [OCMockObject partialMockForObject:pickerController];
    
    id mockImage = [OCMockObject niceMockForClass:[UIImage class]];
    NSDictionary *info = [NSDictionary dictionaryWithObject:mockImage forKey:UIImagePickerControllerOriginalImage];
    
    [mockVC imagePickerController:mockPicker didFinishPickingMediaWithInfo:info];
    
    [mockPicker verify];
    [mockImage verify];
    [mockVC verify];
    
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    XCTAssertNotNil(mockImage, @"");
    XCTAssertNotNil(image, @"");
    XCTAssertEqualObjects(mockImage, image, @"");
    
    NSURL *mockUrl = [NSURL URLWithString:@"fakeStringForTesting"];
    
    info = [NSDictionary dictionaryWithObject:mockUrl forKey:UIImagePickerControllerReferenceURL];
    
    NSURL *imageUrl = [info valueForKey:UIImagePickerControllerReferenceURL];
    
    NSString *imagePath = [imageUrl absoluteString];
    
    XCTAssertNotNil(imageUrl, @"");
    XCTAssertNotNil(imagePath, @"");
    
    NSString *mediaObjId = [[imageUrl path]lastPathComponent];
    
    [MHDatabaseManager insertMediaWithObjId:mediaObjId objItem:nil objCreatedDate:[NSDate date] objOwner:nil objLocalPath:imagePath];
    MHMedia *fetchedMedia = [MHDatabaseManager mediaWithObjId:mediaObjId];
    
    XCTAssertNotNil(fetchedMedia, @"");
    XCTAssertEqual(fetchedMedia.objId, mediaObjId, @"");
    XCTAssertEqual(fetchedMedia.objLocalPath, imagePath, @"");
    
    [MHDatabaseManager removeMediaWithObjId:mediaObjId];
}

@end
