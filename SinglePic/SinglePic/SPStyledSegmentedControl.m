//
//  SPStyledSegmentedControl.m
//  SinglePic
//
//  Created by Ryan Renna on 2012-02-26.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SPStyledSegmentedControl.h"
#import "UIColor+Expanded.h"

@interface SPStyledSegmentedControl()
@property (retain) NSArray* items;
@property (retain) UIFont  *font;
@property (retain) UIColor* selectedItemColor;
@property (retain) UIColor* unselectedItemColor;
@property (retain) UIColor* unselectedItemShadowColor;
@end

@implementation SPStyledSegmentedControl
@synthesize items,selectedItemColor,unselectedItemColor,unselectedItemShadowColor;
@dynamic font;
#pragma mark - Dynamic Properties
- (UIFont *)font
{
	if (font == nil) {
		self.font = [UIFont fontWithName:FONT_NAME_PRIMARY size:FONT_SIZE_MEDIUM];
	}
	return font;
}
- (void)setFont:(UIFont *)aFont
{
	if (font != aFont) {
		[font release];
		font = [aFont retain];
        
		[self setNeedsDisplay];
	}
}
#pragma mark
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {        
        [self setupLayers];
        [self setStyle:STYLE_DEFAULT];
        //self.height = 35;
    }
    return  self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        self.layer.needsDisplayOnBoundsChange = YES;
        self.frame = frame;
        
        [self setupLayers];
        [self setStyle:STYLE_DEFAULT];
        [self setDepth:DEPTH_OUTSET];
    }
    return self;
}
-(void)dealloc
{
    [selectedItemColor release];
    [unselectedItemColor release];
    [items release];
    [bevelLayer release];
    [colorLayer release];
    [darkenLayer release];
    [colorGradientLayer release];
    [tint release];
    [super dealloc];
}
- (void)awakeFromNib
{
	NSMutableArray *ar = [NSMutableArray arrayWithCapacity:self.numberOfSegments];
    
	for (int i = 0; i < self.numberOfSegments; i++) {
		NSString *aTitle = [self titleForSegmentAtIndex:i];
		if (aTitle) {
			[ar addObject:aTitle];
		} else {
			UIImage *anImage = [self imageForSegmentAtIndex:i];
			if (anImage) {
				[ar addObject:anImage];
			}
		}
	}
    
	self.items = ar;
	[self setNeedsDisplay];
}

- (void)layoutSubviews
{
	for (UIView *subView in self.subviews) {
		[subView removeFromSuperview];
	}
}
#pragma mark
-(void)setStyle:(STYLE)style
{
    if(style == STYLE_DEFAULT)
    {
        self.selectedItemColor = [UIColor colorWithWhite:0.6 alpha:1];
        self.unselectedItemColor = [UIColor colorWithWhite:0.6 alpha:1];
        
        [tint release];
        tint = [TINT_DEFAULT retain];	
    }
    else if(style == STYLE_WHITE)
    {
        self.selectedItemColor = [UIColor colorWithWhite:0.75 alpha:1];
        self.unselectedItemColor = [UIColor colorWithWhite:0.8 alpha:1];
        
        [tint release];
        tint = [TINT_WHITE retain];
    }
    else if(style == STYLE_TAB)
    {
        self.selectedItemColor = [UIColor colorWithWhite:0.75 alpha:1];
        self.unselectedItemColor = [UIColor colorWithWhite:0.6 alpha:1];
        
        [tint release];
        tint = [TINT_TAB retain];
    }
    else if(style == STYLE_PAGE)
    {
        self.selectedItemColor = [UIColor colorWithWhite:0.75 alpha:1];
        self.unselectedItemColor = [UIColor colorWithWhite:0.6 alpha:1];
             
        [tint release];
        tint = [TINT_PAGE retain];
    }
    else if(style == STYLE_BASE)
    {
        self.selectedItemColor = [UIColor colorWithWhite:0.85 alpha:1];
        self.unselectedItemColor = [UIColor colorWithWhite:0.9 alpha:1];
        self.unselectedItemShadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];

        [tint release];
        //Nice and dark
        tint = [[TINT_BASE colorByMultiplyingByRed:0.78 green:0.95 blue:0.95 alpha:1.0] retain];
        unselectedTint = [[TINT_BASE colorByMultiplyingByRed:0.9 green:0.9 blue:0.9 alpha:1.0] retain];
    }
    else if(style == STYLE_CONFIRM_BUTTON)
    {
        self.selectedItemColor = [UIColor colorWithWhite:0.75 alpha:1];
        self.unselectedItemColor = [UIColor colorWithWhite:0.95 alpha:1];
        
        [tint release];
        //Nice and dark //tint = [[INSET_TINT_CONFIRM_BUTTON colorByMultiplyingByRed:0.63 green:0.81 blue:0.81 alpha:1.0] retain];
        tint = [[TINT_CONFIRM_BUTTON colorByMultiplyingByRed:0.63 green:0.81 blue:0.81 alpha:1.0] retain];
    }
    else if(style == STYLE_ALTERNATIVE_ACTION_1_BUTTON)
    {
        self.selectedItemColor = [UIColor colorWithWhite:0.75 alpha:1];
        self.unselectedItemColor = [UIColor colorWithWhite:0.95 alpha:1];
 
        [tint release];
        tint = [TINT_ALTERNATIVE_ACTION_1_BUTTON retain];
    }
    else if(style == STYLE_ALTERNATIVE_ACTION_2_BUTTON)
    {
        self.selectedItemColor = [UIColor colorWithWhite:0.75 alpha:1];
        self.unselectedItemColor = [UIColor colorWithWhite:0.95 alpha:1];
        
        [tint release];
        tint = [TINT_ALTERNATIVE_ACTION_2_BUTTON retain];
    }
    
    colorLayer.backgroundColor = tint.CGColor;
    
    [self setNeedsDisplay];
    [self setNeedsLayout];
}
-(void)setDepth:(DEPTH)depth
{
    //Does nothing
}
- (void)drawRect:(CGRect)rect
{
	// Only the bordered and plain style are customized
	if (![self _mustCustomize]) 
    {
		[super drawRect:rect];
		return;
	}
    
	// TODO: support for segment custom width
	CGSize itemSize = CGSizeMake(round(rect.size.width / self.numberOfSegments), rect.size.height);
	CGContextRef c = UIGraphicsGetCurrentContext();
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextSaveGState(c);
    
	// Rect with radius, will be used to clip the entire view
	CGFloat minx = CGRectGetMinX(rect) + 1, midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect) ;
	CGFloat miny = CGRectGetMinY(rect) + 1, midy = CGRectGetMidY(rect) , maxy = CGRectGetMaxY(rect) ;
    
	// Path are drawn starting from the middle of a pixel, in order to avoid an antialiased line
	CGContextMoveToPoint(c, minx - .5, midy - .5);
	CGContextAddArcToPoint(c, minx - .5, miny - .5, midx - .5, miny - .5, INSET_CORNER_RADIUS);
	CGContextAddArcToPoint(c, maxx - .5, miny - .5, maxx - .5, midy - .5, INSET_CORNER_RADIUS);
	CGContextAddArcToPoint(c, maxx - .5, maxy - .5, midx - .5, maxy - .5, INSET_CORNER_RADIUS);
	CGContextAddArcToPoint(c, minx - .5, maxy - .5, minx - .5, midy - .5, INSET_CORNER_RADIUS);
	CGContextClosePath(c);
	CGContextClip(c);
    
    int red = 55, green = 111, blue = 214; // default blue color
    float factor  = 1.22f; // multiplier applied to the first color of the gradient to obtain the second
    float mfactor = 1.25f; // multiplier applied to the color of the first gradient to obtain the bottom gradient
    
    //BEGIN NON-SELECTED GRADIENT
    if (tint != nil) {
        const CGFloat *components = CGColorGetComponents(tint.CGColor);
        size_t numberOfComponents = CGColorGetNumberOfComponents(tint.CGColor);
        
        if (numberOfComponents == 2) {
            red = green = blue = components[0] * 255;
        } else if (numberOfComponents == 4) {
            red   = components[0] * 255;
            green = components[1] * 255;
            blue  = components[2] * 255;
        }
    }
    // Top gradient
    CGFloat top_components[8] = { 
        red / 255.0f,         green / 255.0f,         blue/255.0f          , 0.33f,
        (red*mfactor)/255.0f, (green*mfactor)/255.0f, (blue*mfactor)/255.0f, 0.1f
    };
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, top_components, NULL, 2);
	CGContextDrawLinearGradient(c, gradient, CGPointZero, CGPointMake(0, rect.size.height), kCGGradientDrawsBeforeStartLocation);
	CFRelease(gradient);
    //END - NON SELECTED GRADIENT
    
	for (int i = 0; i < self.numberOfSegments; i++) {
		id item = [self.items objectAtIndex:i];
		BOOL isLeftItem  = i == 0;
		BOOL isRightItem = i == self.numberOfSegments -1;
        
		CGRect itemBgRect = CGRectMake(i * itemSize.width, 
									   0.0f,
									   itemSize.width,
									   rect.size.height);
        
		if (i == self.selectedSegmentIndex) 
        {
			// -- Selected item --
			// Background gradient is composed of two gradients, one on the top, another rounded on the bottom
			CGContextSaveGState(c);
			CGContextClipToRect(c, itemBgRect);
            
        
			if (tint != nil) 
           {
				const CGFloat *components = CGColorGetComponents(tint.CGColor);
				size_t numberOfComponents = CGColorGetNumberOfComponents(tint.CGColor);
                
				if (numberOfComponents == 2) {
					red = green = blue = components[0] * 255;
				} else if (numberOfComponents == 4) {
					red   = components[0] * 255;
					green = components[1] * 255;
					blue  = components[2] * 255;
				}
			}
            
			// Top gradient
			CGFloat top_components[16] = 
           { 
				red / 255.0f,         green / 255.0f,         blue/255.0f          , 0.5f,
				(red*mfactor)/255.0f, (green*mfactor)/255.0f, (blue*mfactor)/255.0f, 0.5f
			};
			CGFloat top_locations[2] = 
           {
				0.0f, .75f
			};
            
			CGGradientRef top_gradient = CGGradientCreateWithColorComponents(colorSpace, top_components, top_locations, 2);
			CGContextDrawLinearGradient(c, 
										top_gradient, 
										itemBgRect.origin, 
										CGPointMake(itemBgRect.origin.x, 
													itemBgRect.size.height), 
										kCGGradientDrawsBeforeStartLocation);
			CFRelease(top_gradient);
			CGContextRestoreGState(c);
           
			// Bottom gradient
			// It's clipped in a rect with the left corners rounded if segment is the first,
			// right corners rounded if segment is the last, no rounded corners for the segments inbetween 
			CGRect bottomGradientRect = CGRectMake(itemBgRect.origin.x, 
												   itemBgRect.origin.y + round(itemBgRect.size.height / 2), 
												   itemBgRect.size.width, 
												   round(itemBgRect.size.height / 2));
            
			CGFloat gradient_minx = CGRectGetMinX(bottomGradientRect) + 1;
			CGFloat gradient_midx = CGRectGetMidX(bottomGradientRect);
			CGFloat gradient_maxx = CGRectGetMaxX(bottomGradientRect);
			CGFloat gradient_miny = CGRectGetMinY(bottomGradientRect) + 1;
			CGFloat gradient_midy = CGRectGetMidY(bottomGradientRect);
			CGFloat gradient_maxy = CGRectGetMaxY(bottomGradientRect);
            
			CGContextSaveGState(c);
			if (isLeftItem) 
           {
				CGContextMoveToPoint(c, gradient_minx - .5f, gradient_midy - .5f);
			} 
           else 
           {
				CGContextMoveToPoint(c, gradient_minx - .5f, gradient_miny - .5f);
			}
            
			CGContextAddArcToPoint(c, gradient_minx - .5f, gradient_miny - .5f, gradient_midx - .5f, gradient_miny - .5f, INSET_CORNER_RADIUS);
            
			if (isRightItem) {
				CGContextAddArcToPoint(c, gradient_maxx - .5f, gradient_miny - .5f, gradient_maxx - .5f, gradient_midy - .5f, INSET_CORNER_RADIUS);
				CGContextAddArcToPoint(c, gradient_maxx - .5f, gradient_maxy - .5f, gradient_midx - .5f, gradient_maxy - .5f, INSET_CORNER_RADIUS);
			} else {
				CGContextAddLineToPoint(c, gradient_maxx, gradient_miny);
				CGContextAddLineToPoint(c, gradient_maxx, gradient_maxy);
			}
            
			if (isLeftItem) {
				CGContextAddArcToPoint(c, gradient_minx - .5f, gradient_maxy - .5f, gradient_minx - .5f, gradient_midy - .5f, INSET_CORNER_RADIUS);
			} else {
				CGContextAddLineToPoint(c, gradient_minx, gradient_maxy);
			}
            
			CGContextClosePath(c);
            
            
			CGContextClip(c);
			CGFloat bottom_components[16] = {
				(red*factor)        /255.0f, (green*factor)        /255.0f, (blue*factor)/255.0f,         0.5f,
				(red*factor*mfactor)/255.0f, (green*factor*mfactor)/255.0f, (blue*factor*mfactor)/255.0f, 0.5f
			};
            
			CGFloat bottom_locations[2] = {
				0.0f, 1.0f
			};
            
			CGGradientRef bottom_gradient = CGGradientCreateWithColorComponents(colorSpace, bottom_components, bottom_locations, 2);
			CGContextDrawLinearGradient(c, 
										bottom_gradient, 
										bottomGradientRect.origin, 
										CGPointMake(bottomGradientRect.origin.x, 
													bottomGradientRect.origin.y + bottomGradientRect.size.height), 
										kCGGradientDrawsBeforeStartLocation);
			CFRelease(bottom_gradient);
			CGContextRestoreGState(c);
            
            
			// Inner shadow
            
			int blendMode = kCGBlendModeDarken;
            
			// Right and left inner shadow 
			CGContextSaveGState(c);
			CGContextSetBlendMode(c, blendMode);
			CGContextClipToRect(c, itemBgRect);
            
			CGFloat inner_shadow_components[16] = {
				0.0f, 0.0f, 0.0f, isLeftItem ? 0.0f : .25f,
				0.0f, 0.0f, 0.0f, 0.0f,
				0.0f, 0.0f, 0.0f, 0.0f,
				0.0f, 0.0f, 0.0f, isRightItem ? 0.0f : .25f
			};
            
            
			CGFloat locations[4] = {
				0.0f, .05f, .95f, 1.0f
			};
			CGGradientRef inner_shadow_gradient = CGGradientCreateWithColorComponents(colorSpace, inner_shadow_components, locations, 4);
			CGContextDrawLinearGradient(c, 
										inner_shadow_gradient, 
										itemBgRect.origin, 
										CGPointMake(itemBgRect.origin.x + itemBgRect.size.width, 
													itemBgRect.origin.y), 
										kCGGradientDrawsAfterEndLocation);
			CFRelease(inner_shadow_gradient);
			CGContextRestoreGState(c);
            
			// Top inner shadow 
			CGContextSaveGState(c);
			CGContextSetBlendMode(c, blendMode);
			CGContextClipToRect(c, itemBgRect);
			CGFloat top_inner_shadow_components[8] = { 
				0.0f, 0.0f, 0.0f, 0.25f,
				0.0f, 0.0f, 0.0f, 0.0f
			};
			CGFloat top_inner_shadow_locations[2] = {
				0.0f, .10f
			};
			CGGradientRef top_inner_shadow_gradient = CGGradientCreateWithColorComponents(colorSpace, top_inner_shadow_components, top_inner_shadow_locations, 2);
			CGContextDrawLinearGradient(c, 
										top_inner_shadow_gradient, 
										itemBgRect.origin, 
										CGPointMake(itemBgRect.origin.x, 
													itemBgRect.size.height), 
										kCGGradientDrawsAfterEndLocation);
			CFRelease(top_inner_shadow_gradient);
			CGContextRestoreGState(c);
            
		}
        
		if ([item isKindOfClass:[UIImage class]]) 
        {
			CGImageRef imageRef = [(UIImage *)item CGImage];
			CGFloat imageScale  = [(UIImage *)item scale];
			CGFloat imageWidth  = CGImageGetWidth(imageRef)  / imageScale;
			CGFloat imageHeight = CGImageGetHeight(imageRef) / imageScale;
            
			CGRect imageRect = CGRectMake(round(i * itemSize.width + (itemSize.width - imageWidth) / 2), 
										  round((itemSize.height - imageHeight) / 2),
										  imageWidth,
										  imageHeight);
            
			if (i == self.selectedSegmentIndex) 
           {
                
				CGContextSaveGState(c);
				CGContextTranslateCTM(c, 0, rect.size.height);
				CGContextScaleCTM(c, 1.0, -1.0);  
                
				CGContextClipToMask(c, imageRect, imageRef);
				CGContextSetFillColorWithColor(c, [self.selectedItemColor CGColor]);
                
				CGContextFillRect(c, imageRect);
				CGContextRestoreGState(c);
			} 
			else 
            {
				// 1px shadow
                CGContextSaveGState(c);
				CGContextTranslateCTM(c, 0, itemBgRect.size.height);  
				CGContextScaleCTM(c, 1.0, -1.0);  
                
				CGContextClipToMask(c, CGRectOffset(imageRect, 0, -1), imageRef);
				CGContextSetFillColorWithColor(c, [[UIColor whiteColor] CGColor]);
				CGContextFillRect(c, CGRectOffset(imageRect, 0, -1));
				CGContextRestoreGState(c);
              
                
				// Image drawn as a mask
				CGContextSaveGState(c);
				CGContextTranslateCTM(c, 0, itemBgRect.size.height);  
				CGContextScaleCTM(c, 1.0, -1.0);  
                
				CGContextClipToMask(c, imageRect, imageRef);
				CGContextSetFillColorWithColor(c, [self.unselectedItemColor CGColor]);
				CGContextFillRect(c, imageRect);
				CGContextRestoreGState(c);
			}
            
		}
		else if ([item isKindOfClass:[NSString class]]) 
        {
            
			NSString *string = (NSString *)[items objectAtIndex:i];
			CGSize stringSize = [string sizeWithFont:self.font];
			CGRect stringRect = CGRectMake(i * itemSize.width + (itemSize.width - stringSize.width) / 2, 
										   (itemSize.height - stringSize.height) / 2,
										   stringSize.width,
										   stringSize.height);
            
			if (self.selectedSegmentIndex == i) 
            {
				[[UIColor colorWithWhite:0.0f alpha:.2f] setFill];
				[string drawInRect:CGRectOffset(stringRect, 0.0f, -1.0f) withFont:self.font];
				[self.selectedItemColor setFill];	
				[self.selectedItemColor setStroke];	
				[string drawInRect:stringRect withFont:self.font];
			} 
           else 
           {
				[[self unselectedItemShadowColor] setFill];			
				[string drawInRect:CGRectOffset(stringRect, 0.0f, 1.0f) withFont:self.font];
				[self.unselectedItemColor setFill];
				[string drawInRect:stringRect withFont:self.font];
                
			}
		}
        
		// Separator
		if (i > 0 && i - 1 != self.selectedSegmentIndex && i != self.selectedSegmentIndex) {
			CGContextSaveGState(c);
            
			CGContextMoveToPoint(c, itemBgRect.origin.x + .5, itemBgRect.origin.y);
			CGContextAddLineToPoint(c, itemBgRect.origin.x + .5, itemBgRect.size.height);
            
			CGContextSetLineWidth(c, .5f);
			CGContextSetStrokeColorWithColor(c, [UIColor colorWithWhite:120/255.0 alpha:1.0].CGColor);
			CGContextStrokePath(c);
            
			CGContextRestoreGState(c);
		}
        
	}
    
	CGContextRestoreGState(c);
	if (self.segmentedControlStyle ==  UISegmentedControlStyleBordered) 
    {
		CGContextMoveToPoint(c, minx - .5, midy - .5);
		CGContextAddArcToPoint(c, minx - .5, miny - .5, midx - .5, miny - .5, INSET_CORNER_RADIUS);
		CGContextAddArcToPoint(c, maxx - .5, miny - .5, maxx - .5, midy - .5, INSET_CORNER_RADIUS);
		CGContextAddArcToPoint(c, maxx - .5, maxy - .5, midx - .5, maxy - .5, INSET_CORNER_RADIUS);
		CGContextAddArcToPoint(c, minx - .5, maxy - .5, minx - .5, midy - .5, INSET_CORNER_RADIUS);
		CGContextClosePath(c);
        
		CGContextSetStrokeColorWithColor(c,[UIColor blackColor].CGColor);
		CGContextSetLineWidth(c, 1.0f);
		CGContextStrokePath(c);
	} 
    else 
    {
		CGContextSaveGState(c);
        
		CGRect bottomHalfRect = CGRectMake(0, 
										   rect.size.height - INSET_CORNER_RADIUS + 7,
										   rect.size.width,
										   INSET_CORNER_RADIUS);
		CGContextClearRect(c, CGRectMake(0, 
										 rect.size.height - 1,
										 rect.size.width,
										 1));
		CGContextClipToRect(c, bottomHalfRect);
        
		CGContextMoveToPoint(c, minx + .5, midy - .5);
		CGContextAddArcToPoint(c, minx + .5, miny - .5, midx - .5, miny - .5, INSET_CORNER_RADIUS);
		CGContextAddArcToPoint(c, maxx - .5, miny - .5, maxx - .5, midy - .5, INSET_CORNER_RADIUS);
		CGContextAddArcToPoint(c, maxx - .5, maxy - .5, midx - .5, maxy - .5, INSET_CORNER_RADIUS);
		CGContextAddArcToPoint(c, minx + .5, maxy - .5, minx - .5, midy - .5, INSET_CORNER_RADIUS);
		CGContextClosePath(c);
        
		CGContextSetBlendMode(c, kCGBlendModeLighten);
		CGContextSetStrokeColorWithColor(c,INSET_BEVEL_LIGHT_COLOUR.CGColor);
		CGContextSetLineWidth(c, 2.0f);
		CGContextStrokePath(c);
        
		CGContextRestoreGState(c);
		midy--, maxy--;
		CGContextMoveToPoint(c, minx - .5, midy - .5);
		CGContextAddArcToPoint(c, minx - .5, miny - .5, midx - .5, miny - .5, INSET_CORNER_RADIUS);
		CGContextAddArcToPoint(c, maxx - .5, miny - .5, maxx - .5, midy - .5, INSET_CORNER_RADIUS);
		CGContextAddArcToPoint(c, maxx - .5, maxy - .5, midx - .5, maxy - .5, INSET_CORNER_RADIUS);
		CGContextAddArcToPoint(c, minx - .5, maxy - .5, minx - .5, midy - .5, INSET_CORNER_RADIUS);
		CGContextClosePath(c);
        
        //Background Colour
		CGContextSetBlendMode(c, kCGBlendModeMultiply);
		CGContextSetStrokeColorWithColor(c,INSET_BEVEL_DARK_COLOUR.CGColor);
		CGContextSetLineWidth(c, 0.5f);
		CGContextStrokePath(c);
	}

	CFRelease(colorSpace);
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (![self _mustCustomize]) {
		[super touchesBegan:touches withEvent:event];
	} else {
		CGPoint point = [[touches anyObject] locationInView:self];
		int itemIndex = floor(self.numberOfSegments * point.x / self.bounds.size.width);
		self.selectedSegmentIndex = itemIndex;
        
		[self setNeedsDisplay];
	}
}
- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex
{
	if (selectedSegmentIndex == self.selectedSegmentIndex) return;
    
	[super setSelectedSegmentIndex:selectedSegmentIndex];
	
#ifdef __IPHONE_5_0
	if ([self respondsToSelector:@selector(apportionsSegmentWidthsByContent)]
		&& [self _mustCustomize]) 
	{
		[self sendActionsForControlEvents:UIControlEventValueChanged];
	}
#endif
}

- (void)setSegmentedControlStyle:(UISegmentedControlStyle)aStyle
{
	[super setSegmentedControlStyle:aStyle];
	if ([self _mustCustomize]) {
		[self setNeedsDisplay];
	}
}

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment
{
	if (![self _mustCustomize]) {
		[super setTitle:title forSegmentAtIndex:segment];
	} else {
		[self.items replaceObjectAtIndex:segment withObject:title];
		[self setNeedsDisplay];
	}
}

- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment
{
	if (![self _mustCustomize]) {
		[super setImage:image forSegmentAtIndex:segment];
	} else {
		[self.items replaceObjectAtIndex:segment withObject:image];
		[self setNeedsDisplay];
	}
}

- (void)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated
{
	if (![self _mustCustomize]) {
		[super insertSegmentWithTitle:title atIndex:segment animated:animated];
	} else {
		if (segment >= self.numberOfSegments && segment != 0) return;
		[super insertSegmentWithTitle:title atIndex:segment animated:animated];
		[self.items insertObject:title atIndex:segment];
		[self setNeedsDisplay];
	}
}

- (void)insertSegmentWithImage:(UIImage *)image atIndex:(NSUInteger)segment animated:(BOOL)animated
{
	if (![self _mustCustomize]) {
		[super insertSegmentWithImage:image atIndex:segment animated:animated];
	} else {
		if (segment >= self.numberOfSegments) return;
		[super insertSegmentWithImage:image atIndex:segment animated:animated];
		[self.items insertObject:image atIndex:segment];
		[self setNeedsDisplay];
	}
}

- (void)removeSegmentAtIndex:(NSUInteger)segment animated:(BOOL)animated
{
	if (![self _mustCustomize]) {
		[super removeSegmentAtIndex:segment animated:animated];
	} else {
		if (segment >= self.numberOfSegments) return;
		[self.items removeObjectAtIndex:segment];
		[self setNeedsDisplay];
	}
}
#pragma mark - Private methods
- (BOOL)_mustCustomize
{
    return YES;
    
	return self.segmentedControlStyle == UISegmentedControlStyleBordered
    || self.segmentedControlStyle == UISegmentedControlStylePlain;
}
- (void)setupLayers
{   
    bevelLayer = setupBevelLayerForView(self);
    colorLayer = setupColorLayerForView(self);
    colorGradientLayer = setupColorGradientLayerForControl(self);	
	
    [bevelLayer retain];
    [colorLayer retain];
    [colorGradientLayer retain];	
    
    //[self.layer addSublayer:bevelLayer];
    [self.layer addSublayer:colorLayer];
    [self.layer addSublayer:colorGradientLayer];

}
@end
