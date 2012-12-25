//
//  Copyright (c) 2011 Aaron Brethorst
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

#import "SPStackPanel.h"

@interface SPStackPanel ()
{
	UITableView *tableView;
	NSMutableArray *cells;
}
- (void)configureView;
@end

@implementation SPStackPanel

#pragma mark
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
	if (self)
	{
		[self configureView];
	}	
	return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
	if (self)
	{
		[self configureView];
	}	
	return self;
}
- (void)dealloc
{
	self.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_STACKPANEL_CONTENT_RESIZED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_STACKPANEL_CONTENT_WILL_RESIZE object:nil];
}

#pragma mark -
#pragma mark Private

- (void)configureView
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(panelWasResized:) name:NOTIFICATION_STACKPANEL_CONTENT_RESIZED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(panelWillBeResized:) name:NOTIFICATION_STACKPANEL_CONTENT_WILL_RESIZE object:nil];
    
	self.delegate = nil;
	cells = [[NSMutableArray alloc] init];
	
	tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
	tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	tableView.dataSource = self;
	tableView.delegate = self;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.showsVerticalScrollIndicator = NO;
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self addSubview:tableView];
}
#pragma mark Public Methods
- (void)setBackgroundColor:(UIColor *)backgroundColor
{
	[super setBackgroundColor:backgroundColor];
	tableView.backgroundColor = backgroundColor;
}
- (void)addStackedView:(UIView *)v
{
	[self addStackedView:v reload:YES];
}
- (void)addStackedView:(UIView *)v reload:(BOOL)yn
{
	assert(nil != v);

	UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	CGRect cellFrame = cell.frame;
	cellFrame.size = v.frame.size;
	cell.frame = cellFrame;
	v.tag = [cells count];
    [cell.contentView addSubview:v];
	
	[cells addObject:cell];

	if (yn)
	{
		[tableView reloadData];
	}
}

- (void)addStackedViews:(NSArray*)a
{
	for (UIView *v in a)
	{
		[self addStackedView:v reload:NO];
	}

	[tableView reloadData];
}

- (void)removeStackedViewAtIndex:(NSInteger)index
{
	[self removeStackedViewAtIndex:index animation:UITableViewRowAnimationNone];
}

- (void)removeStackedViewAtIndex:(NSInteger)index animation:(UITableViewRowAnimation)rowAnimation
{
	if ([cells count] > index)
	{
		[cells removeObjectAtIndex:index];
	}
    
	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]]
					 withRowAnimation:rowAnimation];
}

- (void)removeStackedView:(UIView*)aView
{
	[self removeStackedView:aView animation:UITableViewRowAnimationNone];
}

- (void)removeStackedView:(UIView*)aView animation:(UITableViewRowAnimation)rowAnimation
{
	for (int i=0; i<[cells count]; i++)
	{
		UITableViewCell *cell = [cells objectAtIndex:i];
		if (aView == [cell.contentView.subviews objectAtIndex:0])
		{
			[self removeStackedViewAtIndex:i animation:rowAnimation];
		}
	}
}
- (void)scrollToOffset:(CGPoint)offset
{
    [tableView setContentOffset:offset animated:YES];
}
- (void)reloadStack
{
	[tableView reloadData];
}
#pragma mark - Private methods
-(void)panelWillBeResized:(NSNotification*)notification
{
    NSDictionary* userInfo = (NSDictionary*)[notification object];
    
    UIView* view = [userInfo objectForKey:@"view"];
    if([view isDescendantOfView:self])
    {
        int index = [[userInfo objectForKey:@"index"] intValue];
        double height = [[userInfo objectForKey:@"height"] doubleValue];
    
        UITableViewCell* cell = [cells objectAtIndex:index];

        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        cell.height = height;
    
        [tableView beginUpdates];
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [tableView endUpdates];
    
        //The cell's height has to be set a 2nd time for it's subview's to be clickable
        cell.height = height;
    }
}
-(void)panelWasResized:(NSNotification*)notification
{
    NSDictionary* userInfo = (NSDictionary*)[notification object];
    
    UIView* view = [userInfo objectForKey:@"view"];
    if([view isDescendantOfView:self])
    {
        NSDictionary* userInfo = (NSDictionary*)[notification object];
        int index = [[userInfo objectForKey:@"index"] intValue];
        //Scroll the StackPanel to the top of this panel
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}
#pragma mark UITableViewDataSource/UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
	return [cells count];
}
- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIView *v = [cells objectAtIndex:indexPath.row];
    int height =  v.frame.size.height;
	return height;
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [cells objectAtIndex:indexPath.row];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	SEL selector = @selector(stackPanel:didSelectView:);
	if (self.delegate && [self.delegate respondsToSelector:selector])
	{
		UITableViewCell *tappedCell = [cells objectAtIndex:indexPath.row];
		UIView *tappedView = [tappedCell.contentView.subviews objectAtIndex:0];
		[self.delegate performSelector:selector withObject:self withObject:tappedView];
	}
}
#pragma mark - StackPanelContentDelegate methods
- (void)stackPanelContent:(UIView*)content willResizeToHeight:(CGFloat)height
{
    
}
- (void)stackPanelContent:(UIView*)content didResizeToHeight:(CGFloat)height
{

}
@end
