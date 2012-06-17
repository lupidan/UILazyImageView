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

#import <UIKit/UIKit.h>

/**
	This class works as a normal UIImageView, but offers also the possibility to load images from the internet asynchronously.
 */
@interface UILazyImageView : UIImageView <NSURLConnectionDataDelegate>

/**
	Set this image URL member to start downloading the image from the web
 */
@property (nonatomic,retain) NSURL * imageURL;


/**
	Clears the temp cache for all the images
 */
+ (void) clearCache;
/**
	Clears the cache entry for an URL
	@param url The url to clear the caché
 */
+ (void) clearsCacheEntryForURL:(NSURL*)url;

@end
