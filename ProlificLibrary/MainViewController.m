//
//  ViewController.m
//  ProlificLibrary
//
//  Created by Julien Chene on /21/1214.
//  Copyright (c) 2014 JulienChene. All rights reserved.
//

#import "AFNetworking/AFNetworking.h"
#import "Book.h"
#import "BookDetailViewController.h"
#import "MainViewController.h"

NSString *const kAuthorSort = @"SortByAuthor";
NSString *const kTitleSort = @"SortByTitle";
NSString *const kAvailabilitySort = @"SortByAvailability";

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize bookList;

// TODO : Clean files, Availability sort, check if book already exists when adding.

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    bookList = [[NSMutableArray alloc] init];
    
    sortingType = @"None";
    chosenBookIndex = 0;
    
    [self retrieveBooks];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






#pragma mark - Book List Processing

- (int)isInStockWithLastCheckIn:(NSDate*)lastCheckIn andLastCheckOut:(NSDate*)lastCheckOut
{
    if (lastCheckIn != nil || lastCheckOut == nil)
        return (-1);
    
    NSTimeInterval timeDifference = [[NSDate date] timeIntervalSinceDate:lastCheckOut];
    
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
            // Enables to deal with the null value sent by the server
            NSDate *checkedOutDate = nil;
            NSString *checkedOutBy = @"";
            NSString *publisher = @"";
            
            if (([dict objectForKey:@"publisher"] != nil) && (![[dict objectForKey:@"publisher"] isKindOfClass:[NSNull class]]))
                publisher = [dict objectForKey:@"publisher"];
            
            if (![[dict objectForKey:@"lastCheckedOut"] isKindOfClass:[NSNull class]])
                checkedOutDate = [dict objectForKey:@"lastCheckedOut"];
            
            if (![[dict objectForKey:@"lastCheckedOutBy"] isKindOfClass:[NSNull class]])
                checkedOutBy = [dict objectForKey:@"lastCheckedOutBy"];
            
            Book *newBook = [[Book alloc] initWithAuthor:[dict objectForKey:@"author"]
                                           andCategories:[dict objectForKey:@"categories"]
                                         andLastCheckOut:checkedOutDate
                                       andLastCheckOutBy:checkedOutBy
                                            andPublisher:publisher
                                                andTitle:[dict objectForKey:@"title"]
                                                  andURL:[dict objectForKey:@"url"]
                                         andAvailability:[self isInStockWithLastCheckIn:nil andLastCheckOut:checkedOutDate]
                                                   andID:(int)[dict objectForKey:@"id"]];
            
            [bookList addObject:newBook];
        }
    }
}

- (void)sortListBy:(NSString*)type
{
    if ([type isEqualToString:kAuthorSort])
        [bookList sortUsingComparator:^NSComparisonResult (id obj1, id obj2){
            Book *firstBook = (Book*) obj1;
            Book *secondBook = (Book*) obj2;
            
            return [[firstBook bookAuthor] compare:[secondBook bookAuthor]];
        }];
    else
        if ([type isEqualToString:kTitleSort])
            [bookList sortUsingComparator:^NSComparisonResult (id obj1, id obj2){
                Book *firstBook = (Book*) obj1;
                Book *secondBook = (Book*) obj2;
            
                return [[firstBook bookTitle] compare:[secondBook bookTitle]];
            }];
    else
        if ([type isEqualToString:kAvailabilitySort])
            NSLog(@"Availability sort");
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 47;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookCell"];
    
    Book *book = [bookList objectAtIndex:indexPath.row];
    
    UILabel *bookTitleLabel = (UILabel *)[cell viewWithTag:100];
    [bookTitleLabel setText:[book bookTitle]];
    
    UILabel *bookAuthorLabel = (UILabel *)[cell viewWithTag:101];
    [bookAuthorLabel setText:[book bookAuthor]];
    
    
    
    UILabel *bookAvailabilityLabel = (UILabel *)[cell viewWithTag:102];
    if ([book bookAvailability] < 0)
    {
        [bookAvailabilityLabel setTextColor:[UIColor blackColor]];
        [bookAvailabilityLabel setText:@"In Stock"];
    }
    else
    {
        [bookAvailabilityLabel setTextColor:[UIColor redColor]];
        [bookAvailabilityLabel setText:[NSString stringWithFormat:@"%d days", [book bookAvailability]]];
    }
    
    return cell;
}






#pragma mark - UITableViewController Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    chosenBookIndex = indexPath.row;
    [self performSegueWithIdentifier:@"BookDetailSegue" sender:self];
}







#pragma mark - Action Sheet

- (IBAction)organizeList:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Organize"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Remove all books"
                                                    otherButtonTitles:@"By author", @"By title", @"By stock", nil];
    
    [actionSheet showInView:[self view]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
        NSLog(@"Remove all items");
    
    // Sort by author
    if (buttonIndex == 1)
    {
        sortingType = kAuthorSort;
        [self sortListBy:kAuthorSort];
        
        [self.tableView reloadData];
    }
    
    // Sort by title
    if (buttonIndex == 2)
    {
        sortingType = kTitleSort;
        [self sortListBy:kTitleSort];
        
        [self.tableView reloadData];
    }
        
    // Sort by availability
    if (buttonIndex == 3)
    {
        sortingType = kAvailabilitySort;
        [self sortListBy:kAvailabilitySort];
        
        [self.tableView reloadData];
    }
}





#pragma mark - AddBookViewController Delegate

- (void)addBookWithBook:(Book *)book
{
    [bookList addObject:book];
    
    [self sortListBy:sortingType];
    [self.tableView reloadData];
}







#pragma mark - Segue handling

- (IBAction)addBookButtonPressed:(id)sender
{
    [self performSegueWithIdentifier:@"AddBookSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"AddBookSegue"])
    {
        AddBookViewController *addBookViewController = (AddBookViewController*)[segue destinationViewController];
        
        int maxID = 1;
        
        for (Book *book in bookList)
        {
            if ([book bookID] > maxID)
                maxID = [book bookID];
        }
        
        [addBookViewController setDelegate:self];
        [addBookViewController setCurrentID:maxID];
    }
    
    if ([[segue identifier] isEqualToString:@"BookDetailSegue"])
    {
        BookDetailViewController *bookDetailViewController = (BookDetailViewController*)[segue destinationViewController];
        
        [bookDetailViewController setCurrentBook:[bookList objectAtIndex:chosenBookIndex]];
    }
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

- (void)deleteAllBooks
{
    NSString *string = @"http://prolific-interview.herokuapp.com/5488c4836aed89000761c2f4/clean";
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
