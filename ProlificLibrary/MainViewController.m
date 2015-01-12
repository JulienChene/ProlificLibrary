//
//  ViewController.m
//  ProlificLibrary
//
//  Created by Julien Chene on /21/1214.
//  Copyright (c) 2014 JulienChene. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworking/AFNetworking.h"
#import "Book.h"
#import "MainViewController.h"

#define kBookList   @"BookList"
#define kNameList   @"NameList"

NSString *const kAuthorSort = @"SortByAuthor";
NSString *const kTitleSort = @"SortByTitle";
NSString *const kAvailabilitySort = @"SortByAvailability";

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize bookList;
@synthesize checkoutNameList;

// TODO : Clean files, Availability sort, check if book already exists when adding.

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    bookList = [[NSMutableArray alloc] init];
    searchResults = [[NSMutableArray alloc] init];
    checkoutNameList = [[NSMutableArray alloc] init];
    
    sortingType = @"None";
    chosenBookIndex = 0;
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.mainVC = self;
    
    [self retrieveBooks];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
    
    return [super viewWillAppear:animated];
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
            if ((int)[dict objectForKey:@"id"] == [book bookID])
            {
                isBookExisting = true;
                break;
            }
        }
        
        // If the book doesn't exist, create the book
        if (!isBookExisting)
        {
            // Enables to deal with the null value sent by the server
            NSDate *checkedOutDate = nil;
            NSString *checkedOutBy = @"";
            NSString *publisher = @"";
            
            if (([dict objectForKey:@"publisher"] != nil) && (![[dict objectForKey:@"publisher"] isKindOfClass:[NSNull class]]))
                publisher = [dict objectForKey:@"publisher"];
            
            if (![[dict objectForKey:@"lastCheckedOut"] isKindOfClass:[NSNull class]])
            {
                NSString *dateString = [dict objectForKey:@"lastCheckedOut"];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                
                
                checkedOutDate = [dateFormatter dateFromString:dateString];
            }
            
            if (![[dict objectForKey:@"lastCheckedOutBy"] isKindOfClass:[NSNull class]])
                checkedOutBy = [dict objectForKey:@"lastCheckedOutBy"];
            
            Book *newBook = [[Book alloc] initWithAuthor:[dict objectForKey:@"author"]
                                           andCategories:[dict objectForKey:@"categories"]
                                          andLastCheckIn:nil
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
        {
            [bookList sortUsingComparator:^NSComparisonResult (id obj1, id obj2){
                Book *firstBook = (Book*) obj1;
                Book *secondBook = (Book*) obj2;
                
                int firstBookAvailability = [firstBook bookAvailability];
                int secondBookAvailability = [secondBook bookAvailability];;
                
                if (firstBookAvailability > secondBookAvailability)
                    return (NSComparisonResult)NSOrderedSame;
                else if (firstBookAvailability < secondBookAvailability)
                    return (NSComparisonResult)NSOrderedDescending;
                else
                    return (NSComparisonResult)NSOrderedSame;
            }];
        }
}






#pragma mark - UITableViewController Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return [searchResults count];
    return [self.bookList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 47;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BookCell"];
    
    Book *book = nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
        book = [searchResults objectAtIndex:indexPath.row];
    else
        book = [bookList objectAtIndex:indexPath.row];
    
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
        if ([book bookAvailability] < 20)
            [bookAvailabilityLabel setTextColor:[UIColor blueColor]];
        else if ([book bookAvailability] < 30)
            [bookAvailabilityLabel setTextColor:[UIColor orangeColor]];
        else if ([book bookAvailability] >= 30)
            [bookAvailabilityLabel setTextColor:[UIColor redColor]];
        
        [bookAvailabilityLabel setText:[NSString stringWithFormat:@"%d days", [book bookAvailability]]];
    }
    
    return cell;
}






#pragma mark - UITableViewController Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    chosenBookIndex = indexPath.row;
    [self performSegueWithIdentifier:@"BookDetailSegue" sender:tableView];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteBookWithURL:[[self.bookList objectAtIndex:indexPath.row] bookURL]];
        [self.bookList removeObjectAtIndex:indexPath.row];
        
        [tableView reloadData]; // tell table to refresh now
    }
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
    {
        [bookList removeAllObjects];
        [self.tableView reloadData];
        
        [self deleteAllBooks];
    }
    
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





#pragma mark - AddBookViewController Delegate and BookDetailViewController Delegate

- (void)addBookWithBook:(Book *)book
{
    [bookList addObject:book];
    
    NSDictionary *params = [self setParamsBeforeSendWithBook:book];
    
    [self sendBookWithParams:params];
    
    [self sortListBy:sortingType];
    [self.tableView reloadData];
}

- (NSDictionary*)setParamsBeforeSendWithBook:(Book*)book
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[book bookAuthor], [book bookTitle], [book bookCategories], nil]
                                                                       forKeys:[NSArray arrayWithObjects:@"author", @"title", @"categories", nil]];
    
    // Adding LastCheckedOut
    if ([book bookLastCheckedOut] != nil)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
        [params setObject:[formatter stringFromDate:[book bookLastCheckedOut]] forKey:@"lastCheckedOut"];
    }
    else
        [params setObject:[NSNull null] forKey:@"lastCheckedOut"];
    
    // Adding LastCheckedOutBy
    if ([book bookLastCheckedOutBy] != nil)
        [params setObject:[book bookLastCheckedOutBy] forKey:@"lastCheckedOutBy"];
    else
        [params setObject:[NSNull null] forKey:@"lastCheckedOutBy"];
    
    // Adding publisher
    if ([book bookPublisher] != nil)
        [params setObject:[book bookPublisher] forKey:@"publisher"];
    else
        [params setObject:[NSNull null] forKey:@"publisher"];
    
    return params;
}

- (void)bookCheckoutWithBook:(Book *)book andName:(NSString *)name
{
    int i = 0;
    
    while (i < [bookList count])
    {
        if ([book bookID] == [[bookList objectAtIndex:i] bookID])
        {
            NSDictionary *params = [self setParamsForUpdateWithUpdatedBook:book andOldBook:[bookList objectAtIndex:i]];
            
            [self updateBookWithParams:params andURL:[book bookURL]];
            
            [bookList replaceObjectAtIndex:i withObject:book];
            break;
        }
        i++;
    }
    
    // Check if the name is not already present
    int namePosition = 0;
    Boolean doesNameExist = false;

    while (namePosition < [checkoutNameList count])
    {
        if ([name isEqualToString:[checkoutNameList objectAtIndex:namePosition]])
        {
            doesNameExist = true;
            break;
        }
        namePosition++;
    }
    
    if (!doesNameExist)
        [checkoutNameList addObject:name];
    else
    {
        [checkoutNameList removeObjectAtIndex:namePosition];
        [checkoutNameList insertObject:name atIndex:0];
    }
    
    if ([checkoutNameList count] > 10)
        [checkoutNameList removeObjectAtIndex:10];
}

- (NSDictionary*)setParamsForUpdateWithUpdatedBook:(Book*)updatedBook andOldBook:(Book*)oldBook
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if ([[updatedBook bookLastCheckedOutBy] isEqualToString:[oldBook bookLastCheckedOutBy]])
        [params setObject:[updatedBook bookLastCheckedOutBy] forKey:@"lastCheckedOutBy"];
    
    // Compare dates
    if (![[updatedBook bookLastCheckedOut] compare:[oldBook bookLastCheckedOut]] == NSOrderedSame)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
        
        [params setObject:[formatter stringFromDate:[updatedBook bookLastCheckedOut]] forKey:@"lastCheckedOut"];
    }
    
    return params;
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
        
        int maxID = 0;
        
        for (Book *book in bookList)
        {
            if ([book bookID] > maxID)
                maxID = [book bookID];
        }
        NSLog(@"max ID: %d", maxID);
        [addBookViewController setDelegate:self];
        [addBookViewController setCurrentID:maxID];
    }
    
    if ([[segue identifier] isEqualToString:@"BookDetailSegue"])
    {
        BookDetailViewController *bookDetailViewController = (BookDetailViewController*)[segue destinationViewController];
        
        if (sender == self.searchDisplayController.searchResultsTableView)
            [bookDetailViewController setCurrentBook:[searchResults objectAtIndex:chosenBookIndex]];
        else
            [bookDetailViewController setCurrentBook:[bookList objectAtIndex:chosenBookIndex]];
        
        [bookDetailViewController setNameList:[NSMutableArray arrayWithArray:checkoutNameList]];
        [bookDetailViewController setDelegate:self];
    }
}






#pragma mark - UISearchDisplay Delegate

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [searchResults removeAllObjects];
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"bookAuthor contains[cd] %@ OR bookTitle contains[cd] %@", searchText, searchText];
    searchResults = [NSMutableArray arrayWithArray:[bookList filteredArrayUsingPredicate:resultPredicate]];
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
//        NSLog(@"%@", responseObject);
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

- (void)sendBookWithParams:(NSDictionary*)params
{
    NSString *urlString = @"http://prolific-interview.herokuapp.com/5488c4836aed89000761c2f4/books/";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager POST:urlString parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
//        NSLog(@"JSON: %@", responseObject);
    }
          failure:
     ^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
     }];
}

- (void)updateBookWithParams:(NSDictionary*)params andURL:(NSString*)url
{
    NSString *urlString = [NSString stringWithFormat:@"http://prolific-interview.herokuapp.com/5488c4836aed89000761c2f4%@", url];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager PUT:urlString parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
//         NSLog(@"JSON: %@", responseObject);
     }
          failure:
     ^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
     }];
}

- (void)deleteBookWithURL:(NSString*)url
{
    NSString *urlString = [NSString stringWithFormat:@"http://prolific-interview.herokuapp.com/5488c4836aed89000761c2f4%@", url];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager DELETE:urlString parameters:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
//         NSLog(@"JSON: %@", responseObject);
     }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
}

- (void)deleteAllBooks
{
    NSString *urlString = @"http://prolific-interview.herokuapp.com/5488c4836aed89000761c2f4/clean";

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager DELETE:urlString parameters:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
//         NSLog(@"JSON: %@", responseObject);
     }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
    }];
}





#pragma mark - Saving and Loading data

- (void)saveData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedBookList = [NSKeyedArchiver archivedDataWithRootObject:bookList];
    NSData *encodedNameList = [NSKeyedArchiver archivedDataWithRootObject:checkoutNameList];
    [defaults setObject:encodedBookList forKey:kBookList];
    [defaults setObject:encodedNameList forKey:kNameList];
    
    [defaults synchronize];
}

- (void)loadData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:kBookList] != nil)
    {
        NSData *encodedObject = [defaults objectForKey:kBookList];
        NSArray *task = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
        NSMutableArray *tempoArray = [[NSMutableArray alloc] initWithArray:task];
        [bookList removeAllObjects];
        
        for (Book *book in tempoArray)
        {
            [bookList addObject:book];
        }
    }

    if ([defaults objectForKey:kNameList] != nil)
    {
        NSData *encodedObject = [defaults objectForKey:kNameList];
        NSMutableArray *tempoArray = [[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:encodedObject]];
        [checkoutNameList removeAllObjects];
        
        for (NSString *name in tempoArray)
        {
            [checkoutNameList addObject:name];
        }
    }
    
    [self.tableView reloadData];
}

@end
