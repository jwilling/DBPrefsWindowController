//
//  DBPrefsWindowController.h
//
//  Created by Dave Batton
//  http://www.Mere-Mortal-Software.com/blog/
//
//  Updated by David Keegan and Jonathan Willing
//  https://github.com/kgn/DBPrefsWindowController
//
//  Copyright 2007. Some rights reserved.
//  This work is licensed under a Creative Commons license:
//  http://creativecommons.org/licenses/by/3.0/

#import <Cocoa/Cocoa.h>

@interface DBPrefsWindowController : NSWindowController

/* Enable or disable the cross-fade effect when switching views. 
 * The default value is YES.*/
@property BOOL crossFade;

/* Returns a shared instance of the DBPrefsWindowController class. */
+ (DBPrefsWindowController *)sharedPrefsWindowController;

/* Call this method to display the preferences window. For example: 
 * [[AppPrefsWindowController sharedPrefsWindowController] showWindow:nil]; */
- (void)showWindow:(id)sender;

/* Override this method if you want to use a nib file named something 
 * other than Preferences. */
+ (NSString *)nibName;

/* Override this method with calls to -addView:label: or -addView:label:image: 
 * to populate the toolbar. */
- (void)setupToolbar;


/* Adds a blank, flexible-width space between toolbar items. */
- (void)addFlexibleSpacer;

/* Call this method as many times as needed from -setupToolbar to 
 * add new toolbar icons and custom views to the preferences window. 
 * An image with a name that matches the label should be available in 
 * the application bundle. It will be used as the toolbar icon. */
- (void)addView:(NSView *)view label:(NSString *)label;

/* This method can be used instead of -addView:label: if the application 
 * is localized, or if you just want to use icons with names that 
 * differ from the toolbar button labels. */
- (void)addView:(NSView *)view label:(NSString *)label image:(NSImage *)image;

/* Displays the preference view and highlights the toolbar item 
 * for the passed in identifier. */
- (void)displayViewForIdentifier:(NSString *)identifier animate:(BOOL)animate;

@end
