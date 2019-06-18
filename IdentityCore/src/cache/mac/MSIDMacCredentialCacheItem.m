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


#import "MSIDMacCredentialCacheItem.h"

static NSString *keyDelimiter = @"-";

@interface MSIDMacCredentialCacheItem ()

@property (nonatomic) NSMutableDictionary *cacheObjects;
@property (nonatomic) dispatch_queue_t queue;

@end

@implementation MSIDMacCredentialCacheItem

- (instancetype)init
{
    if(self = [super init])
    {
        self.cacheObjects = [NSMutableDictionary dictionary];
        NSString *queueName = [NSString stringWithFormat:@"com.microsoft.universalstorage-%@", [NSUUID UUID].UUIDString];
        self.queue = dispatch_queue_create([queueName cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_CONCURRENT);
    }
    
    return self;
}

- (void)setCredential:(MSIDCredentialCacheItem *)token forKey:(NSString *)key
{
    dispatch_barrier_async(self.queue, ^{
        [self.cacheObjects setObject:token forKey:key];
    });
}

-(MSIDCredentialCacheItem *)credentialForKey:(NSString *)key
{
    __block MSIDCredentialCacheItem *appCredential = nil;
    
    dispatch_sync(self.queue, ^{
        appCredential = [self.cacheObjects objectForKey:key];
    });
    
    return appCredential;
}

- (void)removeCredentialForKey:(NSString *)key
{
    dispatch_barrier_async(self.queue, ^{
        [self.cacheObjects removeObjectForKey:key];
    });
}

- (void)mergeCredential:(MSIDMacCredentialCacheItem *)credential
{
    NSArray *keys = [credential allKeys];
    for (NSString *key in keys)
    {
        if (![self credentialForKey:key])
        {
            MSIDCredentialCacheItem *item = [credential.cacheObjects objectForKey:key];
            if (item)
            {
                [self setCredential:item forKey:key];
            }
        }
    }
}

- (NSArray<MSIDCredentialCacheItem *> *)credentialsWithKey:(MSIDDefaultCredentialCacheKey *)key
{
    if (key.account && key.service)
    {
        NSString *tokenKey = [NSString stringWithFormat:@"%@%@%@", key.account, keyDelimiter, key.service];
        MSIDCredentialCacheItem *credential = [self credentialForKey:tokenKey];
        if (credential)
        {
            return @[credential];
        }
        
        return nil;
    }
    
    NSMutableArray *subPredicates = [[NSMutableArray alloc] init];
    
    /*
     Refresh token either has family Id as 1 or nil.
     For app refresh token, we pass family id as nil which matches both FRT and RT instead of matching just RT
     For clients that are not part of family, family is saved as empty string and added to refresh token query.
     */
    if ([NSString msidIsStringNilOrBlank:key.familyId])
    {
        key.familyId = nil;
    }

    [subPredicates addObject:[NSPredicate predicateWithFormat:@"self.familyId == %@", key.familyId]];
    if (key.clientId)
        [subPredicates addObject:[NSPredicate predicateWithFormat:@"self.clientId == %@", key.clientId]];
    if (key.environment)
        [subPredicates addObject:[NSPredicate predicateWithFormat:@"self.environment == %@", key.environment]];
    if (key.homeAccountId)
        [subPredicates addObject:[NSPredicate predicateWithFormat:@"self.homeAccountId == %@", key.homeAccountId]];
    if (key.credentialType)
        [subPredicates addObject:[NSPredicate predicateWithFormat:@"self.credentialType == %d", key.credentialType]];
    if (key.realm)
        [subPredicates addObject:[NSPredicate predicateWithFormat:@"self.realm == %@", key.realm]];
    /*
     key.target is not added as target can be subset , intersect , superset or exact string match and is matched later in the code.
     */
    
    // Combine all sub-predicates with AND:
    NSPredicate *matchAttributes = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
    
    NSArray *tokens = [self allValues];
    NSArray *filteredTokens = [tokens filteredArrayUsingPredicate:matchAttributes];
    return filteredTokens;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)json
                                 error:(NSError * __autoreleasing *)error
{
    if (!(self = [self init]))
    {
        return nil;
    }
    
    for (NSString *tokenKey in json)
    {
        NSDictionary *rtDict = [json objectForKey:tokenKey];
        
        if (rtDict)
        {
            MSIDCredentialCacheItem *appToken = [[MSIDCredentialCacheItem alloc] initWithJSONDictionary:rtDict error:error];
            
            if (appToken)
            {
                [self setCredential:appToken forKey:tokenKey];
            }
        }
    }
    
    return self;
}

- (NSDictionary *)jsonDictionary
{
    NSArray *cacheKeys = [self allKeys];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    for (NSString *appTokenKey in cacheKeys)
    {
        MSIDCredentialCacheItem *appToken = [self credentialForKey:appTokenKey];
        if (appToken)
        {
            NSDictionary *atDict = [appToken jsonDictionary];
            
            if (atDict)
            {
                [dictionary setObject:atDict forKey:appTokenKey];
            }
        }
    }
    
    return dictionary;
}

- (NSArray *)allKeys
{
    __block NSArray *keys;
    /* make your READs sychronous */
    dispatch_sync(self.queue, ^{
        keys = [self.cacheObjects allKeys];
    });
    
    return keys;
}

- (NSArray *)allValues
{
    __block NSArray *values;
    /* make your READs sychronous */
    dispatch_sync(self.queue, ^{
        values = [self.cacheObjects allValues];
    });
    
    return values;
}

@end
