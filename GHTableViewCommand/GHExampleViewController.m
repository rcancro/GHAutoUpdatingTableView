//
//  GHFirstViewController.m
//  GHTableViewCommand
//
//  Created by ricky cancro on 2/9/14.
//  Copyright (c) 2014 ricky cancro. All rights reserved.
//

#import "GHExampleViewController.h"
#import "GHTableViewCommand.h"

static const NSString *kSectionTitleKey = @"section title";
static const NSString *kRowDataKey = @"data";
static NSString *kDefaultCellIdentifier = @"cell";

@interface GHExampleViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *tableData;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *actionBarButton;
@property (nonatomic, strong) NSMutableSet *selectedRows;
@end

@implementation GHExampleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    NSMutableArray *section1 = [NSMutableArray arrayWithArray:@[[self randomCellTitle],[self randomCellTitle],[self randomCellTitle],[self randomCellTitle],[self randomCellTitle]]];
    NSMutableArray *section2 = [NSMutableArray arrayWithArray:@[[self randomCellTitle],[self randomCellTitle],[self randomCellTitle],[self randomCellTitle],[self randomCellTitle]]];
    NSMutableArray *section3 = [NSMutableArray arrayWithArray:@[[self randomCellTitle],[self randomCellTitle],[self randomCellTitle],[self randomCellTitle],[self randomCellTitle]]];
    NSMutableArray *section4 = [NSMutableArray arrayWithArray:@[[self randomCellTitle],[self randomCellTitle],[self randomCellTitle],[self randomCellTitle],[self randomCellTitle]]];
    NSMutableArray *section5 = [NSMutableArray arrayWithArray:@[[self randomCellTitle],[self randomCellTitle],[self randomCellTitle],[self randomCellTitle],[self randomCellTitle]]];
    self.tableData = [NSMutableArray arrayWithArray:@[@{kSectionTitleKey:@"section1", kRowDataKey:section1},
                                                      @{kSectionTitleKey:@"section2", kRowDataKey:section2},
                                                      @{kSectionTitleKey:@"section3", kRowDataKey:section3},
                                                      @{kSectionTitleKey:@"section4", kRowDataKey:section4},
                                                      @{kSectionTitleKey:@"section5", kRowDataKey:section5}
                                                      ]];
    self.selectedRows = [NSMutableSet set];
    [self setupActionButton];
}
                                                      
- (NSString *)randomCellTitle
{
	NSString*	uuidString = nil;
	
	CFUUIDRef	uuidRef = CFUUIDCreate(kCFAllocatorDefault);
	if (uuidRef)
	{
		uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
		
		CFRelease(uuidRef);
	}
	
	return uuidString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupActionButton
{
    self.actionBarButton.target = self;
    if ([self.selectedRows count] > 0)
    {
        [self.actionBarButton setAction:@selector(deleteSelectedRowsAction:)];
        [self.actionBarButton setTitle:@"Delete Rows"];
    }
    else
    {
        [self.actionBarButton setAction:@selector(addRowAction:)];
        [self.actionBarButton setTitle:@"Add Row"];
    }
}

#pragma mark - actions

- (IBAction)clearSelection:(id)sender
{
    self.selectedRows = [NSMutableSet set];
    [self.tableView reloadData];
}

- (void)deleteSelectedRowsAction:(id)sender
{
    
}

- (NSArray *)nonEmptySections
{
    NSMutableArray *sections = [NSMutableArray array];
    for (NSDictionary *sectionData in self.tableData)
    {
        if ([sectionData[kRowDataKey] count] > 0)
        {
            [sections addObject:sectionData[kSectionTitleKey]];
        }
    }
    return sections;
}

- (void)addRowAction:(id)sender
{
    // Create the sectionDataObject needed to update the table
    GHTableCommandSectionIndexData *sectionDataObject = [[GHTableCommandSectionIndexData alloc] init];
    
    // set the current sections as the "oldSections"
    sectionDataObject.outdatedSections = [self nonEmptySections];
    
    GHTableCommandAllSectionData *rowDataObject = [[GHTableCommandAllSectionData alloc] init];
    for (NSDictionary *sectionData in self.tableData)
    {
        [rowDataObject addOutdatedData:sectionData[kRowDataKey] forSection:sectionData[kSectionTitleKey]];
    }
    
    // insert the new row
    NSUInteger sectionIndex = rand() % [self numberOfSectionsInTableView:self.tableView];
    NSUInteger rowIndex = rand() % [self tableView:self.tableView numberOfRowsInSection:sectionIndex];
    
    NSDictionary *sectionData = [self.tableData objectAtIndex:sectionIndex];
    NSMutableArray *rowData = [sectionData objectForKey:kRowDataKey];
    
    NSString *title = [self randomCellTitle];
    [rowData insertObject:title atIndex:rowIndex];
    NSLog(@"added row at (%d,%d) title: %@", sectionIndex, rowIndex, title);
    
    // now get the updated non empty sections and set them in the updatedSections
    sectionDataObject.updatedSections = [self nonEmptySections];
    
    for (NSDictionary *sectionData in self.tableData)
    {
        [rowDataObject addUpdatedData:sectionData[kRowDataKey] forSection:sectionData[kSectionTitleKey]];
    }
    
    [self.tableView updateWithSectionIndexData:sectionDataObject sectionData:rowDataObject withRowAnimation:UITableViewRowAnimationAutomatic callback:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.tableData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *sectionData = [self.tableData objectAtIndex:section];
    return [sectionData[kRowDataKey] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDefaultCellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDefaultCellIdentifier];
    }
    NSDictionary *sectionData = [self.tableData objectAtIndex:indexPath.section];
    NSArray *rowData = sectionData[kRowDataKey];
    cell.textLabel.text = [rowData objectAtIndex:indexPath.row];
    cell.selected = [self.selectedRows containsObject:indexPath];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *sectionData = [self.tableData objectAtIndex:section];
    return sectionData[kSectionTitleKey];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.selectedRows addObject:indexPath];
    [self setupActionButton];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.selectedRows removeObject:indexPath];
    [self setupActionButton];
}

@end
