//
//  ViewController.m
//  ProlificLibrary
//
//  Created by Julien Chene on /21/1214.
//  Copyright (c) 2014 JulienChene. All rights reserved.
//

#import "Book.h"
#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize bookList;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (int)isInStockWithBook:(Book*)book
{
    if ([book bookLastCheckIn])
        return (-1);
    
    NSTimeInterval timeDifference = [[NSDate date] timeIntervalSinceDate:[book bookLastCheckedOut]];
    
    timeDifference = (((timeDifference / 60) / 60) / 24);
    
    return timeDifference;
}

#pragma mark - UITableViewController Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.bookList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookCell"];
    
    Book *book = [bookList objectAtIndex:indexPath.row];
    int lastCheckOut = [self isInStockWithBook:book];
    
    UILabel *bookTitleLabel = (UILabel *)[cell viewWithTag:100];
    [bookTitleLabel setText:[book bookTitle]];
    
    UILabel *bookAuthorLabel = (UILabel *)[cell viewWithTag:101];
    [bookAuthorLabel setText:[book bookAuthor]];
    
    
    
    UILabel *bookAvailabilityLabel = (UILabel *)[cell viewWithTag:102];
    if (lastCheckOut < 0)
    {
        [bookAvailabilityLabel setTextColor:[UIColor blackColor]];
        [bookAvailabilityLabel setText:@"In Stock"];
    }
    else
    {
        [bookAvailabilityLabel setTextColor:[UIColor redColor]];
        [bookAvailabilityLabel setText:[NSString stringWithFormat:@"%d days", lastCheckOut]];
    }
    
    return cell;
}

@end
