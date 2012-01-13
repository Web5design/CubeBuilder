//
//  ImageCellPublic.m
//  CubeConstruct
//
//  Created by Kris Temmerman on 12/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageCellPublic.h"

#import "SaveDataModel.h"

#include <iostream>
@implementation ImageCellPublic
@synthesize image;
@synthesize actInd;

@synthesize myButton2;

@synthesize dataurl;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
      self.frame = CGRectMake(0, 0, 310, 200);
        
        image = [[UIImageView alloc] initWithFrame:CGRectMake(7, 5, 310, 310)];
        
        [self addSubview:image];
        
      // self.clipsToBounds =YES;
        
    
        myButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
        myButton2.frame = CGRectMake(0+7, +5,310, 310); // position in the parent view and set the size of the button
        [myButton2 setTitle:@"Open" forState:UIControlStateNormal];
        // add targets and actions
        
        UIImage * btnImage2 = [UIImage imageNamed:@"openBtn.png"];
        [myButton2 setImage:btnImage2 forState:UIControlStateNormal];
       //myButton2.clipsToBounds =YES;
        
        
        [myButton2 addTarget:self action:@selector(doOpen:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:myButton2];
     
        actInd  =[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        actInd.center = CGPointMake(150,150);
        [self addSubview: actInd ];
        
        self.transform = CGAffineTransformMakeRotation(-M_PI/2.0);
        
        
        self.selectedBackgroundView = [[[UIImageView alloc] init] autorelease];
       
    }
    return self;
}
-(void)  setData:(NSString *) urlImage naam:(NSString *) naam data:(NSString *) urlData;
{
    [actInd startAnimating ];
    dataurl =urlData;
    image.alpha = 0.0f;
   //image.image =  [UIImage  imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"loading" ofType:@"png"]];
    NSURL *url = [NSURL URLWithString:urlImage];
    NSLog(@"load");
    [self loadImageFromURL:url ];
myButton2.frame = CGRectMake(0+7, +5+200,310, 310);
        
    
   
    /*
    cubeID = dataID;
    NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];  
    NSString  *filePath = [NSString stringWithFormat:@"%@/%i.png", documentsDirectory,dataID];
    NSData *pngData = [NSData dataWithContentsOfFile:filePath];
    
    
   
    */
    
    
} 


- (void)doOpen:(id)sender
{
   
    
    
    NSError * e=nil;
    NSData *dataData = [NSData dataWithContentsOfURL:[NSURL  URLWithString:dataurl ] options: NSDataReadingUncached error:&e];
    if (e != nil) return;
    NSString *content = [[[NSString alloc] initWithData:dataData   encoding:NSUTF8StringEncoding] autorelease];
   NSArray *chunks = [content  componentsSeparatedByString: @" "];
    
  
    int size=chunks.count;
    int *dataCube = new int[size];
    for (int i=0;i<size ;++i)
    {
    
        int k = [(NSString *)[chunks objectAtIndex:i] intValue];
        dataCube[i] =k;
    
    }
    Model::getInstance()->setLoadData(dataCube,size);
}
- (void)loadImageFromURL:(NSURL*)url {
    
    
    
    if (connection!=nil) { [connection release];connection=nil; }
    if (data!=nil) { [data release];data=nil; }
    NSURLRequest* request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                         timeoutInterval:5.0];
    [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
    
    connection = [[NSURLConnection alloc]
                  initWithRequest:request delegate:self];
    //TODO error handling, what if connection is nil?
}

- (void)connection:(NSURLConnection *)theConnection
    didReceiveData:(NSData *)incrementalData {
    if (data==nil) {
        data =
        [[NSMutableData alloc] initWithCapacity:2048*5];
    }
    [data appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
    
    [actInd stopAnimating ];
   // [actInd setHidden:true];
    
     
    [connection release];
    connection=nil;
    
   
     image.image =  [UIImage imageWithData:data];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5f];
      [UIView setAnimationDuration:0.5f];    image.alpha = 1.0f;
   myButton2.frame = CGRectMake(0+7, +5,310, 310);
    [UIView commitAnimations];
    
    [data release];
    data=nil;
}



- (void)dealloc {
    [connection cancel];
    [connection release];
    [data release];
    [super dealloc];
}

@end