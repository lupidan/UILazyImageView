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

#import <Foundation/Foundation.h>

/**
	This class defines a lazy image view cache. It uses the default tmp folder to store images downloaded by UILazyImageView, and uses this data if available to avoid downloading image data from the web again. Files are stored in a folder and the name for each file is the hash of the image data.
 */
@interface UILazyImageViewCache : NSObject

/**
	This method gives the user the cache singleton object. Users should refer to this member to access the image cache
	@returns The UILazyImageViewCache singleton
 */
+ (UILazyImageViewCache*) sharedCache;

/**
	Returns cached data for an image URL
	@param url The URL that contains the image data
	@returns The associated NSData in the tmp directory
 */
- (NSData*) getCachedImageDataForURL:(NSURL*)url;

/**
	Updates the cache entry for an image URL with a downloaded data. The data is stored in the default tmp directory and the reference is saved in a internal dictionary
	@param url The URL containing the image
	@param data The data obtained for that URL
 */
- (void) updateCacheEntryForURL:(NSURL*)url withDownloadedData:(NSData*)data;

/**
	Clears the whole cache
 */
- (void) clearCache;

/**
	Clears the cache entry for an specific URL
	@param url The URL containing the image to clear the cache entry
 */
- (void) clearsCacheEntryForURL:(NSURL*)url;

@end
