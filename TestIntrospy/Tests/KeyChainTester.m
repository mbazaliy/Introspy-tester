#import "KeyChainTester.h"
#include <Security/Security.h>

@implementation KeyChainTester : NSObject 


// Testing settings
static NSString *keyChainTestKey = @"IntrospyPassword";
static NSString *keyChainTestValue1 = @"s3cr3t";
static NSString *keyChainTestValue2 = @"p@ssw0rd";



+ (void)runAllTests {

    [self testKeyChain];
    [self testSecPKCS12Import];
}


// Utility function for the keyChain tests
+ (NSMutableDictionary *)newKeyChainSearchDict {

    NSString *appId = [[NSBundle mainBundle] bundleIdentifier];
    NSData *testKey = [keyChainTestKey dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];

    [searchDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    [searchDictionary setObject:testKey forKey:(__bridge id)kSecAttrGeneric];
    [searchDictionary setObject:testKey forKey:(__bridge id)kSecAttrAccount];
    [searchDictionary setObject:appId forKey:(__bridge id)kSecAttrService];

  return searchDictionary;
}


+ (void)testKeyChain {
    
    NSData *testValue1 = [keyChainTestValue1 dataUsingEncoding:NSUTF8StringEncoding];
    NSData *testValue2 = [keyChainTestValue2 dataUsingEncoding:NSUTF8StringEncoding];

    // Test SecItemAdd()
    NSMutableDictionary *itemAddDict = [self newKeyChainSearchDict];
    [itemAddDict setObject:testValue1 forKey:(__bridge id)kSecValueData];
    [itemAddDict setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];
    SecItemAdd((__bridge CFDictionaryRef)itemAddDict, NULL);

    // Test SecItemAdd() with default kSecAttrAccessible
    NSMutableDictionary *itemAddDict2 = [self newKeyChainSearchDict];
    [itemAddDict2 setObject:testValue1 forKey:(__bridge id)kSecValueData];
    //[itemAddDict setObject:(id)kSecAttrAccessibleWhenUnlocked forKey:(id)kSecAttrAccessible];
    SecItemAdd((__bridge CFDictionaryRef)itemAddDict2, NULL);

    // Test SecItemCopyMatching()
    NSMutableDictionary *itemMatchDict = [self newKeyChainSearchDict];
    CFTypeRef *result=NULL;
    [itemMatchDict setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    [itemMatchDict setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    SecItemCopyMatching((__bridge CFDictionaryRef)itemMatchDict, result);

    // Test SecItemUpdate()
    NSMutableDictionary *itemSearchDict = [self newKeyChainSearchDict];
    NSMutableDictionary *itemUpdateDict = [[NSMutableDictionary alloc] init];
    [itemUpdateDict setObject:testValue2 forKey:(__bridge id)kSecValueData];
    SecItemUpdate((__bridge CFDictionaryRef) itemSearchDict, (__bridge CFDictionaryRef) itemUpdateDict);

    // Test SecItemDelete()
    SecItemDelete((__bridge CFDictionaryRef) itemSearchDict);
}


+ (void)testSecPKCS12Import {
    
    // Open the PKCS12 file
    NSString *clientCertPath = [[NSString alloc] initWithFormat:@"%@/introspy.p12", [[NSBundle mainBundle] bundlePath]];
    NSData *clientCertData = [[NSData alloc] initWithContentsOfFile:clientCertPath];

    if ([clientCertData length] == 0) {
        NSLog(@"CLIENT CERT NOT FOUND, PATH:%@", clientCertPath);
    }
    else {
        const void *keys[] =   { kSecImportExportPassphrase };
        const void *values[] = { (CFStringRef) @"test" };
        CFDictionaryRef optionsDictionary = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
        CFArrayRef items = NULL;
        
        // Load the client cert and private key
        if (SecPKCS12Import((__bridge CFDataRef) clientCertData, optionsDictionary, &items) == 0) {

            SecIdentityRef clientIdentity;
            CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex (items, 0);
            clientIdentity = (SecIdentityRef) CFDictionaryGetValue(myIdentityAndTrust, kSecImportItemIdentity);
        
            // Print the cert's summary
            SecCertificateRef clientCertRef;
            SecIdentityCopyCertificate(clientIdentity, &clientCertRef);
            NSString *clientCertSummary = (__bridge NSString*) SecCertificateCopySubjectSummary(clientCertRef);
            NSLog(@"LOADED CERT: %@", clientCertSummary);
            CFRelease(clientCertRef);

            // Store the cert and private key (twice) in the keychain with kSecAttrAccessibleAlways
            NSMutableDictionary *certAddDict = [self newKeyChainSearchDict];
            [certAddDict setObject:(__bridge id)kSecClassIdentity forKey:(__bridge id)kSecClass];
            [certAddDict setObject:(__bridge id)clientIdentity forKey:(__bridge id)kSecValueRef];
            [certAddDict setObject:(__bridge id)kSecAttrAccessibleAlways forKey:(__bridge id)kSecAttrAccessible];
            SecItemAdd((__bridge CFDictionaryRef)certAddDict, NULL);

            NSMutableDictionary *certAddDict2 = [self newKeyChainSearchDict];
            [certAddDict2 setObject:(__bridge id)kSecClassIdentity forKey:(__bridge id)kSecClass];
            [certAddDict2 setObject:(__bridge id)kSecAttrAccessibleAlways forKey:(__bridge id)kSecAttrAccessible];
            [certAddDict2 setObject:(__bridge id)clientIdentity forKey:(__bridge id)kSecValuePersistentRef];
            SecItemAdd((__bridge CFDictionaryRef)certAddDict, NULL);

            // Update the cert and private key - code will not work but we're only testing the hook
            SecItemUpdate((__bridge CFDictionaryRef) [self newKeyChainSearchDict], (__bridge CFDictionaryRef) certAddDict);
        }

        if (optionsDictionary)
            CFRelease(optionsDictionary);

        if (items)
            CFRelease(items);
    }
}

@end
