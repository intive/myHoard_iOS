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
    _vc = [[MHImagePickerViewController alloc] init];
    [_vc view];
}

- (void)tearDown
{
    _vc = nil;
    storyboard = nil;
    [super tearDown];
}

- (void)testViewDidLoad {

    // Testy zazwyczaj wykonujemy na symulatorze. Tam nie ma kamery.
    /*
    [_vc viewDidLoad];
    
    XCTAssertNotNil(_vc.capturedImages, @"");
    if (_vc.imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
        XCTAssertEqual(_vc.navigationItem.rightBarButtonItem.enabled, NO, @"");
    }*/
}

- (void)testViewControllerShouldExist {
    
    XCTAssertNotNil(_vc, @"");
}

- (void)testShowImagePickerForSource {
    
    /*if (_vc.imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
        XCTAssertEqual(_vc.imagePickerController.showsCameraControls, NO, @"");
        XCTAssertEqual([NSBundle mainBundle], @"MHImagePickerViewController", @"");
        //XCTAssertEqual(_vc.MHIPView.frame, _vc.imagePickerController.cameraOverlayView.frame, @"");
        XCTAssertEqual(_vc.imagePickerController.cameraOverlayView, _vc.MHIPView, @"");
        XCTAssertNil(_vc.MHIPView, @"");
    }
    
    XCTAssertEqual(_vc.presentedViewController, _vc.imagePickerController, @"");*/
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


- (void)testLocationFromImage {
//    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
//    NSString *filePath = [bundle pathForResource:@"testImage" ofType:@"JPG"];
//    
//    CLLocationCoordinate2D testCoordinates = [_vc locationForImage:filePath];
//
//    XCTAssertEqualWithAccuracy(testCoordinates.latitude, 53.43069166666667, 0.000000001);
//    XCTAssertEqualWithAccuracy(testCoordinates.longitude, 14.55534166666667, 0.000000001);
    
}

- (void)testIsLocationInImage {
//    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
//    NSString *filePath = [bundle pathForResource:@"testImage" ofType:@"JPG"];
//
//    XCTAssertEqual([_vc isLocationInImage:(NSString *)filePath], YES, @"");
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
    
}



@end
