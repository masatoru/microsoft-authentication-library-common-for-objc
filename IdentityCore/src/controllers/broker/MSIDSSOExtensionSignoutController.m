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

#if MSID_ENABLE_SSO_EXTENSION

#import "MSIDSSOExtensionSignoutController.h"
#import "MSIDSSOExtensionSignoutRequest.h"
#import "MSIDInteractiveRequestParameters.h"
#import "ASAuthorizationSingleSignOnProvider+MSIDExtensions.h"

@interface MSIDSSOExtensionSignoutController()

@property (nonatomic) MSIDSSOExtensionSignoutRequest *currentSSORequest;

@end

@implementation MSIDSSOExtensionSignoutController

- (void)executeRequestWithCompletion:(MSIDSignoutRequestCompletionBlock)completionBlock
{
    if (!completionBlock) return;
    
    self.currentSSORequest = [[MSIDSSOExtensionSignoutRequest alloc] initWithRequestParameters:self.parameters
                                                                      shouldSignoutFromBrowser:NO
                                                                                  oauthFactory:self.factory];
        
    [self.currentSSORequest executeRequestWithCompletion:^(BOOL success, NSError * _Nullable error) {
        
        self.currentSSORequest = nil;
        
        if (!success)
        {
            MSID_LOG_WITH_CTX_PII(MSIDLogLevelError, self.parameters, @"Failed to perform SSO extension signout request with error %@", MSID_PII_LOG_MASKABLE(error));
            completionBlock(success, error);
            return;
        }
        
        [super executeRequestWithCompletion:completionBlock];
    }];
}

+ (BOOL)canPerformRequest
{
    return [[ASAuthorizationSingleSignOnProvider msidSharedProvider] canPerformAuthorization];
}

@end

#endif