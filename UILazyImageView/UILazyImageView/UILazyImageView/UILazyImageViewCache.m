/**
 * UILazyImageView
 *
 * Copyright 2012 Daniel Lupiañez Casares <lupidan@gmail.com>
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either 
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public 
 * License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 * 
 **/

#import "UILazyImageViewCache.h"
#import "NSData+HashMD5.h"

@interface UILazyImageViewCache ()

/**
	This dictionary contains the cached files present in the tmp directory
 */
@property (nonatomic,retain) NSMutableDictionary * fileDictionary;

/**
	This string contains the root directory for storing the images
 */
@property (nonatomic,retain) NSString * imageStorageRoot;


/**
	Delete main tmp folder
 */
- (void) deleteImageStorageFolder;

/**
	Create main tmp folder
 */
- (void) createImageStorageFolder;


@end



@implementation UILazyImageViewCache
@synthesize fileDictionary = _fileDictionary;
@synthesize imageStorageRoot = _imageStorageRoot;

#pragma mark - Class methods

static UILazyImageViewCache * sharedCache;

+ (void) initialize{
    sharedCache = [[UILazyImageViewCache alloc] init];
}

+ (UILazyImageViewCache*) sharedCache{
    return sharedCache;
}











- (id) init{
    self = [super init];
    if (self){
        self.fileDictionary = [NSMutableDictionary dictionary];
        self.imageStorageRoot = [NSString stringWithFormat:@"%@lazyImageViewCache",NSTemporaryDirectory()];
        [self clearCache];
        //NSLog(@"TMP: %@", self.imageStorageRoot);
    }
    return self;
}

- (void) dealloc{
    [_fileDictionary release];
    [_imageStorageRoot release];
    [super dealloc];
}


- (void) deleteImageStorageFolder{
    
    //Delete the main folder
    NSFileManager * fm = [NSFileManager defaultManager];
    NSError * error = nil;
    if (![fm removeItemAtPath:self.imageStorageRoot error:&error]){
        NSLog(@"UILazyImageViewCache: ERROR when deleting main folder %@", error.description);
    }
    
}

- (void) createImageStorageFolder{
    //Create the folder
    NSFileManager * fm = [NSFileManager defaultManager];
    NSError * error = nil;
    if (![fm createDirectoryAtPath:self.imageStorageRoot withIntermediateDirectories:YES attributes:nil error:&error]){
        NSLog(@"UILazyImageViewCache: ERROR when creating main folder %@", error.description);
    }
        
}





- (NSData*) getCachedImageDataForURL:(NSURL*)url{
    
    //Get filename
    NSString * filePath = [self.fileDictionary objectForKey:url.absoluteString];
    NSData * imageData = nil;
    
    //If it's not nil, get the data in that file
    if (filePath){
        //Get the data
        NSFileManager * fm = [NSFileManager defaultManager];
        imageData = [fm contentsAtPath:filePath];
    }
    
    return imageData;
}


- (void) updateCacheEntryForURL:(NSURL*)url withDownloadedData:(NSData*)data{
    
    //The url string as a data object
    NSData * urlStringData = [url.absoluteString dataUsingEncoding:NSUTF8StringEncoding];
    
    //Prepares filename with URL Hash MD5 and data hash MD5
    NSString * saveFilename = [NSString stringWithFormat:@"%@%@",[urlStringData hashMD5String],[data hashMD5String]];
    NSString * saveFilePath = [NSString stringWithFormat:@"%@/%@", self.imageStorageRoot, saveFilename];
    
    //Create file
    NSFileManager * fm = [NSFileManager defaultManager];
    if (![fm createFileAtPath:saveFilePath contents:data attributes:nil]){
        NSLog(@"UILazyImageViewCache: ERROR when creating file at %@", saveFilePath);
    }
    
    //Save in dictionary
    [self.fileDictionary setObject:saveFilePath forKey:url.absoluteString];

}


- (void) clearCache{
    //Delete folder and create it again
    [self deleteImageStorageFolder];
    [self createImageStorageFolder];
    //Remove all entryies in dictionary
    [self.fileDictionary removeAllObjects];
}

- (void) clearsCacheEntryForURL:(NSURL*)url{
    //Get file
    NSString * filePath = [self.fileDictionary objectForKey:url.absoluteString];
    //Remove entry for an specific URL
    if (filePath){
        
        //Delete the main file
        NSFileManager * fm = [NSFileManager defaultManager];
        NSError * error = nil;
        if (![fm removeItemAtPath:filePath error:&error]){
            NSLog(@"UILazyImageViewCache: ERROR when deleting cache entry for %@ %@", filePath, error.description);
        }
        [self.fileDictionary removeObjectForKey:url.absoluteString];
        
    }
}




@end
