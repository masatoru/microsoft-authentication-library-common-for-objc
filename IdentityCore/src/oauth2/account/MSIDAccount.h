// Copyright (c) Microsoft Corporation.
// All rights reserved.
//
// This code is licensed under the MIT License.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files(the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions :
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import "MSIDAccountType.h"
#import "MSIDJsonSerializable.h"

@class MSIDAccountCacheItem;
@class MSIDConfiguration;
@class MSIDTokenResponse;
@class MSIDClientInfo;
@class MSIDAccountIdentifier;
@class MSIDAuthority;
@class MSIDIdTokenClaims;

@interface MSIDAccount : NSObject <NSCopying, MSIDJsonSerializable>

@property (readwrite, nonatomic) MSIDAccountType accountType;
@property (readwrite, nonatomic) NSString *localAccountId;

/*
 'storageEnvironment' is used only for latter token deletion.
 We can not use 'environment' because cache item could be saved with
 'preferred authority' and it might not be equal to provided 'authority'.
 */
@property (readwrite, nonatomic) NSString *storageEnvironment;
@property (readwrite, nonatomic) NSString *environment;
@property (readwrite, nonatomic) NSString *realm;
/*
 'idTokenClaims' is used to convey corresponding the id token claims for the account.
 */
@property (readwrite, nonatomic) MSIDIdTokenClaims *idTokenClaims;

@property (readwrite, nonatomic) NSString *username;
@property (readwrite, nonatomic) NSString *givenName;
@property (readwrite, nonatomic) NSString *middleName;
@property (readwrite, nonatomic) NSString *familyName;
@property (readwrite, nonatomic) NSString *name;
@property (readwrite, nonatomic) MSIDAccountIdentifier *accountIdentifier;
@property (readwrite, nonatomic) MSIDClientInfo *clientInfo;
@property (readwrite, nonatomic) NSString *alternativeAccountId;

- (instancetype)initWithAccountCacheItem:(MSIDAccountCacheItem *)cacheItem;
- (MSIDAccountCacheItem *)accountCacheItem;
- (BOOL)isHomeTenantAccount;

@end
