//
//  Player.m
//  Pods
//
//  Created by Thiago Pontes on 8/11/14.
//
//

#import "Player.h"

#import <AVFoundation/AVFoundation.h>
#import "PlayerView.h"
#import <CoreText/CoreText.h>

@interface Player () <UIGestureRecognizerDelegate>
{
    BOOL mediaControlIsHidden;
    BOOL shouldUpdate;
}

@property (weak, nonatomic) IBOutlet UIView *controlsOverlay;
@property (weak, nonatomic) IBOutlet UIView *scrubber;
@property (weak, nonatomic) IBOutlet UIView *scrubberCenter;
@property (weak, nonatomic) IBOutlet UIView *seekBarContainer;
@property (weak, nonatomic) IBOutlet UIView *mediaControl;
@property (weak, nonatomic) IBOutlet UIButton *playPause;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;

@property (weak, nonatomic) IBOutlet UIView *positionBar;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *positionBarConstraint;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *seekBarTap;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *seekBarDrag;

@end

@implementation Player

+ (Player*) newPlayerWithOptions: (NSDictionary*) options
{
    return [[Player alloc] initWithNibName:@"Player" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        mediaControlIsHidden = NO;
        shouldUpdate = YES;

    }

    return self;
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self syncScrubber];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _player = [AVPlayer playerWithURL: [NSURL URLWithString: @"http://www.html5rocks.com/en/tutorials/video/basics/devstories.mp4"]];
    [_playerView setPlayer: _player];

    [self setupControlsOverlay];

    [self setupScrubber];

    [self setupDuration];

    [self loadPlayerFont];

    __weak Player* weakSelf = self;

    [_player addPeriodicTimeObserverForInterval: CMTimeMake(1, 3) queue: nil usingBlock: ^(CMTime time) {
        [weakSelf.currentTimeLabel setText: [weakSelf getFormattedTime: time]];
        [weakSelf syncScrubber];
    }];

    [[NSNotificationCenter defaultCenter]
        addObserver: self
        selector: @selector(videoEnded)
        name: AVPlayerItemDidPlayToEndTimeNotification
        object: _player.currentItem];
}

- (void) videoEnded
{
    [_player seekToTime: kCMTimeZero];
    [self syncScrubber];
    _playPause.selected = !_playPause.selected;
}

- (void) setupControlsOverlay
{
    // This creates a gradient using the C API, so we don't need to update the gradient layer
    // when rotating the device
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[2] = {0.0f, 1.0f};
    CGFloat components[8] = {
        0, 0, 0, 0,
        0, 0, 0, 0.9
    };
    CGGradientRef result = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsBeginImageContext(_controlsOverlay.frame.size);
    CGContextDrawLinearGradient(UIGraphicsGetCurrentContext(), result, CGPointMake(0, 0), CGPointMake(0, _controlsOverlay.frame.size.height), 0);
    UIImage* gradientTexture = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    _controlsOverlay.backgroundColor = [UIColor colorWithPatternImage:gradientTexture];
}

- (void) loadPlayerFont
{

    NSString* fontPath = [[NSBundle mainBundle] pathForResource: @"Player-Regular" ofType: @"ttf"];
    NSData *data = [NSData dataWithContentsOfFile: fontPath];
    CFErrorRef error;

    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef) data);
    CGFontRef font = CGFontCreateWithDataProvider(provider);

    if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
        CFStringRef errorDescription = CFErrorCopyDescription(error);

        NSLog(@"Failed to load font: %@", errorDescription);
        CFRelease(errorDescription);
    }

    CFRelease(font);
    CFRelease(provider);

    NSString* fontName = (NSString*) CFBridgingRelease(CGFontCopyPostScriptName(font));

    // FIXME: the font size should be proporcional to the player size.
    _playPause.titleLabel.font = [UIFont fontWithName: fontName size: 150];
    [_playPause setTitle: @"\ue001" forState: UIControlStateNormal];
    [_playPause setTitle: @"\ue002" forState: UIControlStateSelected];
}

- (void) setupScrubber
{
    _scrubber.layer.cornerRadius = _scrubber.frame.size.width / 2;
    _scrubberCenter.layer.cornerRadius = _scrubberCenter.frame.size.width / 2;
    _scrubber.layer.borderColor = [UIColor colorWithRed: 192 / 255.0f green: 192 / 255.0f blue: 192 / 255.0f alpha: 1].CGColor;
}

- (void) setupDuration
{
    [_durationLabel setText: [self getFormattedTime: _player.currentItem.asset.duration]];
}

- (NSString*) getFormattedTime: (CMTime) time
{
    //FIXME: there is a better way to do it, without `+(NSString*) stringWithFormat:`
    NSUInteger totalSeconds = CMTimeGetSeconds(time);
    NSUInteger minutes = floor(totalSeconds % 3600 / 60);
    NSUInteger seconds = floor(totalSeconds % 3600 % 60);
    return [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long) minutes, (unsigned long) seconds];
}

- (void) attachTo:(UIViewController *)controller atView:(UIView *)container
{
    [controller addChildViewController:self];
    [container addSubview:self.view];

    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    container.translatesAutoresizingMaskIntoConstraints = NO;

    [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|" options:0 metrics:nil views:@{@"view": self.view}]];

    [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view": self.view}]];

    [container setNeedsLayout];
}

- (void) syncScrubber
{
    CGFloat current = ((CGFloat) CMTimeGetSeconds(_player.currentTime)) / CMTimeGetSeconds(_player.currentItem.asset.duration);
    if (isfinite(current) && current > 0 && shouldUpdate) {
        [self updatePositionBarConstraints: current * _seekBarContainer.frame.size.width];
    }
}

- (void) showMediaControl
{
    [UIView animateWithDuration: .3 animations: ^{
        _mediaControl.alpha = 1.0;
    }];
    mediaControlIsHidden = false;
}

- (void) hideMediaControl
{
    [UIView animateWithDuration: .3 animations: ^{
        _mediaControl.alpha = .0;
    }];
    mediaControlIsHidden = true;
}

- (void) updatePositionBarConstraints: (CGFloat) width
{
    _positionBarConstraint.constant = width;
    [_seekBarContainer setNeedsLayout];
}

- (void) scaleUpScrubber
{
    [UIView animateWithDuration: .3 animations: ^{
        _scrubber.transform = CGAffineTransformMakeScale(1.5, 1.5);
        _scrubber.layer.borderWidth = 1.0f / 1.5;
        _scrubberCenter.transform = CGAffineTransformMakeScale(0.5, 0.5);
    }];
}

- (void) undoScrubberTransform
{
    [UIView animateWithDuration: .3 animations: ^{
        _scrubber.layer.borderWidth = 0.0f;
        _scrubber.transform = CGAffineTransformIdentity;
        _scrubberCenter.transform = CGAffineTransformIdentity;
    }];
}

- (CMTime) positionToTime: (CGPoint) position
{
    return CMTimeMakeWithSeconds(position.x * CMTimeGetSeconds(_player.currentItem.asset.duration) / _seekBarContainer.frame.size.width, 1);
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self scaleUpScrubber];
    });
    return YES;
}

- (IBAction) toggleMediaControl:(UITapGestureRecognizer *)sender
{
    if (mediaControlIsHidden) {
        [self showMediaControl];
    } else {
        [self hideMediaControl];
    }
}

- (IBAction)togglePlayPause:(id)sender {
    if (_playPause.selected) {
        [_player pause];
    } else {
        [_player play];
    }
    _playPause.selected = !_playPause.selected;
}

- (IBAction) dragScrubber: (UIPanGestureRecognizer *) sender
{
    shouldUpdate = NO;
    CGPoint translation = [sender locationInView: _seekBarContainer];
    [self updatePositionBarConstraints: translation.x];
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self undoScrubberTransform];
        [_player seekToTime: [self positionToTime: translation]];
        shouldUpdate = YES;
    }
}

- (IBAction) seekTo:(UITapGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint position = [sender locationInView: _seekBarContainer];
        [_player seekToTime: [self positionToTime: position]];
        [self updatePositionBarConstraints: position.x];
        [self undoScrubberTransform];
    }
}

@end
