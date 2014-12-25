//
//  ViewController.m
//  ProlificLibrary
//
//  Created by Julien Chene on /21/1214.
//  Copyright (c) 2014 JulienChene. All rights reserved.
//

#import "AFNetworking/AFNetworking.h"
#import "Book.h"
#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize bookList;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    bookList = [[NSMutableArray alloc] init];
    
    [self retrieveBooks];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (int)isInStockWithBook:(Book*)book
{
    if ([book bookLastCheckIn] || [book bookLastCheckedOut] == nil)
        return (-1);
    
    if ([book bookLastCheckedOut] == nil)
        NSLog(@"bookLastcheckout nil");
    
    NSTimeInterval timeDifference = [[NSDate date] timeIntervalSinceDate:[book bookLastCheckedOut]];
    
    timeDifference = (((timeDifference / 60) / 60) / 24);
    
    return timeDifference;
}

- (void)updateBookListWithArray:(NSArray*)newList
{
    for (NSDictionary *dict in newList)
    {
        Boolean isBookExisting = false;
        for (Book *book in bookList)
        {
            
            if (([dict objectForKey:@"author"] == [book bookAuthor])
                || ([dict objectForKey:@"title"] == [book bookTitle]))
            {
                isBookExisting = true;
                break;
            }
        }
        
        if (!isBookExisting)
        {
            NSDate *checkedOutDate = nil;
            NSString *checkedOutBy = nil;
            
            if (![[dict objectForKey:@"lastCheckedOut"] isKindOfClass:[NSNull class]])
                checkedOutDate = [dict objectForKey:@"lastCheckedOut"];
            
            if (![[dict objectForKey:@"lastCheckedOutBy"] isKindOfClass:[NSNull class]])
                checkedOutBy = [dict objectForKey:@"lastCheckedOutBy"];
            
            Book *newBook = [[Book alloc] initWithAuthor:[dict objectForKey:@"author"]
                                           andCategories:[dict objectForKey:@"categories"]
                                         andLastCheckOut:checkedOutDate
                                       andLastCheckOutBy:checkedOutBy
                                            andPublisher:[dict objectForKey:@"publisher"]
                                                andTitle:[dict objectForKey:@"title"]
                                                  andURL:[dict objectForKey:@"url"]];
            
            [bookList addObject:newBook];
        }
    }
}





#pragma mark - UITableViewController Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"section number : %d", [bookList count]);
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.bookList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cell");
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




#pragma mark - AFNetworking

- (void)retrieveBooks
{
    NSString *string = @"http://prolific-interview.herokuapp.com/5488c4836aed89000761c2f4/books";
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *responseList = (NSArray *)responseObject;
        [self updateBookListWithArray:responseList];
        [self.tableView reloadData];
    }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Books"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    }];
    
    [operation start];
}

@end
