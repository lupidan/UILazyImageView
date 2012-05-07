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


@interface UILazyImageViewCache ()

@property (nonatomic,retain) NSMutableDictionary * fileDictionary;
@property (nonatomic,retain) NSString * imageStorageRoot;

- (void) deleteImageStorageFolder;
- (void) createImageStorageFolder;

@end



@implementation UILazyImageViewCache
@synthesize fileDictionary = _fileDictionary;
@synthesize imageStorageRoot = _imageStorageRoot;

static UILazyImageViewCache * sharedCache;

+ (UILazyImageViewCache*) sharedCache{
    if (!sharedCache)
        sharedCache = [[UILazyImageViewCache alloc] init];
    
    return sharedCache;
}


- (id) init{
    self = [super init];
    if (self){
        self.fileDictionary = [NSMutableDictionary dictionary];
        self.imageStorageRoot = [NSString stringWithFormat:@"%@lazyImageViewCache",NSTemporaryDirectory()];
        [self clearCache];
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
    NSString * filePath = [self.fileDictionary objectForKey:url.absoluteURL];
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
    
    //Prepares filename
    NSString * saveFilename = [NSString stringWithFormat:@"%d",[data hash]];
    NSString * saveFilePath = [NSString stringWithFormat:@"%@/%@", self.imageStorageRoot, saveFilename];
    
    //Create file
    NSFileManager * fm = [NSFileManager defaultManager];
    if (![fm createFileAtPath:saveFilePath contents:data attributes:nil]){
        NSLog(@"UILazyImageViewCache: ERROR when creating file at %@", saveFilePath);
    }
    
    NSLog(@"Saved file %@", saveFilePath);
    
    //Save in dictionary
    [self.fileDictionary setObject:saveFilePath forKey:url.absoluteURL];

}


- (void) clearCache{
    //Delete folder and create it again
    [self deleteImageStorageFolder];
    [self createImageStorageFolder];
}






@end
