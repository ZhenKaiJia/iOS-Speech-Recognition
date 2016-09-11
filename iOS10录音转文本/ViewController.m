//
//  ViewController.m
//  iOS10录音转文本
//
//  Created by Memebox on 16/9/11.
//  Copyright © 2016年 Justin. All rights reserved.
//

#import "ViewController.h"
#import <Speech/Speech.h>
#import <AVFoundation/AVFoundation.h>

#define kRecordAudioFile @"myRecord.caf"

@interface ViewController ()

@property (nonatomic,strong) AVAudioRecorder *audioRecorder;//音频录音机

@property (nonatomic,strong) AVAudioPlayer *audioPlayer;//音频播放器，用于播放录音文件

@property (nonatomic , strong) AVAudioRecorder *recoeder;

@property (nonatomic, strong) UIButton *starButton;

@property (nonatomic, strong) UIButton *stopButton;

@property (nonatomic, strong) UIButton *playButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self commitView];
}

- (void) commitView {
    [self.view addSubview:self.starButton];
    [self.view addSubview:self.stopButton];
    [self.view addSubview:self.playButton];
    
    self.starButton.frame = CGRectMake(50, 100, 100, 30);
    self.stopButton.frame = CGRectMake(50, 150, 100, 30);
    self.playButton.frame = CGRectMake(50, 200, 100, 30);
    
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    //设置为播放和录音状态，以便可以在录制完之后播放录音
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
}

//解析声音，转换文件
- (void) translationSoundToString {
    NSLocale *local =[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    //1.创建一个语音识别对象
    SFSpeechRecognizer *sf =[[SFSpeechRecognizer alloc] initWithLocale:local];
    
    //2.将资源包中获取的url(录音文件的地址) 传递给 request 对象
    SFSpeechURLRecognitionRequest *res =[[SFSpeechURLRecognitionRequest alloc] initWithURL:[self getSavePath]];
    
    //3.发送一个请求
    [sf recognitionTaskWithRequest:res resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        if (error!=nil) {
            NSLog(@"语音识别解析失败,%@",error);
        }
        else {
            //解析正确
            NSLog(@"---%@",result.bestTranscription.formattedString);
        }
    }];
}

//创建播放器
-(AVAudioPlayer *)audioPlayer{
    if (!_audioPlayer) {
        NSURL *url=[self getSavePath];
        NSError *error=nil;
        _audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        _audioPlayer.numberOfLoops=0;
        [_audioPlayer prepareToPlay];
        if (error) {
            NSLog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioPlayer;
}

//获得录音机对象
-(AVAudioRecorder *)audioRecorder{
    if (!_audioRecorder) {
        //创建录音文件保存路径
        NSURL *url=[self getSavePath];
        //创建录音格式设置
        NSDictionary *setting=[self getAudioSetting];
        //创建录音机
        NSError *error=nil;
        _audioRecorder=[[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
        _audioRecorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}

/**
 *  取得录音文件保存路径
 *
 *  @return 录音文件路径
 */
-(NSURL *)getSavePath{
    NSString *urlStr=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr=[urlStr stringByAppendingPathComponent:kRecordAudioFile];
    NSLog(@"file path:%@",urlStr);
    NSURL *url=[NSURL fileURLWithPath:urlStr];
    return url;
}
//取得录音文件设置
-(NSDictionary *)getAudioSetting{
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    //设置录音格式
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    //设置录音采样率
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    //是否使用浮点数采样
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    //....其他设置等
    return dicM;
}

//开始录音
- (void)starClick {
    if (![self.audioRecorder isRecording]) {
        [self.audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
    }
}
//结束录音
- (void)stopClick {
    [self.audioRecorder stop];
    [self translationSoundToString];
}
//播放录音
- (void)playClick {
    if (![self.audioPlayer isPlaying]) {
        [self.audioPlayer play];
    }
}

- (UIButton *)starButton {
    if (!_starButton) {
        _starButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _starButton.backgroundColor = [UIColor whiteColor];
        [_starButton setTitle:@"开始录音" forState:UIControlStateNormal];
        [_starButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_starButton addTarget:self action:@selector(starClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _starButton;
}

- (UIButton *)stopButton {
    if (!_stopButton) {
        _stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_stopButton setTitle:@"停止录音" forState:UIControlStateNormal];
        _stopButton.backgroundColor = [UIColor whiteColor];
        [_stopButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_stopButton addTarget:self action:@selector(stopClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stopButton;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.backgroundColor = [UIColor whiteColor];
        [_playButton setTitle:@"播放录音" forState:UIControlStateNormal];
        [_playButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(playClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
