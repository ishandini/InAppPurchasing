//
//  NonConsumableViewController.m
//  InAppPurchasing
//
//  Created by Ishan on 10/23/15.
//  Copyright © 2015 AppmonkeyZ MacBook Pro. All rights reserved.
//

#import "NonConsumableViewController.h"
#import <StoreKit/StoreKit.h>
#import <KVNProgress/KVNProgress.h>


@interface NonConsumableViewController () <SKPaymentTransactionObserver, SKProductsRequestDelegate>

@property (strong, nonatomic) IBOutlet UIButton *btnBuyAccess;

@property (strong, nonatomic) IBOutlet UIButton *btnPremiumFeature;

@property (strong, nonatomic) IBOutlet UILabel *lblStatus;

@property(strong,nonatomic) SKProduct *product;

@end

@implementation NonConsumableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [_btnBuyAccess setUserInteractionEnabled:NO];
    [self getProductInfo];

    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    
}


- (void)getProductInfo {

    if([SKPaymentQueue canMakePayments]) {
    
        NSMutableArray *productIdentifier = [[NSMutableArray alloc] init];
        [productIdentifier addObject:[NSString stringWithFormat:@"nonrenewing1234"]];
        
        SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:[[NSSet alloc] initWithArray:productIdentifier]];
        request.delegate = self;
        [request start];
        
        [KVNProgress showWithStatus:@"" onView:self.view];
        
    }else {
    
         self.lblStatus.text = @"In App Purchase is not enabled";
    }
    
}


#pragma mark - Delegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response NS_AVAILABLE_IOS(3_0) {
    
    NSArray *productArray = response.products;
    
    if(productArray.count > 0) {
        
        _product = productArray[0];
        _btnBuyAccess.userInteractionEnabled = YES;
        self.lblStatus.text = @"Ready for purchase";
    
    }else {
    
         self.lblStatus.text = @"Product not found";
    }

    productArray = response.invalidProductIdentifiers;
    
    for( SKProduct *product in productArray) {
        
        _lblStatus.text = [NSString stringWithFormat:@"Product not found %@",product];
    }
    
    [KVNProgress dismiss];
    
}


- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions NS_AVAILABLE_IOS(3_0) {

    for(SKPaymentTransaction *transaction in transactions) {
    
        switch (transaction.transactionState) {
        
                case SKPaymentTransactionStatePurchased:
                
                _lblStatus.text = @"Purchase complete";
                [_btnPremiumFeature setUserInteractionEnabled:YES];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
                
                case SKPaymentTransactionStateFailed:
                
                _lblStatus.text = @"Purchase fail";
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
                
                default:
                break;
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
