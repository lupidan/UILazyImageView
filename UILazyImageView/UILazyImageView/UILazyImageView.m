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
#import "UILazyImageViewCache.h"

@interface UILazyImageView ()

/**
	The progress view to show up when the image is being downloaded
 */
@property (nonatomic,retain) UIProgressView * progressView;
/**
	The reload button to show up when the image download failed
 */
@property (nonatomic,retain) UIButton * reloadButton;
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
 */
- (void) startDownloading;
/**
	This method is executed in the main thread when the connection fails the download
 */
- (void) downloadDidFail;
/**
	This method is executed in the main thread when the connection sucess the download
 */
- (void) downloadDidSuccess;
/**
	This method is executed in the main thread, it updates the progress bar value
 */
- (void) updateProgressBar;

@end







@implementation UILazyImageView
@synthesize imageURL = _imageURL;
@synthesize reloadButton = _reloadButton;
@synthesize progressView = _progressView;
@synthesize imageRequest = _imageRequest;
@synthesize imageRequestConnection = _imageRequestConnection;
@synthesize downloadedImage = _downloadedImage;
@synthesize downloadedByteCount = _downloadedByteCount;
@synthesize expectedByteCount = _expectedByteCount;



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
    //To avoid div by 0
    self.expectedByteCount = 1;
    
    //Progress view
    UIProgressView * tempProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [tempProgressView setHidden:YES];
    self.progressView = tempProgressView;
    [tempProgressView release];
    
    //Button
    self.reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage * reloadImage = [UIImage imageNamed:@"uilazyimageview_reload.png"];
    self.reloadButton.frame = CGRectMake(0.0, 0.0, reloadImage.size.width, reloadImage.size.height);
    [self.reloadButton setImage:reloadImage forState:UIControlStateNormal];
    [self.reloadButton setHidden:YES];
    [self.reloadButton addTarget:self action:@selector(startDownloading) forControlEvents:UIControlEventTouchUpInside];
    
    //Add to view
    [self addSubview:self.progressView];
    [self addSubview:self.reloadButton];
    
    //Set view interaction
    [self setUserInteractionEnabled:YES];
    
}

- (void) dealloc{
    [_imageURL release];
    [_progressView release];
    [_reloadButton release];
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
    //Start downloading
    [self startDownloading];
    
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
    
    //Set frame of reload button
    CGRect buttonRect = self.reloadButton.frame;
    buttonRect.origin.x = 20.0;
    buttonRect.origin.y = 20.0;
    self.reloadButton.frame = buttonRect;
    
}





#pragma mark - Private methods

- (void) startDownloading{
    if (self.imageURL){
        
        //Reset progress bar
        self.downloadedByteCount = 0;
        self.expectedByteCount = 1;
        //Clear image
        [self setImage:nil];
        //Hide button
        [self.reloadButton setHidden:YES];
        //Update progress bar
        [self updateProgressBar];
        //Show progress bar
        [self.progressView setHidden:NO];
        
        //Cancel previous request if needed
        [self.imageRequestConnection cancel];
        
        //Get cached data
        NSData * cachedData = [[UILazyImageViewCache sharedCache] getCachedImageDataForURL:self.imageURL];
        //If we do not have cached data, start a request
        if (!cachedData){
            //Start new request
            self.imageRequest = [NSURLRequest requestWithURL:self.imageURL cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60.0];
            self.imageRequestConnection = [NSURLConnection connectionWithRequest:self.imageRequest delegate:self];
        }
        //If we have cached data,set as the download cache data, and success download
        else{
            self.downloadedImage = [NSMutableData dataWithData:cachedData];
            [self downloadDidSuccess];
        }
        

    }
}

- (void) downloadDidFail{
    //Clear image
    [self setImage:nil];
    //Show button
    [self.reloadButton setHidden:NO];
    //Hide progress bar
    [self.progressView setHidden:NO];
}

- (void) downloadDidSuccess{
    //Image was donwloaded, so set new image
    self.image = [UIImage imageWithData:self.downloadedImage];
    //Update progres bar
    [self updateProgressBar];
    //Hide progress bar
    [self.progressView setHidden:YES];
}


- (void) updateProgressBar{
    [self.progressView setProgress: ((CGFloat)self.downloadedByteCount/(CGFloat)self.expectedByteCount)];
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
        [[UILazyImageViewCache sharedCache] updateCacheEntryForURL:self.imageURL withDownloadedData:self.downloadedImage];
        //Update UI
        [self performSelectorOnMainThread:@selector(downloadDidSuccess) withObject:nil waitUntilDone:YES];
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
