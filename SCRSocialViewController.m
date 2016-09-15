//
//  SCRSocialViewController.m
//
//  Created by Michael Hanna on 2016-02-04.
//  Copyright © 2016 ils. All rights reserved.
//

#import "SCRSocialViewController.h"

@interface SCRSocialViewController ()
@property (strong, nonatomic) IBOutlet UILabel *followUsOnLabel;
@property (strong, nonatomic) IBOutlet UIImageView *twitterImageView;

@end

@implementation SCRSocialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.twitterImageView.layer.cornerRadius = 9.0;
    self.twitterImageView.layer.masksToBounds = YES;
    /*
    if ([accountsArray count] > 0) {
        // Grab the initial Twitter account to tweet from.
        ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
        
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
        [tempDict setValue:@"numerologistiOS" forKey:@"screen_name"];
        [tempDict setValue:@"true" forKey:@"follow"];
        
        TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"https://api.twitter.com/1/friendships/create.json"]
                                                     parameters:tempDict
                                                  requestMethod:TWRequestMethodPOST];
        
        
        [postRequest setAccount:twitterAccount];
        
        [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            NSString *output = [NSString stringWithFormat:@"HTTP response status: %i", [urlResponse statusCode]];
            NSLog(@"%@", output);
            if (urlResponse.statusCode == 200)
            {
                UIAlertView *statusOK = [[UIAlertView alloc]
                                         initWithTitle:@"Thank you for Following!"
                                         message:@"You are now following us on Twitter!"
                                         delegate:self
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [statusOK show];
                });
            }
        }];
    }
     */
    
    /*
    
    NSDictionary *parameters = @{@"screen_name" : @"@techotopia",
                                 @"include_rts" : @"0",
                                 @"trim_user" : @"1",
                                 @"count" : @"20"};
    
    SLRequest *postRequest = [SLRequest
                              requestForServiceType:SLServiceTypeTwitter
                              requestMethod:SLRequestMethodGET
                              URL:requestURL parameters:parameters];
    
    [postRequest performRequestWithHandler:
     ^(NSData *responseData, NSHTTPURLResponse
       *urlResponse, NSError *error)
     {
         self.dataSource = [NSJSONSerialization
                            JSONObjectWithData:responseData
                            options:NSJSONReadingMutableLeaves
                            error:&error];
         
         if (self.dataSource.count != 0) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tweetTableView reloadData];
             });
         }
     }];
*/
}

@end
