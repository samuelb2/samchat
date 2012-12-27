//
//  SignupViewController.m
//  ImageEncryption
//
//  Created by Sam Baumgarten on 12/10/12.
//  Copyright (c) 2012 Makrr. All rights reserved.
//
#define SCROLLVIEW_CONTENT_HEIGHT 460
#define SCROLLVIEW_CONTENT_WIDTH  320

#import "SignupViewController.h"
#import "TabBarViewController.h"

@interface SignupViewController ()

@end

@implementation SignupViewController
@synthesize scrollView;
@synthesize keyboardVisible, activeField, offset;
@synthesize emailField;
@synthesize passwordField;
@synthesize passwordConfirmationField;
@synthesize snapChatManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated {
    // Register for the events
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector (keyboardDidShow:)
     name: UIKeyboardDidShowNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector (keyboardDidHide:)
     name: UIKeyboardDidHideNotification
     object:nil];
    
    // Setup content size
    scrollView.contentSize = CGSizeMake(SCROLLVIEW_CONTENT_WIDTH,
                                        SCROLLVIEW_CONTENT_HEIGHT);
    
    //Initially the keyboard is hidden
    keyboardVisible = NO;

    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signup:(id)sender {
    NSDictionary *response = [[[NSString alloc] initWithData:[WebService postURL:[NSURL URLWithString:@"http://192.168.2.24:3000/api/v1/signup.json"] withBody:[NSString stringWithFormat:@"user[email]=%@&user[password]=%@&user[password_confirmation]=%@", emailField.text, passwordField.text, passwordConfirmationField.text]] encoding:NSUTF8StringEncoding] JSONValue];
    NSLog(@"resp: %@", response);
    if (response) {
        if ([response objectForKey:@"token"]) {
            snapChatManager = [[SnapChat alloc] init];
            
            User *currentUser = [[User alloc] init];
            [currentUser setId:[response objectForKey:@"id"]];
            [currentUser setEmail:[response objectForKey:@"email"]];
            [currentUser setAuthenticationToken:[response objectForKey:@"token"]];
            
            [snapChatManager setCurrentUser:currentUser];
             
            [self performSegueWithIdentifier:@"gotoMainApp" sender:self];
        } else if ([response objectForKey:@"message"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[response objectForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
    }

}

-(void) keyboardDidShow: (NSNotification *)notif {
    NSLog(@"Keyboard is visible");
    // If keyboard is visible, return
    if (keyboardVisible) {
        NSLog(@"Keyboard is already visible. Ignore notification.");
        return;
    }
    
    // Get the size of the keyboard.
    CGSize keyboardSize = CGSizeMake(320, 150);
    
    // Save the current location so we can restore
    // when keyboard is dismissed
    offset = scrollView.contentOffset;
    
    // Resize the scroll view to make room for the keyboard
    CGRect viewFrame = scrollView.frame;
    viewFrame.size.height -= keyboardSize.height;
    scrollView.frame = viewFrame;
    
    NSLog(@"orig: %f", [activeField frame].origin.y);
    [scrollView scrollRectToVisible:CGRectMake(0, [activeField frame].origin.y  , keyboardSize.width, keyboardSize.height) animated:YES];
    
    NSLog(@"ao fim");
    // Keyboard is now visible
    keyboardVisible = YES;
}

-(void) keyboardDidHide: (NSNotification *)notif {

    [UIView beginAnimations:@"hife" context:nil];
    // Reset the frame scroll view to its original value
    scrollView.frame = CGRectMake(0, 0, SCROLLVIEW_CONTENT_WIDTH, SCROLLVIEW_CONTENT_HEIGHT);
    [UIView commitAnimations];
    // Reset the scrollview to previous location
    scrollView.contentOffset = offset;
    
    // Keyboard is no longer visible
    keyboardVisible = NO;
    
}


-(BOOL) textFieldShouldBeginEditing:(UITextField*)textField {
    activeField = textField;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField tag] == 1) {
        [textField resignFirstResponder];
         keyboardVisible = NO;
    }
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    TabBarViewController *vc = [segue destinationViewController];
    [vc setSnapChatManager:snapChatManager];
}
@end
