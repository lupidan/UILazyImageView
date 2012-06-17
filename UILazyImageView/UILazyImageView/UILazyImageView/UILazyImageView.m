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

#import "UILazyImageView.h"
#import "NSData+HashMD5.h"

/**
	The name of the folder in the temp folder to store the image cache
 */
#define UILazyImageViewCacheFolder @"UILazyImageViewCache"

@interface UILazyImageView ()

/**
	This method returns the path of the cache folder
	@returns The path of the cache folder
 */
+ (NSString*) getCacheFolder;
/**
	Checks if the image cache folder exists
	@returns YES if it exists, NO otherwise
 */
+ (BOOL) imageCacheFolderExists;
/**
	Method to delete the cache folder if it exists
 */
+ (void) deleteImageCacheFolder;
/**
	Method to create the cache folder, if it does not exist
 */
+ (void) createImageCacheFolder;
/**
	Method to get the unique filename to store an image with an URL
	@param url The url containing the file
	@returns The string with the file path where the image data will be cached
 */
+ (NSString*) getFilenameForCacheEntryWithURL:(NSURL*)url;
/**
	Get the cached image data for an url
	@param url The image url
	@returns the cached data or nil if no data is found 
 */
+ (NSData*) getCachedImageDataForURL:(NSURL*)url;
/**
	Updates the cache by adding a file for a certain url with the downloaded data
	@param url The url of the image
	@param data The data to store
 */
+ (void) updateCacheForURL:(NSURL*)url withDownloadedData:(NSData*)data;




/**
	The progress view to show up when the image is being downloaded
 */
@property (nonatomic,retain) UIProgressView * progressView;
/**
	The main request to ask for the image data
 */
@property (nonatomic,retain) NSURLRequest * imageRequest;
/**
	The connection in charge of downloading the image data
 */
@property (nonatomic,retain) NSURLConnection * imageRequestConnection;
/**
	The cumulative data structure, at the end of the request, it will contain the full image data
 */
@property (nonatomic,retain) NSMutableData * downloadedImage;
/**
	The number of downloaded bytes
 */
@property (nonatomic,assign) NSUInteger downloadedByteCount;
/**
	The expected number of bytes to download for the request
 */
@property (nonatomic,assign) NSUInteger expectedByteCount;





/**
	Common init for all the init methods
 */
- (void) lazyImageViewInit;
/**
	This method cancels any previous connection, and starts a new download if the imageURL is not nil
    @param imageURL the URL containing the image
 */
- (void) startDownloading:(NSURL*)imageURL;
/**
	This method is executed in the main thread when the connection fails the download
 */
- (void) downloadDidFail;
/**
	This method is executed in the main thread when the connection sucess the download
    @param downloadedImage The downloaded image
 */
- (void) downloadDidSuccess:(UIImage*)downloadedImage;
/**
	This method is executed in the main thread, it updates the progress bar value
 */
- (void) updateProgressBar;
/**
	Starts loading the data in the background thread by attempting to get the data from cache. If not cached, download starts in main thread
    @param imageURL the URL containing the image
 */
- (void) loadDataInBackground:(NSURL*)imageURL;


@end







@implementation UILazyImageView
@synthesize imageURL = _imageURL;
@synthesize progressView = _progressView;
@synthesize imageRequest = _imageRequest;
@synthesize imageRequestConnection = _imageRequestConnection;
@synthesize downloadedImage = _downloadedImage;
@synthesize downloadedByteCount = _downloadedByteCount;
@synthesize expectedByteCount = _expectedByteCount;


#pragma mark - Static class members and methods

/**
 * The string containing the folder where we will store the images
 */
static NSString * cacheFolder;

+ (NSString*) getCacheFolder{
    if (!cacheFolder)
        cacheFolder = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), UILazyImageViewCacheFolder];
    return cacheFolder;
}



+ (BOOL) imageCacheFolderExists{
    //Delete the main folder if it exists
    NSFileManager * fm = [NSFileManager defaultManager];
    return [fm fileExistsAtPath:[self getCacheFolder]];
}



+ (void) deleteImageCacheFolder{
    
    //Delete the main folder if it exists
    NSFileManager * fm = [NSFileManager defaultManager];
    NSError * error = nil;
    if ([self imageCacheFolderExists]){
        if (![fm removeItemAtPath:[self getCacheFolder] error:&error]){
            NSLog(@"UILazyImageViewCache: ERROR when deleting main folder %@", error.description);
        }
    }
    
    
}


+ (void) createImageCacheFolder{
    //Create the folder
    NSFileManager * fm = [NSFileManager defaultManager];
    NSError * error = nil;
    if (![self imageCacheFolderExists]){
        if (![fm createDirectoryAtPath:[self getCacheFolder] withIntermediateDirectories:YES attributes:nil error:&error]){
            NSLog(@"UILazyImageViewCache: ERROR when creating main folder %@", error.description);
        }
    }
    
}


+ (NSString*) getFilenameForCacheEntryWithURL:(NSURL*)url{
    //Get url MD5
    NSString * urlMD5 = [[url.absoluteString dataUsingEncoding:NSUTF8StringEncoding] hashMD5String];
    //Get the filename
    NSString * filePath = [NSString stringWithFormat:@"%@/%@",[self getCacheFolder],urlMD5];
    return filePath;
}


+ (NSData*) getCachedImageDataForURL:(NSURL*)url{
    
    //If file exists with this hash as filename, return the data asociated
    NSFileManager * fm = [NSFileManager defaultManager];
    return [fm contentsAtPath:[self getFilenameForCacheEntryWithURL:url]];
    
}



+ (void) updateCacheForURL:(NSURL*)url withDownloadedData:(NSData*)data{
    
    //First create if needed the image cache folder
    [self createImageCacheFolder];
    
    //Save data in file
    NSFileManager * fm = [NSFileManager defaultManager];
    if (![fm createFileAtPath:[self getFilenameForCacheEntryWithURL:url] contents:data attributes:nil]){
        NSLog(@"UILazyImageViewCache: ERROR when creating file at %@", [self getFilenameForCacheEntryWithURL:url]);
    }
    
}

+ (void) clearCache{
    //Delete folder and create it again
    [self deleteImageCacheFolder];
    [self createImageCacheFolder];
}

+ (void) clearsCacheEntryForURL:(NSURL*)url{
    
    //Just delete the file
    NSFileManager * fm = [NSFileManager defaultManager];
    NSError * error = nil;
    if (![fm removeItemAtPath:[self getFilenameForCacheEntryWithURL:url] error:&error]){
        NSLog(@"UILazyImageViewCache: ERROR when deleting cache entry for %@ %@", [self getFilenameForCacheEntryWithURL:url], error.description);
    }

}















#pragma mark - Init and Dealloc methods

- (id) init{
    self = [super init];
    if (self){
        [self lazyImageViewInit];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self lazyImageViewInit];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self lazyImageViewInit];
    }
    return self;
}

- (id) initWithImage:(UIImage *)image{
    self = [super initWithImage:image];
    if (self){
        [self lazyImageViewInit];
    }
    return self;
}

- (id) initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage{
    self = [super initWithImage:image highlightedImage:highlightedImage];
    if (self){
        [self lazyImageViewInit];
    }
    return self;
}


- (void) lazyImageViewInit{
    
    //Progress view
    UIProgressView * tempProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    [tempProgressView setHidden:YES];
    self.progressView = tempProgressView;
    [tempProgressView release];
    
    //Add to view
    [self addSubview:self.progressView];
    
    //Set view interaction
    [self setUserInteractionEnabled:YES];
    
}

- (void) dealloc{
    [_imageURL release];
    [_progressView release];
    [_imageRequest release];
    [_imageRequestConnection release];
    [_downloadedImage release];
    
    [super dealloc];
}











#pragma mark - Overrides

- (void) setImageURL:(NSURL *)imageURL{
    [_imageURL release];
    _imageURL = nil;
    _imageURL = [imageURL retain];
    
    //Clear image
    self.image = nil;
    //If we have a new image URL
    if (self.imageURL){
        
        //Reset progress bar
        self.downloadedByteCount = 0;
        self.expectedByteCount = 0;
        
        //Update progress bar
        [self updateProgressBar];
        [self.progressView setHidden:NO];
        
        //Cancel previous request if needed
        [self.imageRequestConnection cancel];
        
        //Load data in background
        [self performSelectorInBackground:@selector(loadDataInBackground:) withObject:self.imageURL];
        
        
    }
    
}




- (void) layoutSubviews{
    [super layoutSubviews];
    
    //Set frame of progress view
    CGFloat rightMargin = 20.0;
    CGFloat leftMargin = 20.0;
    CGFloat width = self.frame.size.width - leftMargin - rightMargin;
    CGFloat height = 10.0;
    CGFloat yPos = self.center.y - (height / 2.0);
    if (width < 0)
        width = 0;
    self.progressView.frame = CGRectMake(leftMargin, yPos, width, height);
    
    
}











#pragma mark - Private methods
- (void) updateProgressBar{
    if (self.expectedByteCount > 0)
        [self.progressView setProgress: ((CGFloat)self.downloadedByteCount/(CGFloat)self.expectedByteCount)];
    else
        [self.progressView setProgress:0.0f];
}



- (void) loadDataInBackground:(NSURL*)imageURL{
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    //Get cached data in background
    NSData * cachedData = [UILazyImageView getCachedImageDataForURL:imageURL];
    //If we don't have cached data, start downloading
    if (!cachedData){
        [self performSelectorOnMainThread:@selector(startDownloading:) withObject:imageURL waitUntilDone:YES];
    }
    //Else, if we have cached data, set as main
    else{
        //Create image with cached data
        UIImage * cachedImage = [UIImage imageWithData:cachedData];
        //If data is nil, remove it from the cache folder and retry the download
        if (!cachedImage){
            [UILazyImageView clearsCacheEntryForURL:imageURL];
            [self performSelectorOnMainThread:@selector(startDownloading:) withObject:imageURL waitUntilDone:YES];
        }
        else{
            [self performSelectorOnMainThread:@selector(downloadDidSuccess:) withObject:cachedImage waitUntilDone:YES];
        }
    }
    
    [pool drain];
    
}



- (void) startDownloading:(NSURL*)imageURL{
    
    //Start new request
    self.imageRequest = [NSURLRequest requestWithURL:imageURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60.0];
    self.imageRequestConnection = [NSURLConnection connectionWithRequest:self.imageRequest delegate:self];
    
}

- (void) downloadDidSuccess:(UIImage*)downloadedImage{
    
    //Update progres bar
    [self updateProgressBar];
    //Set image
    self.image = downloadedImage;
    //Clear memory
    self.imageRequest = nil;
    self.imageRequestConnection = nil;
    self.downloadedImage = nil;
    //Hide progress bar
    [self.progressView setHidden:YES];
}


- (void) downloadDidFail{
    //Clear image
    [self setImage:nil];
    //Hide progress bar
    [self.progressView setHidden:NO];
}



 










#pragma mark - Url Connection Data Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    //Only continue if the connection is the same
    if (self.imageRequestConnection == connection){
        
        //If we are going to start a request, clear received data
        NSMutableData * newData = [[NSMutableData alloc] init];
        self.downloadedImage = newData;
        [newData release];
        
        //Keep the number of bytes we are going to receive, and reset the counter
        self.expectedByteCount = [response expectedContentLength];
        self.downloadedByteCount = 0;
        
    }
    
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    //Only continue if the connection is the same
    if (self.imageRequestConnection == connection){
        //Append the new data
        [self.downloadedImage appendData:data];
        //Update downloaded bytes
        self.downloadedByteCount += data.length;
        //Update progress bar in front view
        [self performSelectorOnMainThread:@selector(updateProgressBar) withObject:nil waitUntilDone:YES];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    //Only continue if the connection is the same
    if (self.imageRequestConnection == connection){
        //Update cache
        [UILazyImageView updateCacheForURL:self.imageURL withDownloadedData:self.downloadedImage];
        //Image was donwloaded, so set new image
        UIImage * downloadedImage = [UIImage imageWithData:self.downloadedImage];
        if (downloadedImage)
            //Update UI
            [self performSelectorOnMainThread:@selector(downloadDidSuccess:) withObject:downloadedImage waitUntilDone:YES];
        else
            //Update UI
            [self performSelectorOnMainThread:@selector(downloadDidFail) withObject:nil waitUntilDone:YES];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    //Only continue if the connection is the same one
    if (self.imageRequestConnection == connection){
        //Hide progress bar
        [self performSelectorOnMainThread:@selector(downloadDidFail) withObject:nil waitUntilDone:YES];
    }
}




@end
