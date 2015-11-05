//
//  ViewController.m
//  InAppPurchasing
//
//  Created by Ishan on 10/19/15.
//  Copyright © 2015 AppmonkeyZ MacBook Pro. All rights reserved.
//

#import "ConsumableViewController.h"
#import <StoreKit/StoreKit.h>
#import <KVNProgress/KVNProgress.h>


@interface ConsumableViewController ()<SKPaymentTransactionObserver, SKProductsRequestDelegate>

@property (strong, nonatomic) IBOutlet UIButton *btnBuyAccess;

@property (strong, nonatomic) IBOutlet UIButton *btnPremiumFeature;

@property (strong, nonatomic) IBOutlet UILabel *lblStatus;

@property(strong,nonatomic) SKProduct *product;

@end

@implementation ConsumableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
     Added new test line
     */
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [self.btnBuyAccess setUserInteractionEnabled:NO];
    [self getProductInfo];
    
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)getProductInfo {

    if([SKPaymentQueue canMakePayments]) {
        
        NSMutableArray *productIdentifierList = [[NSMutableArray alloc] init];
        [productIdentifierList addObject:[NSString stringWithFormat:@"consumable1234"]];  // consumable1234 is product ID
        
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productIdentifierList]];
        
        request.delegate = self;
        [request start];
        [KVNProgress showWithStatus:@"" onView:self.view];
        
    }else {
    
        self.lblStatus.text = @"In App Purchase is not enabled";
    }
    
}


#pragma mark - Delegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response NS_AVAILABLE_IOS(3_0){

    NSArray *productsArray = response.products;
    
    if(productsArray.count > 0) {
    
        _product = productsArray[0];
        _btnBuyAccess.userInteractionEnabled = YES;
        _lblStatus.text = @"Ready for purchase";
        
    }else {
    
        _lblStatus.text = @"Products not found";
    }
    
    productsArray = response.invalidProductIdentifiers;
    
    for( SKProduct *product in productsArray) {
    
        _lblStatus.text = [NSString stringWithFormat:@"Product not found %@",product];
    }
    
    [KVNProgress dismiss];
    
}


- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions NS_AVAILABLE_IOS(3_0) {
    
    for(SKPaymentTransaction *transaction in transactions) {
    
        if(transaction.transactionState == SKPaymentTransactionStatePurchased){
        
            _lblStatus.text = @"Purchase complete";
            [_btnPremiumFeature setUserInteractionEnabled:YES];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            
        }else if (transaction.transactionState == SKPaymentTransactionStateFailed){
        
            _lblStatus.text = @"Purchase failed";
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            
        }
        
    }
    
}




- (IBAction)pressedBuyAccess:(id)sender {
    
    SKPayment *payment = [SKPayment paymentWithProduct:self.product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
    _lblStatus.text = @"Pressed Buy Access";
    [_btnPremiumFeature setUserInteractionEnabled:NO];
}




@end
