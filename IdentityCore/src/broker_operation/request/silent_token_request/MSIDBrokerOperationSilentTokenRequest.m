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

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000 && !MSID_EXCLUDE_WEBKIT
#import <AuthenticationServices/ASAuthorizationOpenIDRequest.h>
#import "MSIDBrokerOperationSilentTokenRequest.h"
#import "MSIDJsonSerializableFactory.h"
#import "MSIDConstants.h"
#import "MSIDAccountIdentifier.h"
#import "MSIDRequestParameters.h"
#import "MSIDJsonSerializableTypes.h"

@implementation MSIDBrokerOperationSilentTokenRequest

+ (void)load
{
    [MSIDJsonSerializableFactory registerClass:self forClassType:self.operation];
}

+ (instancetype)tokenRequestWithParameters:(MSIDRequestParameters *)parameters
                              providerType:(MSIDProviderType)providerType
                                     error:(NSError **)error
{
    __auto_type request = [MSIDBrokerOperationSilentTokenRequest new];
    BOOL result = [self fillRequest:request withParameters:parameters providerType:providerType error:error];
    if (!result) return nil;
    
    request.accountIdentifier = parameters.accountIdentifier;
    
    return request;
}

#pragma mark - MSIDBrokerOperationRequest

+ (NSString *)operation
{
    return ASAuthorizationOperationRefresh;
}

#pragma mark - MSIDJsonSerializable

- (instancetype)initWithJSONDictionary:(NSDictionary *)json error:(NSError **)error
{
    self = [super initWithJSONDictionary:json error:error];
    
    if (self)
    {
        _accountIdentifier = [[MSIDAccountIdentifier alloc] initWithJSONDictionary:json error:error];
        if (!_accountIdentifier)
        {
            MSID_LOG_WITH_CORR(MSIDLogLevelError, self.correlationId, @"Failed to create json for %@ class, accountIdentifier is nil.", self.class);
            return nil;
        }
    }
    
    return self;
}

- (NSDictionary *)jsonDictionary
{
    NSMutableDictionary *json = [[super jsonDictionary] mutableCopy];
    if (!json) return nil;
    
    NSDictionary *accountIdentifierJson = [self.accountIdentifier jsonDictionary];
    if (!accountIdentifierJson) return nil;
    
    [json addEntriesFromDictionary:accountIdentifierJson];
    
    return json;
}

@end
#endif
