//
//  DBPrefsWindowController.m
//

#import "DBPrefsWindowController.h"

@interface DBPrefsWindowController()
@property (nonatomic, strong) NSMutableArray *toolbarIdentifiers;
@property (nonatomic, strong) NSMutableDictionary *toolbarViews;
@property (nonatomic, strong) NSMutableDictionary *toolbarItems;
@end

@interface NSView (Animations)
- (void)addSubview:(NSView *)aView animated:(BOOL)animated;
- (void)removeFromSuperviewAnimated:(BOOL)animated;
@end

@interface NSWindow (Animations)
- (void)setFrameFromView:(NSView *)view animated:(BOOL)animated;
@end

@interface DBFlippedView : NSView
@end

@implementation DBPrefsWindowController

@synthesize crossFade = _crossFade;
@synthesize toolbarIdentifiers = _toolbarIdentifiers;
@synthesize toolbarItems = _toolbarItems;
@synthesize toolbarViews = _toolbarViews;

#pragma mark -
#pragma mark Class Methods

+ (DBPrefsWindowController *)sharedPrefsWindowController{
    static DBPrefsWindowController *_sharedPrefsWindowController = nil;
	if(!_sharedPrefsWindowController){
		_sharedPrefsWindowController = [[self alloc] initWithWindowNibName:[self nibName]];
	}
	return _sharedPrefsWindowController;
}

// Subclasses can override this to use a nib with a different name.
+ (NSString *)nibName{
    return @"Preferences";
}


#pragma mark -
#pragma mark Setup & Teardown

- (id)initWithWindow:(NSWindow *)window {
	if((self = [super initWithWindow:nil])){
        // Set up an array and some dictionaries to keep track
        // of the views we'll be displaying.
        self.toolbarIdentifiers = [[NSMutableArray alloc] init];
        self.toolbarViews = [[NSMutableDictionary alloc] init];
        self.toolbarItems = [[NSMutableDictionary alloc] init];
        
        self.crossFade = YES;
	}
	return self;
}

- (void)windowDidLoad {
    // Create a new window to display the preference views.
    // If the developer attached a window to this controller
    // in Interface Builder, it gets replaced with this one.
    NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 100, 100)
                                                   styleMask:(NSTitledWindowMask |
                                                              NSClosableWindowMask |
                                                              NSMiniaturizableWindowMask)
                                                     backing:NSBackingStoreBuffered
                                                       defer:YES];
    [self setWindow:window];
    [[self window] setShowsToolbarButton:NO];
    
    DBFlippedView *view = [[DBFlippedView alloc] initWithFrame:[[[self window] contentView] frame]];
    [[self window] setContentView:view];
}


#pragma mark -
#pragma mark Configuration

- (void)setupToolbar{
    // Subclasses must override this method to add items to the
    // toolbar by calling -addView:label: or -addView:label:image:.
}

- (void)addToolbarItemForIdentifier:(NSString *)identifier
                              label:(NSString *)label
                              image:(NSImage *)image
                           selector:(SEL)selector {
    [self.toolbarIdentifiers addObject:identifier];
    
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
    [item setLabel:label];
    [item setImage:image];
    [item setTarget:self];
    [item setAction:selector];
    
    [self.toolbarItems setObject:item forKey:identifier];
}

- (void)addFlexibleSpacer {
    [self addToolbarItemForIdentifier:NSToolbarFlexibleSpaceItemIdentifier label:nil image:nil selector:nil];
}

- (void)addView:(NSView *)view label:(NSString *)label{
    [self addView:view label:label image:[NSImage imageNamed:label]];
}

- (void)addView:(NSView *)view label:(NSString *)label image:(NSImage *)image{
    if(view == nil){
        return;
    }
	
    NSString *identifier = [label copy];
    [self.toolbarViews setObject:view forKey:identifier];
    [self addToolbarItemForIdentifier:identifier
                                label:label
                                image:image
                             selector:@selector(toggleActivePreferenceView:)];
}


#pragma mark -
#pragma mark Overriding Methods

- (IBAction)showWindow:(id)sender {
    // This forces the resources in the nib to load.
    [self window];
    
    // Clear the last setup and get a fresh one.
    [self.toolbarIdentifiers removeAllObjects];
    [self.toolbarViews removeAllObjects];
    [self.toolbarItems removeAllObjects];
    [self setupToolbar];
    
    if(![_toolbarIdentifiers count]){
        return;
    }
    
    if([[self window] toolbar] == nil){
        NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"DBPreferencesToolbar"];
        [toolbar setAllowsUserCustomization:NO];
        [toolbar setAutosavesConfiguration:NO];
        [toolbar setSizeMode:NSToolbarSizeModeDefault];
        [toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
        [toolbar setDelegate:(id<NSToolbarDelegate>)self];
        [[self window] setToolbar:toolbar];
    }
        
    NSString *firstIdentifier = [self.toolbarIdentifiers objectAtIndex:0];
    [[[self window] toolbar] setSelectedItemIdentifier:firstIdentifier];
    [self displayViewForIdentifier:firstIdentifier animate:NO];
    
    [super showWindow:sender];
}


#pragma mark -
#pragma mark Toolbar

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar{
	return self.toolbarIdentifiers;
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar {
	return self.toolbarIdentifiers;
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar {
	return self.toolbarIdentifiers;
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)identifier willBeInsertedIntoToolbar:(BOOL)willBeInserted {
	return [self.toolbarItems objectForKey:identifier];
}

- (void)toggleActivePreferenceView:(NSToolbarItem *)toolbarItem {
	[self displayViewForIdentifier:[toolbarItem itemIdentifier] animate:self.crossFade];
}

- (void)displayViewForIdentifier:(NSString *)identifier animate:(BOOL)animate {
    [[[self window] toolbar] setSelectedItemIdentifier:identifier];
    NSView *newView = [self.toolbarViews objectForKey:identifier];
    NSArray *subviews = [[[self window] contentView] subviews];
    
    if ([subviews containsObject:newView])
        return;
    
    for (NSView *view in subviews) {
        [view removeFromSuperviewAnimated:animate];
    }
    
    [[[self window] contentView] addSubview:newView animated:animate];
    [[self window] setFrameFromView:newView animated:animate];
    
    if (!animate && (subviews.count == 0))
        [[self window] center];
}

// Close the window with cmd+w in case the app doesn't have an app menu
- (void)keyDown:(NSEvent *)theEvent{
    NSString *key = [theEvent charactersIgnoringModifiers];
    if(([theEvent modifierFlags] & NSCommandKeyMask) && [key isEqualToString:@"w"]){
        [self close];
    } else {
        [super keyDown:theEvent];
    }
}

@end

@implementation NSView (Animations)

- (void)addSubview:(NSView *)aView animated:(BOOL)animated {
    [aView setAlphaValue:0.f];
    [aView setFrameOrigin:NSZeroPoint];
    
    CGFloat duration = animated ? (([[[self window] currentEvent] modifierFlags] & NSShiftKeyMask) ? 1.f : 0.25f ) : 0.f;
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:duration];
    
    [self addSubview:aView];
    [[aView animator] setAlphaValue:1.f];
    
    [NSAnimationContext endGrouping];
}

- (void)removeFromSuperviewAnimated:(BOOL)animated {
    CGFloat duration = animated ? (([[[self window] currentEvent] modifierFlags] & NSShiftKeyMask) ? 1.f : 0.25f ) : 0.f;
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:duration];
    
    [[self animator] setAlphaValue:0.f];
    
    [NSAnimationContext endGrouping];
    
    // if we were Lion-only, using built-in completion handler would be a better idea
    [self performSelector:@selector(removeFromSuperview)
               withObject:nil
               afterDelay:duration];
}

@end

@implementation NSWindow (Animations)

- (NSRect)frameForView:(NSView *)view {
	NSRect windowFrame = [self frame];
	NSRect contentRect = [self contentRectForFrameRect:windowFrame];
	CGFloat windowTitleAndToolbarHeight = NSHeight(windowFrame) - NSHeight(contentRect);
    
	windowFrame.size.height = NSHeight([view frame]) + windowTitleAndToolbarHeight;
	windowFrame.size.width = NSWidth([view frame]);
	windowFrame.origin.y = NSMaxY([self frame]) - NSHeight(windowFrame);
	
	return windowFrame;
}

- (void)setFrameFromView:(NSView *)view animated:(BOOL)animated {
    CGFloat duration = animated ? (([[self currentEvent] modifierFlags] & NSShiftKeyMask) ? 1.f : 0.25f ) : 0.f;
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:duration];
    
    NSRect frame = [self frameForView:view];
    [[self animator] setFrame:frame display:YES];
    
    [NSAnimationContext endGrouping];
}

@end

@implementation DBFlippedView

- (BOOL)isFlipped {
    return YES;
}

@end
