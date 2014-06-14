#import "CryptoTester.h"
#include <CommonCrypto/CommonCryptor.h>
#include <CommonCrypto/CommonHmac.h>
#include <CommonCrypto/CommonKeyDerivation.h>
#include <CommonCrypto/CommonDigest.h>


@implementation CryptoTester 


static char testKey[16] = "Key 123";
static char testIv[16] = "IVIVIVIV";
static char testData[16] = "s3cret 123";


+ (void)runAllTests {

    [self testCommonHmac];
    [self testRand];
    [self testCommonDigest];
    [self testCommonCryptor];
    [self testCommonKeyDerivation];
}


+ (void) testCommonHmac {
    char dataOut[16];
    CCHmacContext ctx;

    CCHmacInit(&ctx, kCCHmacAlgSHA1, testKey, 16);
    CCHmacUpdate(&ctx, testData, 16);
    CCHmacFinal(&ctx, dataOut);

    CCHmac(kCCHmacAlgSHA1, testKey, 16, testData, 16, dataOut);
  
    //--------------------------------------------//
    
    NSString *key = @"Key";
    NSString *data = @"Data";
    
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
}


+ (void) testRand {
    rand();
    random();
}


+ (void) testCommonDigest {
    CC_MD5_CTX ctx;
    unsigned char dataOut[CC_MD5_DIGEST_LENGTH];

    CC_MD5_Init(&ctx);
    CC_MD5_Update(&ctx, testData, 16);
    CC_MD5_Final(dataOut, &ctx);

    CC_MD5(testData, 16, dataOut);
}


+ (void) testCommonCryptor {
    CCCryptorRef cryptorRef;
    char dataOut[16];
    size_t dataOutMoved;

    CCCryptorCreateFromData(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding, 
        testKey, 16, testIv, testData, 16, &cryptorRef, &dataOutMoved);

    CCCryptorCreate(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding, 
        testKey, 16, testIv, &cryptorRef);
    CCCryptorUpdate(cryptorRef,  testData, 16, dataOut, 0, &dataOutMoved);
    CCCryptorFinal(cryptorRef, dataOut, 16, &dataOutMoved);


    CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding, testKey, 16, 
        testIv, testData, 16, dataOut, 16, &dataOutMoved);
}


+ (void) testCommonKeyDerivation {
    CCPBKDFAlgorithm algorithm = kCCPBKDF2;
    const char password[9] = "s3cretPW";
    size_t passwordLen = 9;
    const uint8_t salt[4] = "abc";
    size_t saltLen = 4; 
    CCPseudoRandomAlgorithm prf = kCCPRFHmacAlgSHA384; 
    uint rounds = 123;
    uint8_t derivedKey[33];
    size_t derivedKeyLen = 33;

    CCKeyDerivationPBKDF(algorithm, password, passwordLen, salt, saltLen, prf, rounds, derivedKey, derivedKeyLen);
}

@end
