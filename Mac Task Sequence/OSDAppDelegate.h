//
//  OSDAppDelegate.h
//  Mac Task Sequence
//
//  Created by Joseph Rafferty on 5/17/12.
//  Copyright (c) 2012 Texas A&M University. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Department.h"
#import "Building.h"
#import "Room.h"

@interface OSDAppDelegate : NSObject <NSApplicationDelegate>
{
    NSString *prefix, *mirrorString, *computerName;
    
    int counter;
    
    NSMutableArray *departments;
    NSMutableArray *roles;
    
    Department *selectedDepartment, *emptyDept;
    Building *selectedBuilding, *emptyBuild;
    Room *selectedRoom, *emptyRoom;
    
    NSMutableArray *selectedRoles;
    
    IBOutlet NSArrayController *departmentsController;
    IBOutlet NSArrayController *buildingsController;
    IBOutlet NSArrayController *roomsController;
    IBOutlet NSArrayController *rolesController;
    
    IBOutlet NSButton *mirrorButton;
    
    IBOutlet NSTextField *computerNumber, *countdownText, *computerNameText;
    
    IBOutlet NSTableView *rolesTable;
}

- (BOOL)mountOSDShare;

- (IBAction)canMirror:(id)sender;
- (IBAction)popupDidChange:(id)sender;

- (BOOL)checkMirrorRequirements;

- (IBAction)mirror:(id)sender;

- (NSString *)getmacAddress;

- (NSString *)paddedComputerNumber;

- (IBAction)startCountdown:(id)sender;

- (NSString *)counterToTime;
- (NSString *)computerName;
void CopySerialNumber(CFStringRef *serialNumber);


@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) Department *selectedDepartment;
@property (nonatomic, retain) Building *selectedBuilding;
@property (nonatomic, retain) Room *selectedRoom;
@property (nonatomic, retain) NSMutableArray *departments, *roles, *selectedRoles;
@property (assign) int counter;
@end
