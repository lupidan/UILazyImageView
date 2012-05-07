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

#import "ViewController.h"

@implementation ViewController
@synthesize lazyImageView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setLazyImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [lazyImageView setImageURL:[NSURL URLWithString:@"http://www.beach-backgrounds.com/sunset-images/good-evening-ocean-side-beach-background-1920x1200.jpg"]];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)dealloc {
    [lazyImageView release];
    [super dealloc];
}
- (IBAction)button1Pressed:(id)sender {
    [lazyImageView setImageURL:[NSURL URLWithString:@"http://www.beach-backgrounds.com/sunset-images/good-evening-ocean-side-beach-background-1920x1200.jpg"]];
}

- (IBAction)button2Pressed:(id)sender {
    [lazyImageView setImageURL:[NSURL URLWithString:@"http://www.macwallpapers.eu/bulkupload//Trv/afric/3//Africa/Mac%20Tourism%20Background%20Zanzibar%20Beach.jpg"]];
}

- (IBAction)button3Pressed:(id)sender {
    [lazyImageView setImageURL:[NSURL URLWithString:@"http://www.free-desktop-backgrounds.net/free-desktop-wallpapers-backgrounds/free-hd-desktop-wallpapers-backgrounds/619840535.jpg"]];
}

- (IBAction)button4Pressed:(id)sender {
    [lazyImageView setImageURL:[NSURL URLWithString:@"http://www.pptbackgrounds.net/uploads/haena-beach-kauai-hawaii-backgrounds-wallpapers.jpg"]];
}
@end
