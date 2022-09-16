/*****************************************************************************
 * VLC for iOS
 *****************************************************************************
 * Copyright (c) 2017-2018 VideoLAN. All rights reserved.
 * $Id$
 *
 * Authors: Carola Nitz <caro # videolan.org>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

#import "VLCMetadata.h"
#import <MediaPlayer/MediaPlayer.h>
#import "VLCPlaybackService.h"

#if TARGET_OS_IOS
#import "VLC-Swift.h"
#endif

@implementation VLCMetaData

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.trackNumber = nil;
        self.title = @"";
        self.artist = @"";
        self.albumName = @"";
        self.artworkImage = nil;
        self.isAudioOnly = NO;
    }
    return self;
}
#if TARGET_OS_TV
- (void)updateMetadataFromMediaPlayer:(VLCMediaPlayer *)mediaPlayer;
{
    [self updateMetadataFromMediaPlayerFortvOS:mediaPlayer];
}
#endif

#if TARGET_OS_IOS
- (void)updateMetadataFromMedia:(VLCMLMedia *)media mediaPlayer:(VLCMediaPlayer*)mediaPlayer
{
    if (media && !media.isExternalMedia) {
        self.title = media.title;
        self.artist = media.artist.name;
        self.trackNumber = @(media.trackNumber);
        self.albumName = media.album.title;
        self.artworkImage = [media thumbnailImage];
        self.isAudioOnly = [media subtype] == VLCMLMediaSubtypeAlbumTrack;
    } else { // We're streaming something
        [self fillFromMetaDict:mediaPlayer];
        if (!self.artworkImage) {
            BOOL isDarktheme = PresentationTheme.current.isDark;
            self.artworkImage = isDarktheme ? [UIImage imageNamed:@"song-placeholder-dark"]
                                            : [UIImage imageNamed:@"song-placeholder-white"];
        }
    }

    [self checkIsAudioOnly:mediaPlayer];

    if (self.isAudioOnly) {
        if (self.artworkImage) {
            if (self.artist)
                self.title = [self.title stringByAppendingFormat:@" — %@", self.artist];
            if (self.albumName)
                self.title = [self.title stringByAppendingFormat:@" — %@", self.albumName];
        }
        if (self.title.length < 1)
            self.title = [[mediaPlayer.media url] lastPathComponent];

    }
    [self updatePlaybackRate:mediaPlayer];

    //Down here because we still need to populate the miniplayer
    if ([VLCKeychainCoordinator passcodeLockEnabled]) return;

    [self populateInfoCenterFromMetadata];
}
#else

- (void)updateMetadataFromMediaPlayerFortvOS:(VLCMediaPlayer *)mediaPlayer
{
    [self fillFromMetaDict:mediaPlayer];
    [self checkIsAudioOnly:mediaPlayer];

    if (self.isAudioOnly) {
        if (self.title.length < 1)
            self.title = [[mediaPlayer.media url] lastPathComponent];
    }
    [self updatePlaybackRate:mediaPlayer];
    [self populateInfoCenterFromMetadata];
}
#endif

- (void)updateExposedTimingFromMediaPlayer:(VLCMediaPlayer*)mediaPlayer
{
    /* just update the timing data and used the cached rest for the update
     * regrettably, in contrast to macOS, we always need to deliver the full dictionary */
    self.elapsedPlaybackTime = @(mediaPlayer.time.value.floatValue / 1000.);
    self.position = @(mediaPlayer.position);

    [self populateInfoCenterFromMetadata];
}

- (void)updatePlaybackRate:(VLCMediaPlayer *)mediaPlayer
{
    self.playbackDuration = @(mediaPlayer.media.length.intValue / 1000.);
    self.playbackRate = @(mediaPlayer.rate);
    VLCTime *elapsedPlaybackTime = mediaPlayer.time;
    if (elapsedPlaybackTime) {
        self.elapsedPlaybackTime = @(elapsedPlaybackTime.value.floatValue / 1000.);
    }
    self.position = @(mediaPlayer.position);
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:VLCPlaybackServicePlaybackMetadataDidChange object:self];
    });
}

- (void)checkIsAudioOnly:(VLCMediaPlayer *)mediaPlayer
{
    _isAudioOnly = mediaPlayer.numberOfVideoTracks == 0;
}

- (void)fillFromMetaDict:(VLCMediaPlayer *)mediaPlayer
{
    NSDictionary *metaDict = mediaPlayer.media.metaDictionary;

    if (metaDict) {
        self.title = metaDict[VLCMetaInformationNowPlaying] ?: metaDict[VLCMetaInformationTitle];
        self.artist = metaDict[VLCMetaInformationArtist];
        self.albumName = metaDict[VLCMetaInformationAlbum];
        self.trackNumber = metaDict[VLCMetaInformationTrackNumber];
        self.artworkImage = nil;

        NSString *artworkURLString = metaDict[VLCMetaInformationArtworkURL];
        if (artworkURLString) {
            NSURL *artworkURL = [NSURL URLWithString:artworkURLString];
            if (artworkURL) {
                NSData *imageData = [NSData dataWithContentsOfURL:artworkURL];
                if (imageData) {
                    self.artworkImage = [UIImage imageWithData:imageData];
                }
            }
        }
    }
}

- (void)populateInfoCenterFromMetadata
{
    NSMutableDictionary *currentlyPlayingTrackInfo = [NSMutableDictionary dictionary];
    NSNumber *duration = self.playbackDuration;
    currentlyPlayingTrackInfo[MPMediaItemPropertyPlaybackDuration] = duration;
    if (@available(iOS 10.0, *)) {
        currentlyPlayingTrackInfo[MPNowPlayingInfoPropertyIsLiveStream] = @(duration.intValue <= 0);
        currentlyPlayingTrackInfo[MPNowPlayingInfoPropertyMediaType] = _isAudioOnly ? @(MPNowPlayingInfoMediaTypeAudio) : @(MPNowPlayingInfoMediaTypeVideo);
        currentlyPlayingTrackInfo[MPNowPlayingInfoPropertyPlaybackProgress] = self.position;
    }
    currentlyPlayingTrackInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.elapsedPlaybackTime;
    currentlyPlayingTrackInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.playbackRate;

    currentlyPlayingTrackInfo[MPMediaItemPropertyTitle] = self.title;
    currentlyPlayingTrackInfo[MPMediaItemPropertyArtist] = self.artist;
    currentlyPlayingTrackInfo[MPMediaItemPropertyAlbumTitle] = self.albumName;

    if ([self.trackNumber intValue] > 0)
        currentlyPlayingTrackInfo[MPMediaItemPropertyAlbumTrackNumber] = self.trackNumber;

#if TARGET_OS_IOS
    if (self.artworkImage) {
        @try {
            MPMediaItemArtwork *mpartwork = [[MPMediaItemArtwork alloc] initWithImage:self.artworkImage];
            currentlyPlayingTrackInfo[MPMediaItemPropertyArtwork] = mpartwork;
        } @catch (NSException *exception) {
            currentlyPlayingTrackInfo[MPMediaItemPropertyArtwork] = nil;
        }
    }
#endif

    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = currentlyPlayingTrackInfo;
}

@end
