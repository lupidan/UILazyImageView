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

#import "TableViewController.h"
#import "UILazyImageView.h"

@implementation TableViewController
@synthesize arrayOfImageURL;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
    

}

- (void) viewDidLoad{
    [super viewDidLoad];
    self.arrayOfImageURL = [NSArray arrayWithObjects:@"http://www.wallpapersfreebackgrounds.com/uploads/island-beautiful-beach-background-images-wallpapers_for_desktop.jpg",
                            @"http://www.macwallpapers.eu/bulkupload//Trv/afric/3//Africa/Mac%20Tourism%20Background%20Zanzibar%20Beach.jpg",
                            @"http://www.free-desktop-backgrounds.net/free-desktop-wallpapers-backgrounds/free-hd-desktop-wallpapers-backgrounds/619840535.jpg",
                            @"http://www.pptbackgrounds.net/uploads/haena-beach-kauai-hawaii-backgrounds-wallpapers.jpg",
                            @"http://2.bp.blogspot.com/-C4lhV_kw0eo/TjblAkw_ROI/AAAAAAAAAgM/Fp-MUs149TQ/s1600/beach_chair_dl.jpg",
                            @"http://cooldesktopbackgroundsx.com/wp-content/uploads/2010/07/Paradise-Beach.jpeg",
                            @"http://wallpaperskd.com/wp-content/uploads/2012/03/summer-beach-background-nature.jpg",
                            @"http://www.profilethai.com/download/original/green-bottle-on-sandy-beach-wallpaper-1920x1200.jpg",nil];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) dealloc{
    [arrayOfImageURL release];
    [super dealloc];
}

#pragma mark - View lifecycle



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.arrayOfImageURL.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        UILazyImageView * lazyImage = [[[UILazyImageView alloc] initWithFrame:cell.bounds] autorelease];
        lazyImage.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [cell addSubview:lazyImage];
    }
    
    for (UIView * view in cell.subviews){
        if ([view isKindOfClass:[UILazyImageView class]]){
            UILazyImageView * imageView = (UILazyImageView*)view;
            imageView.imageURL = [NSURL URLWithString:[self.arrayOfImageURL objectAtIndex:indexPath.row]];
        }
    }
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150.0;
}

@end
