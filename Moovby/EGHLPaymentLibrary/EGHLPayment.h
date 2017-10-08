//
//  EGHLPayment.h
//  EGHLPayment
//
//  Created by Administrator on 15-1-24.
//  Copyright (c) 2015年 ghl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PaymentRequestPARAM : NSObject
@property BOOL RealHost;
@property (strong, nonatomic) NSString *Amount;
@property (strong, nonatomic) NSString *PaymentID;
@property (strong, nonatomic) NSString *OrderNumber;
@property (strong, nonatomic) NSString *MerchantName;
@property (strong, nonatomic) NSString *ServiceID;
@property (strong, nonatomic) NSString *PymtMethod;
@property (strong, nonatomic) NSString *MerchantReturnURL;
@property (strong, nonatomic) NSString *CustEmail;
@property (strong, nonatomic) NSString *Password;
@property (strong, nonatomic) NSString *CustPhone;
@property (strong, nonatomic) NSString *CurrencyCode;
@property (strong, nonatomic) NSString *CustName;
@property (strong, nonatomic) NSString *LanguageCode;
@property (strong, nonatomic) NSString *PaymentDesc;
@property (strong, nonatomic) NSString *PageTimeout;
@property (strong, nonatomic) NSString *CustIP;
@property (strong, nonatomic) NSString *MerchantApprovalURL;
@property (strong, nonatomic) NSString *CustMAC;
@property (strong, nonatomic) NSString *MerchantUnApprovalURL;
@property (strong, nonatomic) NSString *CardHolder;
@property (strong, nonatomic) NSString *CardNo;
@property (strong, nonatomic) NSString *CardExp;
@property (strong, nonatomic) NSString *CardCVV2;
@property (strong, nonatomic) NSString *BillAddr;
@property (strong, nonatomic) NSString *BillPostal;
@property (strong, nonatomic) NSString *BillCity;
@property (strong, nonatomic) NSString *BillRegion;
@property (strong, nonatomic) NSString *BillCountry;
@property (strong, nonatomic) NSString *ShipAddr;
@property (strong, nonatomic) NSString *ShipPostal;
@property (strong, nonatomic) NSString *ShipCity;
@property (strong, nonatomic) NSString *ShipRegion;
@property (strong, nonatomic) NSString *ShipCountry;
@property (strong, nonatomic) NSString *TokenType;
@property (strong, nonatomic) NSString *Token;
@property (strong, nonatomic) NSString *SessionID;
@property (strong, nonatomic) NSString *IssuingBank;
@property (strong, nonatomic) NSString *MerchantCallBackURL;
@property (strong, nonatomic) NSString *B4TaxAmt;
@property (strong, nonatomic) NSString *TaxAmt;
@property (strong, nonatomic) NSString *Param6;
@property (strong, nonatomic) NSString *Param7;
@end

@interface PaymentRespPARAM : NSObject
@property (strong, nonatomic) NSString *Amount;
@property (strong, nonatomic) NSString *AuthCode;
@property (strong, nonatomic) NSString *BankRefNo;

@property (strong, nonatomic) NSString *CardExp;
@property (strong, nonatomic) NSString *CardHolder;
@property (strong, nonatomic) NSString *CardNoMask;
@property (strong, nonatomic) NSString *CardType;

@property (strong, nonatomic) NSString *CurrencyCode;
@property (strong, nonatomic) NSString *HashValue;
@property (strong, nonatomic) NSString *HashValue2;

@property (strong, nonatomic) NSString *IssuingBank;

@property (strong, nonatomic) NSString *OrderNumber;
@property (strong, nonatomic) NSString *PaymentID;
@property (strong, nonatomic) NSString *PymtMethod;
@property (strong, nonatomic) NSString *QueryDesc;

@property (strong, nonatomic) NSString *ServiceID;
@property (strong, nonatomic) NSString *SessionID;

@property (strong, nonatomic) NSString *TotalRefundAmount;

@property (strong, nonatomic) NSString *TransactionType;
@property (strong, nonatomic) NSString *TxnExists;
@property (strong, nonatomic) NSString *TxnID;
@property (strong, nonatomic) NSString *TxnMessage;
@property (strong, nonatomic) NSString *TxnStatus;

@property (strong, nonatomic) NSString *TokenType;
@property (strong, nonatomic) NSString *Token;
@end

@protocol eGHLDetegate <NSObject>
- (void)QueryResult:(PaymentRespPARAM *)result;
@end

typedef void (^onPaymentRequest)(PaymentRequestPARAM* RequestData);
typedef void (^onPaymentResp)(PaymentRespPARAM* ParamData);
typedef void (^onSuccessResp)(NSString* SuccessData);
typedef void (^onErrorCB)(NSString* errorCode,NSString* errorData);

@interface EGHLPayment : UIView<UIWebViewDelegate>

@property (nonatomic, assign) id <eGHLDetegate> delegate;

/**
*   @method  EGHLRequestSale:(PaymentRequestPARAM *)paymentparam successBlock:(onSuccessResp)successRequestCB failedBlock:(onErrorCB)failedCB
*
*   @param   paymentparam   A <code>paymentparam</code> object.
*                           include Amount,PaymentID,OrderNumber,MerchantName,ServiceID,PymtMethod,MerchantReturnURL,CustEmail,Password,CustPhone,
*                                   CurrencyCode,CustName,LanguageCode,PaymentDesc,PageTimeout,CustIP,MerchantApprovalURL,CustMAC,MerchantUnApprovalURL,CardHolder,
*                                   CardNo,CardExp,CardCVV2,BillAddr,ShipPostal,ShipCity,ShipRegion,ShipCountry,TokenType,Token,
*                                   SessionID,IssuingBank,MerchantCallBackURL,B4TaxAmt,TaxAmt,Param6,Param7.
*   @param   successRequestCB  A success block.
*   @param   failedCB          A fail block.
*   @discussion    start enter to sale payment page and perform an online payment transaction.
*/
- (void)EGHLRequestSale:(PaymentRequestPARAM *)paymentparam successBlock:(onSuccessResp)successRequestCB failedBlock:(onErrorCB)failedCB;


/*
 *   @method  EGHLRequestQuery:(PaymentRequestPARAM *)paymentparam successBlock:(onSuccessResp)successRequestCB failedBlock:(onErrorCB)failedCB
 *
 *   @param   PaymentPARAMCB   A <code>PaymentPARAMCB</code> object.
 *                           include TransactionType,PymtMethod,ServiceID,PaymentID,Amount,CurrencyCode.
 *   @param   successRequestCB  A success block.
 *   @param   failedCB          A fail block.
 *   @discussion    query payment status.
 */
- (void)EGHLRequestQuery:(PaymentRequestPARAM *)PaymentPARAMCB successBlock:(onPaymentResp)successAnalyCB failedBlock:(onErrorCB)failedCB;

/**
 *   @method  EGHLRequestReversal:(PaymentRequestPARAM *)PaymentPARAMCB successBlock:(onPaymentResp)successAnalyCB failedBlock:(onErrorCB)failedCB
 *
 *   @param   PaymentPARAMCB   A <code>PaymentPARAMCB</code> object.
 *                           include TransactionType,PymtMethod,ServiceID,PaymentID,Amount,CurrencyCode.
 *   @param   successRequestCB  A success block.
 *   @param   failedCB          A fail block.
 *   @discussion    reverse the original sale/payment.
 */
- (void)EGHLRequestReversal:(PaymentRequestPARAM *)PaymentPARAMCB successBlock:(onPaymentResp)successAnalyCB failedBlock:(onErrorCB)failedCB;

/*
 *   @method  EGHLRequestRefund:(PaymentRequestPARAM *)PaymentPARAMCB successBlock:(onPaymentResp)successAnalyCB failedBlock:(onErrorCB)failedCB
 *
 *   @param   PaymentPARAMCB   A <code>PaymentPARAMCB</code> object.
 *                           include TransactionType,PymtMethod,ServiceID,PaymentID,Amount,CurrencyCode.
 *   @param   successRequestCB  A success block.
 *   @param   failedCB          A fail block.
 *   @discussion    refund the original sale/payment.
 */
- (void)EGHLRequestRefund:(PaymentRequestPARAM *)PaymentPARAMCB successBlock:(onPaymentResp)successAnalyCB failedBlock:(onErrorCB)failedCB;

/*
 *   @method  EGHLRequestCapture:(PaymentRequestPARAM *)PaymentPARAMCB successBlock:(onPaymentResp)successAnalyCB failedBlock:(onErrorCB)failedCB
 *
 *   @param   PaymentPARAMCB   A <code>PaymentPARAMCB</code> object.
 *                           include TransactionType,PymtMethod,ServiceID,PaymentID,Amount,CurrencyCode.
 *   @param   successRequestCB  A success block.
 *   @param   failedCB          A fail block.
 *   @discussion    capture the original authorization transaction.
 */
- (void)EGHLRequestCapture:(PaymentRequestPARAM *)PaymentPARAMCB successBlock:(onPaymentResp)successAnalyCB failedBlock:(onErrorCB)failedCB;

/*
 *   @method  SaleViewStopLoad
 *
 *   @discussion    exit payment page.
 */
- (void)SaleViewStopLoad;

@end
