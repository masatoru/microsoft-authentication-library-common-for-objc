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

#import "MSIDOpenURLAction.h"
#import "MSIDAutomationTestRequest.h"
#import "MSIDAutomationTestResult.h"
#import "MSIDAutomationActionConstants.h"
#import "MSIDAutomationActionManager.h"

@implementation MSIDOpenURLAction

+ (void)load
{
    [[MSIDAutomationActionManager sharedInstance] registerAction:[MSIDOpenURLAction new]];
}

- (NSString *)actionIdentifier
{
    return MSID_AUTO_OPEN_URL_ACTION_IDENTIFIER;
}

- (BOOL)needsRequestParameters
{
    return YES;
}

- (void)performActionWithParameters:(MSIDAutomationTestRequest *)parameters
                containerController:(MSIDAutomationMainViewController *)containerController
                    completionBlock:(MSIDAutoCompletionBlock)completionBlock
{
    NSString *urlString = parameters.extraQueryParameters[@"url"];
    NSURL *url = [NSURL URLWithString:urlString];

    if (!url)
    {
        MSIDAutomationTestResult *testResult = [[MSIDAutomationTestResult alloc] initWithAction:self.actionIdentifier success:NO additionalInfo:nil];
        completionBlock(testResult);
        return;
    }

    [[NSWorkspace sharedWorkspace] openURL:url];

    MSIDAutomationTestResult *testResult = [[MSIDAutomationTestResult alloc] initWithAction:self.actionIdentifier success:YES additionalInfo:nil];
    completionBlock(testResult);
}

@end
