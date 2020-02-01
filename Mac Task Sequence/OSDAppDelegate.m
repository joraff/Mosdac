//
//  OSDAppDelegate.m
//  Mac Task Sequence
//
//  Created by Joseph Rafferty on 5/17/12.
//  Copyright (c) 2012 Texas A&M University. All rights reserved.
//

#import "OSDAppDelegate.h"
#import "Department.h"
#import "Building.h"
#import "Room.h"
#import "DeployStudioHelper.h"
#import "Constants.h"
#include "GetMacAddress.h"


/**
 Main application delegate.
 */


@implementation OSDAppDelegate

@synthesize window = _window;
@synthesize selectedDepartment, selectedBuilding, selectedRoom, selectedRoles;
@synthesize departments, roles;
@synthesize counter;

/**
 Initializes the application
 */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Get the prefix of where we should look for and save our text files
    // NSUserDefaults has a dictionary of arguments passed on the command line.
    NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
    prefix = [args stringForKey:@"prefix"];
    
    if (!prefix) {
        // No prefix, setup a default
        prefix = @"/Volumes/osd$";
    }

    // Mount the OSD share for our text files    
    if ([self mountOSDShare]) {
        
        // To hide the deploystudio runtime window. Otherwise, our form window would appear behind it.
        [NSApp hideOtherApplications:self];
        
                
        // Setup file references for our text files
        NSString *fileContents;
        NSArray *fileLines;
        
        
        /**************************/
        
        
        // Department.txt has lines with elements separated by the pipe character
        fileContents = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Department.txt", prefix] encoding:NSUTF8StringEncoding error:nil];
        fileLines = [fileContents componentsSeparatedByString:@"\r\n"];
        
        departments = [NSMutableArray new];
        
        // To aid in recalling the exact department object we need later, we'll put them in a dictionary instead of an array
        NSMutableDictionary *tempDepartments = [NSMutableDictionary new];
        
        for(NSString *line in fileLines) {
            
            // Split the line by the pipe character, into an array
            NSArray *tempElements = [line componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"|"]];
            
            // Init a new Department object using that line element array
            Department *tempDepartment = [[Department alloc] initWithArray:tempElements];
            
            // Add the department object to our departments dictionary
            [tempDepartments setObject:tempDepartment forKey:[tempDepartment value]];
        }
        
        /**************************/
        
        // Building.txt has lines with elements separated by the pipe character
        fileContents = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Building.txt", prefix] encoding:NSUTF8StringEncoding error:nil];
        fileLines = [fileContents componentsSeparatedByString:@"\r\n"];

        for(NSString *line in fileLines) {
            
            // Split the line by the | character into an array
            NSArray *tempElements = [line componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"|"]];
            
            // init a new Building object. It knows how to parse the line elements
            Building *tempBuilding = [[Building alloc] initWithArray:tempElements];
            
            // Add building to the department(s) it belongs to. The 4th column on the line is a list of departments in the building separated by a semi-colon.
            for (NSString *key in [[tempElements objectAtIndex:3] componentsSeparatedByString:@";"]) {
                
                // Recall the department we want by its value (key)
                Department *d = [tempDepartments objectForKey:key];
                
                // Directly access the buildings dictionary to add the new building object.
                // TODO: don't synthesize buildings, and instead create a [Department addBuilding:] method
                [[d buildings] setObject:tempBuilding forKey:[tempBuilding value]];
            }
            
        }
        
        /**************************/
        
        // Room.txt has lines with elements separated by the pipe character
        fileContents = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Room.txt", prefix] encoding:NSUTF8StringEncoding error:nil];
        fileLines = [fileContents componentsSeparatedByString:@"\r\n"];
        
        // Loop over the lines
        for(NSString *line in fileLines) {
            
            // Split the line by the | character into an array
            NSArray *tempElements = [line componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"|"]];
            
            // Init a new Room object. It knows how to parse the line elements
            Room *tempRoom = [[Room alloc] initWithArray:tempElements];
            
            // These next two loops will add the Room object to the rooms dictionary of a building object that's in a department's building dictionary. We'll end up with something like a big de-dup'd tree structure with departments at the top and 
            
            // The 4th column has a list of departments using room separated by ";". Loop over them
            for (NSString *deptKey in [[tempElements objectAtIndex:3] componentsSeparatedByString:@";"])
            {
                // Recall the department object
                Department *d = [tempDepartments objectForKey:deptKey];
                
                // The 1st column has a list of buildings the room is in (should be only one, right?) separated by ";". Loop over them
                for (NSString *buildKey in [[tempElements objectAtIndex:0] componentsSeparatedByString:@";"])
                {
                    // Get the building object
                    Building *b = [[d buildings] objectForKey:buildKey];
                    
                    // Add the room to the building
                    [[b rooms] setObject:tempRoom forKey:[tempRoom number]];
                }
            }
        }
        
        // Now that we've added all the buildings and rooms to the departments, turn the temporary dictionary into an Array that our NSArrayController and NSPopUp can use
        for (NSString *key in tempDepartments)
        {
            Department *d = [tempDepartments objectForKey:key];
            [departments addObject:d];
        }
        
        // Now populate the department array controller with the departments
        [departmentsController setContent:departments];
        
        
        /**************************/

        
        // Define our roles
        // TODO: move this to a constant? & define in Constants.h/m
        roles = [NSArray arrayWithObjects:
                 [NSDictionary dictionaryWithObjectsAndKeys:@"Generic Lab Machine", @"name", @" ", @"value", nil],
                 [NSDictionary dictionaryWithObjectsAndKeys:@"ADA Compliant Workstation", @"name", @"A", @"value", nil],
                 [NSDictionary dictionaryWithObjectsAndKeys:@"Classroom Workstation", @"name", @"C", @"value", nil],
                 [NSDictionary dictionaryWithObjectsAndKeys:@"Extended (2+) Monitors", @"name", @"E", @"value", nil],
                 [NSDictionary dictionaryWithObjectsAndKeys:@"Graphics Workstation", @"name", @"G", @"value", nil],
                 [NSDictionary dictionaryWithObjectsAndKeys:@"Instructor Workstation", @"name", @"I", @"value", nil],
                 [NSDictionary dictionaryWithObjectsAndKeys:@"Staff Workstation", @"name", @"S", @"value", nil],
                 [NSDictionary dictionaryWithObjectsAndKeys:@"Test Workstation", @"name", @"T", @"value", nil],
                 [NSDictionary dictionaryWithObjectsAndKeys:@"Virtual Workstation", @"name", @"V", @"value", nil],
                 nil];
        
        // Populate the content in our roles ArrayController
        [rolesController setContent:roles];
        
        // By default, the first item was being auto selected. Stop that crap de forcing a deselectAll on the NSTableView
        [rolesTable deselectAll:nil];
        
        // "Listen" for changes to which roles are selected by adding an observer to the NSTableView.
        // Basically, we want to check if the change will allow them to mirror or not.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(canMirror:) name:NSTableViewSelectionDidChangeNotification object:rolesTable];
        
        
        /**************************/

        
        // To prevent the first item in each Popup to be selected by default, init some empty objects and set them as the selected objects (will update the arraycontrollers and nspopups through bindings)
        emptyDept = [[Department alloc] init];
        emptyBuild = [[Building alloc] init];
        emptyRoom = [[Room alloc] init];
        
        self.selectedDepartment = emptyDept;
        self.selectedBuilding = emptyBuild;
        self.selectedRoom = emptyRoom;
        
        
        // Set the sort order for the building and room popups - will be alphabetically based on their description. We could do this for departments too, but that list is short.
        [buildingsController setSortDescriptors:[NSArray arrayWithObject:
                                                 [NSSortDescriptor sortDescriptorWithKey:@"description"
                                                                               ascending:YES]]];
        [roomsController setSortDescriptors:[NSArray arrayWithObject:
                                             [NSSortDescriptor sortDescriptorWithKey:@"description"
                                                                           ascending:YES]]];
        
        
        /**************************/

        
        // SCCM task sequence wizard's SMB share may already have a text file with some default values for us.
        // Files are named as "mac address dot txt"
        NSString *macAddress = [self getmacAddress];
        NSString *mirrorFilePath = [NSString stringWithFormat:@"%@/Default/%@.txt", prefix, macAddress];
        
        // No need to check for the existance of the file: values will be nil if the file didn't exist
        mirrorString = [NSString stringWithContentsOfFile:mirrorFilePath encoding:NSUTF8StringEncoding error:nil];
        
        // Parse the values in the default file.
        NSArray *defaults = [mirrorString componentsSeparatedByString:@"|"];
        
        // TODO: add try/catch NSRangeException here
        NSString *defaultBuilding = [defaults objectAtIndex:0];
        NSString *defaultRoom = [defaults objectAtIndex:1];
        NSString *defaultCompNumber = [defaults objectAtIndex:2];
        NSString *defaultRoles = [defaults objectAtIndex:3];
        NSString *defaultDepartment = [defaults objectAtIndex:4];
        
        // 
        for (id department in departments) {
            if ([defaultDepartment isEqualToString:[department value]]) {
                self.selectedDepartment = department;
                
                [buildingsController setContent:[department buildingsArray]];
                
                for (id building in [department buildingsArray]) {
                    if ([defaultBuilding isEqualToString:[building value]]) {
                        self.selectedBuilding = building;
                        
                        [roomsController setContent:[building roomsArray]];
                        for (id room in [building roomsArray]) {
                            if ([defaultRoom isEqualToString:[room number]]) {
                                self.selectedRoom = room;
                                break;
                            }
                        }
                        break;
                    }
                }
                break;
            }
        }
        
        [computerNumber setStringValue:defaultCompNumber];
        
        NSMutableArray *defaultRolesArray = [NSMutableArray new];
        for (int i = 0; i < [defaultRoles length]; i++)
        {
            NSString *c = [defaultRoles substringWithRange:NSMakeRange(i, 1)];
            [defaultRolesArray addObject:c];
        }
        
        NSMutableArray *defaultSelectedRoles = [NSMutableArray new];
        
        for (id role in roles) {
            if ([defaultRolesArray containsObject:[role valueForKey:@"value"]]) {
                [defaultSelectedRoles addObject:role];
            }
        }
        
        [rolesController setSelectedObjects:[NSArray arrayWithArray:defaultSelectedRoles]];
        
        [self canMirror:nil];
        
        if ([self checkMirrorRequirements]) {
            [self startCountdown:nil];
        }
    } else {
        NSString *errMsg = @"Error: OSD sharepoint could not mount or was not found.";
        NSAlert *alert = [NSAlert alertWithMessageText:errMsg defaultButton:@"Exit" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
        NSLog(@"%@", errMsg);
        
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert runModal];
        
        exit(3);
    }
    
}

/**
 Enables and disables the Mirror button based on the return of [self checkMirrorRequirements].
 Also updates the computer name display
 Rooms popup is bound here
 */
- (IBAction)canMirror:(id)sender
{
    
    if ([self checkMirrorRequirements]) {
        [mirrorButton setEnabled:YES];
        [computerNameText setStringValue:[NSString stringWithFormat:@"Configured name: %@", [self computerName]]];
    } else {
        [mirrorButton setEnabled:NO];
        [computerNameText setStringValue:@""];
    }
}

- (BOOL) checkMirrorRequirements
{
    BOOL canMirror = YES;
    if ([[selectedDepartment name] length] == 0) canMirror = NO;
    if ([[selectedBuilding name] length] == 0) canMirror = NO;
    if ([[selectedRoom number] length] == 0) canMirror = NO;
    if ([[computerNumber stringValue] length] == 0) canMirror =  NO;
    if ([[rolesController selectedObjects] count] == 0) canMirror = NO;

    return canMirror;
}

/**
 Bindings method called when any of the popups (except the room popup) is changed.
 Checks if we should enable the mirror button
 */
// TODO: can we also bind the rooms popup directly here if we check who the sender is?
- (IBAction)popupDidChange:(id)sender {
    // We should definitely reset the Room popup
    self.selectedRoom = emptyRoom;
    
    // And if we're the Department popup, we should also reset the building.
    if ([sender indexOfItemWithTitle:[[departments objectAtIndex:0] name]] >= 0) {
        self.selectedBuilding = emptyBuild;
    }
    
    // Check mirror requirements
    [self canMirror:self];
}


/**
 Notification method called when the computer number is changed.
 Checks if we should enable the mirror button
 */
- (void) controlTextDidChange: (NSNotification *) notification
{
    if ([notification object] == computerNumber) {
        [self canMirror:[notification object]];
    }
}


/**
 Updates Deploystudio and the SCCM smb share with the newly chosen (or time-out chosen) computer name and mirror string
 */
- (IBAction)mirror:(id)sender
{
    // The SCCM Task Sequence Wizard is expecting a specially formatted string representing the chosen values
    
    // First, append all the chosen role abbreviations together.
    NSString *roleString = @"";
    for (NSDictionary *role in [rolesController selectedObjects]) {
        roleString = [roleString stringByAppendingString:[role objectForKey:@"value"]];
    }
    
    // Construct the SCCM mirror string in the format it expects
    mirrorString = [NSString stringWithFormat:@"%@|%@|%@|%@|%@", [selectedBuilding value], [selectedRoom number], [self paddedComputerNumber], roleString, [selectedDepartment value]];
    
    // SCCM Task Sequence Wizard will look for the string in a text file named by the mac address on its SMB share
    NSString *macAddress = [self getmacAddress];
    NSString *mirrorFilePath = [NSString stringWithFormat:@"%@/Default/%@.txt", prefix, macAddress];
    
    // Write the mirror string to the mac address text file
    [mirrorString writeToFile:mirrorFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    // Deploystudio, however, uses the serial number as the identifier.
    CFStringRef cfserialNumber;
    CopySerialNumber(&cfserialNumber);
    
    // Convert the core foundation string to an NSString
    NSString *serialNumber = (__bridge NSString *)cfserialNumber;
    CFRelease(cfserialNumber);
    
    // Fetch a dictionary of key/values from Deploystudio for this computer
    NSMutableDictionary *compData = [DeployStudioHelper getDictionaryWithIdentifier:serialNumber];
    
    // Deploystudio expects cn and dstudio-hostname to be updated for a computer name change
    [compData setObject:[self computerName] forKey:@"cn"];
    [compData setObject:[self computerName] forKey:@"dstudio-hostname"];
    
    // Also, for funsies, put the role string in an ARD field. Maybe we'll find a use for this someday.
    [compData setObject:roleString forKey:@"dstudio-host-ard-field-2"];
    
    // Update our records in deploystudio
    [DeployStudioHelper updateIdentifier:serialNumber withDictionary:compData];
    
    // Show all apps again
    [NSApp unhideAllApplications:self];
    
    // And be gone!
    [NSApp terminate:self];

}

/**
 @returns a string representing the primary network adapter's MAC address without any separaters
 */
- (NSString *)getmacAddress
{
    // Get MAC address
    kern_return_t	kernResult = KERN_SUCCESS;
    io_iterator_t	intfIterator;
    UInt8			MACAddress[kIOEthernetAddressSize];
    
    kernResult = FindEthernetInterfaces(&intfIterator);
    
    if (KERN_SUCCESS != kernResult) {
        //printf("FindEthernetInterfaces returned 0x%08x\n", kernResult);
    }
    else {
        kernResult = GetMACAddress(intfIterator, MACAddress, sizeof(MACAddress));
    }
    
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", MACAddress[0], MACAddress[1], MACAddress[2], MACAddress[3], MACAddress[4], MACAddress[5]];
}


/**
 @returns a formatted string of a number left-padded with zeros to 3 digits.
 */
- (NSString *)paddedComputerNumber
{
    NSString *paddedCompNumber = [computerNumber stringValue];
    for (NSUInteger i = [paddedCompNumber length]; i < 3; i++) {
        paddedCompNumber = [NSString stringWithFormat:@"0%@", paddedCompNumber];
    }
    return paddedCompNumber;
}


/**
 Sets up and starts the countdown for an auto-mirror
 */
- (IBAction)startCountdown:(id)sender
{
    // Setup our initial countdown value
    counter = CountdownTime;
    
    // Start a timer that calls the [self advanceTimer:] method once every second.
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(advanceTimer:)
                                   userInfo:nil
                                    repeats:YES];
}

/**
 Advances the countdown timer by one second
 */
- (void)advanceTimer:(NSTimer *)timer
{
    // Decrement the counter
    [self setCounter:(counter -1)];
    
    // Update the time countdown display
    [countdownText setStringValue:
        [NSString stringWithFormat:@"Computer will auto-mirror in %@", [self counterToTime]]];
    
    // If the countdown ran out, invalidate the timer and mirror!
    if (counter <= 0) {
        [timer invalidate];
        [self mirror:nil];
    }
}


/**
 @returns a formatted string representing the amount of time left on a seconds counter
 */
- (NSString *)counterToTime
{
    // Counter is in seconds, so seconds/60 = minutes. Round down to the nearest whole minute
    int minutes = floor(counter/60);
    // How many seconds are left in the partial minute?
    int seconds = counter - (60 * minutes);
    
    return [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
}

- (NSString *)computerName
{
    return [NSString stringWithFormat:@"%@-%@-%@", [selectedBuilding value], [selectedRoom number], [self paddedComputerNumber]];
}

// Returns the serial number as a CFString. 
// It is the caller's responsibility to release the returned CFString when done with it.
void CopySerialNumber(CFStringRef *serialNumber)
{
    if (serialNumber != NULL) {
        *serialNumber = NULL;
        
        io_service_t    platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault,
                                                                     IOServiceMatching("IOPlatformExpertDevice"));
        
        if (platformExpert) {
            CFTypeRef serialNumberAsCFString = 
            IORegistryEntryCreateCFProperty(platformExpert,
                                            CFSTR(kIOPlatformSerialNumberKey),
                                            kCFAllocatorDefault, 0);
            if (serialNumberAsCFString) {
                *serialNumber = serialNumberAsCFString;
            }
            
            IOObjectRelease(platformExpert);
        }
    }
}

/**
 Method that mounts the OSD SMB share that contains our text files
 */
- (BOOL)mountOSDShare
{
    // Make sure the directory exists where we will be mounting the volume to
    NSTask *mkdir = [[NSTask alloc] init];
    [mkdir setLaunchPath:@"/bin/mkdir"];
    [mkdir setArguments:[NSArray arrayWithObjects:prefix, nil]];
    [mkdir launch]; [mkdir waitUntilExit];
    
    // Mount the smb share
    NSTask *mount = [[NSTask alloc] init];
    [mount setLaunchPath:@"/sbin/mount_smbfs"];
    [mount setArguments:[NSArray arrayWithObjects:[NSString stringWithFormat:@"//%@:%@@%@/osd$", OSDServerUsername, OSDServerPassword, OSDServerName], prefix, nil]];
    
    [mount launch]; [mount waitUntilExit];
    
    // Get the return code for the mount operation
    int i = [mount terminationStatus];
    // Returns 0 on success, 17 & 64 if already mounted
    return (i == 0 || i == 17 || i == 64) ? YES : NO;
}
@end


