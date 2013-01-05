//
//  DKQueryTableViewController.h
//  DeploydKit
//
//  Created by Denis Berton
//  Copyright (c) 2012 clooket.com. All rights reserved.
//
//  DeploydKit is based on DataKit (https://github.com/eaigner/DataKit)
//  Created by Erik Aigner
//  Copyright (c) 2012 chocomoko.com. All rights reserved.
//

#import "DKQuery.h"
#import "DKEntity.h"

/**
 A table view to display a specified entity paginated
 */
@interface DKQueryTableViewController : UITableViewController

/** @name Initializing Entity Tables */

/**
 Initializes a new query table for the specified entity
 @param entityName The entity name displayed in the table
 @return The initialized query table
 */
- (id)initWithEntityName:(NSString *)entityName;

/**
 Initializes a new query table for the specified entity
 @param style The table view style
 @param entityName The entity name displayed in the table
 @return The initialized query table
 */
- (id)initWithStyle:(UITableViewStyle)style entityName:(NSString *)entityName;

/** @name Configuration */

/**
 The entity name used for the table
 */
@property (nonatomic, copy) NSString *entityName;

/**
 The entity key to use for the cell title text
 */
@property (nonatomic, copy) NSString *displayedTitleKey;

/**
 The entity key to use for the cell image data
 */
@property (nonatomic, copy) NSString *displayedImageKey;

/**
 The number of objects displayed per page
 */
@property (nonatomic, assign) NSUInteger objectsPerPage;

/**
 If the table view is currently fetching a page
 */
@property (nonatomic, assign, readonly) BOOL isLoading;

/**
 The currently loaded objects
 
 Objects can be either of type <DKEntity> or NSDictionary
 */
@property (nonatomic, strong, readonly) NSMutableArray *objects;

/**
 The search bar
 
 Use this property to configure it.
 */
@property (nonatomic, strong, readonly) UISearchBar *searchBar;

/** @name Reloading */

/**
 Reloads the table in the background
 */
- (void)reloadInBackground;

/**
 Reloads the table in the background
 @param block The block that is called when the reload finished.
 */
- (void)reloadInBackgroundWithBlock:(void (^)(NSError *error))block;

/**
 Called when the table is about to reload it's objects
 */
- (void)queryTableWillReload;

/**
 Called when the table did reload it's objects
 */
- (void)queryTableDidReload;

/**
 Give subclasses a chance to do custom post processing on the table objects on a different queue.
 */
- (void)postProcessResults;

/** @name Methods to Override */

/**
 Determines if table shows a search bar in the header view
 
 The search bar is updated on each reload, so this property can change any time.
 @return `YES` if the table should display a search bar in the header, `NO` otherwise.
 */
- (BOOL)hasSearchBar;

/**
 Specify a custom query by overriding this method
 
 @return The query to use for the tables objects
 */
- (DKQuery *)tableQuery;

/**
 Returns a query for the entered search text
 
 @param text The query text
 @return The search query
 */
- (DKQuery *)tableQueryForSearchText:(NSString *)text;

/**
 Determines if the cell at the index path is a next-page cell
 @param indexPath The cell index path to check.
 @return NO if the cell represents a <DKEntity>, YES if it is the next-page cell.
 */
- (BOOL)tableViewCellIsNextPageCellAtIndexPath:(NSIndexPath *)indexPath;

/**
 Returns the cell for the given index path
 @param tableView The calling table view
 @param indexPath The index path for the cell
 @return The initialized or dequeued table cell
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 Returns the cell used as the next-page cell
 @param tableView The calling table view
 @return The initialized or dequeued next-page cell
 */
- (UITableViewCell *)tableViewNextPageCell:(UITableView *)tableView;

/**
 Called when a table row is selected
 @param tableView The calling table view
 @param indexPath The index path of the selected row
 @param object The selected object. Can be of type <DKEntity> or NSDictionary.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath object:(id)object;

@end
