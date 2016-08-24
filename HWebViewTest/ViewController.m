//
//  ViewController.m
//  HWebViewTest
//
//  Created by JuanFelix on 16/8/24.
//  Copyright © 2016年 JuanFelix. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController ()<UISearchBarDelegate,WKNavigationDelegate>
{
    WKWebView * webView;
}

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    webView = [[WKWebView alloc] init];
    //
    [webView setTranslatesAutoresizingMaskIntoConstraints:false];
    NSLayoutConstraint * left = [NSLayoutConstraint constraintWithItem:webView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint * right = [NSLayoutConstraint constraintWithItem:webView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint * top = [NSLayoutConstraint constraintWithItem:webView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint * bottom = [NSLayoutConstraint constraintWithItem:webView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.containerView addSubview:webView];
    [self.containerView addConstraints:@[left,right,top,bottom]];
    //
    
    webView.navigationDelegate = self;
    
    
    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.searchBar.text]]];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.hidden = webView.estimatedProgress >= 1;
        [self.progressView setProgress:webView.estimatedProgress animated:true];
    }
}

- (IBAction)backAction:(id)sender {
    if ([webView canGoBack]) {
        [webView goBack];
        [self.progressView setProgress:0 animated:false];
        [self.searchBar setText:[NSString stringWithFormat:@"%@",webView.backForwardList.backItem.URL]];
    }else{
        NSLog(@"May Be Pop to Root View Controller");
    }
}

- (IBAction)forwardAction:(id)sender {
    if ([webView canGoForward]) {
        [webView goForward];
        [self.progressView setProgress:0 animated:false];
        [self.searchBar setText:[NSString stringWithFormat:@"%@",webView.backForwardList.forwardItem.URL]];
    }else{
        NSLog(@"No Next Page");
    }
}

- (IBAction)reloadAction:(id)sender {
    [self.progressView setProgress:0 animated:false];
    [webView reload];
}

#pragma mark -

-(void)webView:(WKWebView *)webView1 didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"start new");
    [self.progressView setProgress:0 animated:false];
    [self.searchBar setText:[NSString stringWithFormat:@"%@",webView1.URL]];
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [self.progressView setProgress:0.0 animated:false];
}

#pragma mark -

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:true];
    return true;
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:false];
    return true;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (searchBar.text && searchBar.text.length) {
        NSString * url = [searchBar.text lowercaseString];
        if ([url hasPrefix:@"http://"]||
            [url hasPrefix:@"https://"]) {
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        }else if ([url hasPrefix:@"www."]){
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@",url]]]];
        }else{
            //NSLog(@"Invalid URL");
            [webView loadHTMLString:@"<div class=\"text\" style=\"text-align:center ;\"><h1>Invalid URL</h1></div>" baseURL:nil];
        }
        [searchBar resignFirstResponder];
    }else{
        NSLog(@"Empty...");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden{
    return true;
}

@end
