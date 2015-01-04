//
//  ViewController.h
//  ProlificLibrary
//
//  Created by Julien Chene on /21/1214.
//  Copyright (c) 2014 JulienChene. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddBookViewController.h"

@interface MainViewController : UITableViewController <UIActionSheetDelegate, AddBookViewControllerDelegate, bookDetailViewControllerDelegate>
{
    NSString    *sortingType;
    NSUInteger   chosenBookIndex;
}

@property (strong, nonatomic) NSMutableArray    *bookList;

@end

