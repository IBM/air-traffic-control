////
////  MarkerView.m
////  Around Me
////
////  Created by jdistler on 11.02.13.
////  Copyright (c) 2013 Jean-Pierre Distler. All rights reserved.
////
//
//#import "MarkerView.h"
//
//#import "ARGeoCoordinate.h"
//
//const float kWidth = 200.0f;
//const float kHeight = 100.0f;
//
//@interface MarkerView ()
//
//@property (nonatomic, strong) UILabel *lblDistance;
//
//@end
//
//
//@implementation MarkerView
//
//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}
//
//- (id)initWithCoordinate:(ARGeoCoordinate *)coordinate delegate:(id<MarkerViewDelegate>)delegate {
//	if((self = [super initWithFrame:CGRectMake(0.0f, 0.0f, kWidth, kHeight)])) {
//		_coordinate = coordinate;
//		_delegate = delegate;
//		
//		[self setUserInteractionEnabled:YES];
//		
//		UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kWidth, 40.0f)];
//		[title setBackgroundColor:[UIColor colorWithWhite:0.3f alpha:0.7f]];
//		[title setTextColor:[UIColor whiteColor]];
//		[title setTextAlignment:NSTextAlignmentCenter];
//		[title setText:[coordinate title]];
//		[title sizeToFit];
//		
//		_lblDistance = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 45.0f, kWidth, 40.0f)];
//		
//		[_lblDistance setBackgroundColor:[UIColor colorWithWhite:0.3f alpha:0.7f]];
//		[_lblDistance setTextColor:[UIColor whiteColor]];
//		[_lblDistance setTextAlignment:NSTextAlignmentCenter];
//		[_lblDistance setText:[NSString stringWithFormat:@"%.2f km", [coordinate distanceFromOrigin] / 1000.0f]];
//		[_lblDistance sizeToFit];
//		
//		[self addSubview:title];
//		[self addSubview:_lblDistance];
//		
//		[self setBackgroundColor:[UIColor clearColor]];
//	}
//
//	return self;
//}
//
//- (void)drawRect:(CGRect)rect {
//	[super drawRect:rect];
//    [[self lblDistance] setText:[NSString stringWithFormat:@"%.2f km", [[self coordinate] distanceFromOrigin] / 1000.0f]];
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//	if(_delegate && [_delegate conformsToProtocol:@protocol(MarkerViewDelegate)]) {
//		[_delegate didTouchMarkerView:self];
//	}
//}
//
//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
//    
//    CGRect theFrame = CGRectMake(0, 0, kWidth, kHeight);
//    
//	return CGRectContainsPoint(theFrame, point);
//}
//
//@end
