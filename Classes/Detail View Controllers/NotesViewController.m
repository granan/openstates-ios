//
//  NotesViewController.m
//  TexLege
//
//  Created by Gregory Combs on 7/22/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "NotesViewController.h"
#import "LegislatorObj+RestKit.h"
#import "UtilityMethods.h"
#import "TexLegeTheme.h"
#import "LocalyticsSession.h"
#import "TexLegeCoreDataUtils.h"
#import "TexLegeAppDelegate.h"

@implementation NotesViewController

@synthesize notesText, nameLabel, dataObjectID;
@synthesize backViewController, navBar, navTitle;

- (void)viewDidLoad {	
	[super viewDidLoad];
	if ([UtilityMethods isIPadDevice]) {
		self.navBar.tintColor = [TexLegeTheme accent];
		self.navTitle.rightBarButtonItem = self.editButtonItem;
		self.contentSizeForViewInPopover = CGSizeMake(320.f, 320.f);
	}
	else {
		self.navigationItem.title = @"Notes";
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
	}
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)dealloc {
	self.dataObjectID = nil;
	self.notesText = nil;
	self.nameLabel = nil;
	self.navTitle = nil;
	self.navBar = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
	
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
									 // Release anything that's not essential, such as cached data
}

- (void)viewWillAppear:(BOOL)animated {   
	[super viewWillAppear:animated];
	
	NSString *notesString = nil;
	
	[[NSUserDefaults standardUserDefaults] synchronize];	
	NSDictionary *storedNotesDict = [[NSUserDefaults standardUserDefaults] valueForKey:@"LEGE_NOTES"];
	if (storedNotesDict) {
		NSString *temp = [storedNotesDict valueForKey:[self.legislator.legislatorID stringValue]];
		if (temp && [temp length])
			notesString = temp;
	}
	if (!notesString)
		notesString = self.legislator.notes;
	
    // Update the views appropriately
    self.nameLabel.text = [self.legislator shortNameForButtons];    
	if (!notesString || [notesString length] == 0) {
		self.notesText.text = kStaticNotes;
	}
	else
		self.notesText.text = notesString;    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Support all orientations except upside-down
    return YES;
}

#pragma mark -
#pragma mark Data Objects

- (LegislatorObj *)legislator {
	LegislatorObj *anObject = nil;
	if (self.dataObjectID) {
		anObject = [LegislatorObj objectWithPrimaryKeyValue:self.dataObjectID];
	}
	return anObject;
}

- (void)setLegislator:(LegislatorObj *)anObject {	
	self.dataObjectID = nil;
	if (anObject) {
		self.dataObjectID = [anObject legislatorID];
	}
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {

    [super setEditing:editing animated:animated];

    self.notesText.editable = editing;
	[self.navigationItem setHidesBackButton:editing animated:YES];

	[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"EDITING_NOTES"];
	
	/*
	 If editing is finished, update the recipe's instructions and save the managed object context.
	 */
	if (!editing) {
		if (![self.notesText.text isEqualToString:kStaticNotes]) {
			[[NSUserDefaults standardUserDefaults] synchronize];
			NSDictionary *storedNotesDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"LEGE_NOTES"];
			NSMutableDictionary *newDictionary = nil;
			
			if (!storedNotesDict) {
				newDictionary = [NSMutableDictionary dictionary];
			}
			else {
				newDictionary = [NSMutableDictionary dictionaryWithDictionary:storedNotesDict];
			}
			
			[newDictionary setObject:self.notesText.text forKey:[self.legislator.legislatorID stringValue]];
			[[NSUserDefaults standardUserDefaults] setObject:newDictionary forKey:@"LEGE_NOTES"];
			[[NSUserDefaults standardUserDefaults] synchronize];

			self.legislator.notes = self.notesText.text;
		}
		
		NSManagedObjectContext *context = self.legislator.managedObjectContext;
		NSError *error = nil;
		if (![context save:&error]) {
			// Handle error
			debug_NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		}
		if ([self.backViewController respondsToSelector:@selector(resetTableData:)])
			[self.backViewController performSelector:@selector(resetTableData:) withObject:self];

	}		
}

@end
