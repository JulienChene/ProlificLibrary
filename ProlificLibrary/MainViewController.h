//
//  ViewController.h
//  ProlificLibrary
//
//  Created by Julien Chene on /21/1214.
//  Copyright (c) 2014 JulienChene. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddBookViewController.h"
#import "BookDetailViewController.h"

@interface MainViewController : UITableViewController <UIActionSheetDelegate,  UISearchDisplayDelegate, AddBookViewControllerDelegate, BookDetailViewControllerDelegate>
{
    NSString        *sortingType;
    NSUInteger      chosenBookIndex;
    NSMutableArray  *searchResults;
}

@property (strong, nonatomic) NSMutableArray    *bookList;
@property (strong, nonatomic) NSMutableArray    *checkoutNameList;

- (void)saveData;
- (void)loadData;

@end