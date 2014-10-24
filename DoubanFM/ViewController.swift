//
//  ViewController.swift
//  DoubanFM
//
//  Created by DJ on 14/10/16.
//  Copyright (c) 2014年 DJ. All rights reserved.
//

import UIKit
import MediaPlayer
import QuartzCore
//
//var channelData = NSArray()
//var channelID:String = "0"

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HttpProtocol,ChannelProtocol {


    @IBOutlet weak var coversView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var songsTableView: UITableView!
    @IBOutlet weak var tap: UITapGestureRecognizer!
    @IBOutlet weak var controlImage: UIImageView!
    
    var channelUrl = "http://www.douban.com/j/app/radio/channels"
    var songUrl = "http://douban.fm/j/mine/playlist?channel=0"
    var songData = NSArray()
    var channelData = NSArray()
    var imageCache = Dictionary<String, UIImage>()
    var player = MPMoviePlayerController()
    var eHttp:HttpController = HttpController()
    var playTime:NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        progressView.progress = 0.0
        eHttp.delegate = self
        eHttp.onSearchWithUrl(channelUrl)
        eHttp.onSearchWithUrl(songUrl)
        coversView.addGestureRecognizer(tap)
//        controlImage.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var channelC = segue.destinationViewController as ChannelController
        channelC.channelData = self.channelData
        channelC.delegate = self //一定要记得跳转界面的时候将原界面的代理设置到self
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "song")
        var rowData = self.songData[indexPath.row] as NSDictionary
        cell.textLabel.text = rowData["title"] as? String
        cell.detailTextLabel?.text = rowData["artist"] as? String
        cell.imageView.image = UIImage(named: "detail.jpg")
        let url = rowData["picture"] as String
        
        //获取歌曲缩略图
        if let image = self.imageCache[url] { //尝试从缓存中读取缩略图
            cell.imageView.image = image
        } else {
            //下载缩略图
            let imageUrl = NSURL(string: url)
            let request = NSURLRequest(URL: imageUrl!)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response:NSURLResponse!,data:NSData!,error:NSError!) -> Void in
                let img = UIImage(data: data)
                cell.imageView.image = img
                self.imageCache[url] = img //更新缩略图
            })
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectDict = self.songData[indexPath.row] as NSDictionary
        let songUrl = selectDict["url"] as String
        let pictureUrl = selectDict["picture"] as String
        NSLog("========Song changes==========")
        NSLog(songUrl)
        playMusic(songUrl)
        showPicture(pictureUrl)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        // 展示动画
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1.0)
        UIView.animateWithDuration(0.5, animations: {
        cell.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        })
    }
    
    func didReceiveResults(results: NSDictionary) {
        if (results["song"] != nil) {
            self.songData = results["song"] as NSArray
            self.songsTableView.reloadData()
            let firstDict = self.songData[0] as NSDictionary
            let songUrl = firstDict["url"] as String
            let pictureUrl = firstDict["picture"] as String
//            let json = JSON(object: songData)
//            let songUrl = json["url"].ScalarString
//            let pictureUrl = json["picture"].string
            
            
            playMusic(songUrl)
            showPicture(pictureUrl)
            
        } else if (results["channels"] != nil) {
            self.channelData = results["channels"] as NSArray
        }
    }
    
    
    func playMusic(url: String) {
        timeLabel.text = "00:00"
        playTime?.invalidate()
        self.player.stop()
        self.player.contentURL = NSURL(string: url)
        self.player.play()
        controlImage.hidden = true
        controlImage.removeGestureRecognizer(tap)
        coversView.addGestureRecognizer(tap)
        playTime = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "updateTime", userInfo: nil, repeats: true)
    }
    
    func updateTime() {
        let current = player.currentPlaybackTime
        if player.playbackState == MPMoviePlaybackState.Playing {
            let time = player.duration
            let progress = Float(current/time)
            progressView.setProgress(progress, animated: true)
            
            let sec = Int(current % 60)
            let min = Int(current / 60)
            self.timeLabel.text = NSString(format: "%02d:%02d", min, sec)
        }
    }
    
    func showPicture(url:String) {
        //获取歌曲缩略图
        if let image = self.imageCache[url] { //尝试从缓存中读取缩略图
            self.coversView.image = image
        } else {
            //下载缩略图
            let imageUrl = NSURL(string: url)
            let request = NSURLRequest(URL: imageUrl!)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response:NSURLResponse!,data:NSData!,error:NSError!) -> Void in
                let img = UIImage(data: data)
                self.coversView.image = img
                self.imageCache[url] = img //更新缩略图
            })
        }
    }
    
    func didChangeChannel(channel: String) {
        var eChannel = ChannelController()
        eChannel.delegate = self
        self.songUrl = "http://douban.fm/j/mine/playlist?\(channel)"
        eHttp.onSearchWithUrl(songUrl)
        self.songsTableView.reloadData()
        NSLog("=======Channel changes============")
    }
    
    @IBAction func onTap(sender: UITapGestureRecognizer) {
        NSLog("tap")
        if sender.view == controlImage {
            controlImage.hidden = true
            player.play()
            controlImage.removeGestureRecognizer(tap)
            coversView.addGestureRecognizer(tap)
        } else {
            controlImage.hidden = false
            player.pause()
            coversView.removeGestureRecognizer(tap)
            controlImage.addGestureRecognizer(tap)
        }
        
//        if (self.player.playbackState == MPMoviePlaybackState.Playing) {
//            self.player.pause()
//            self.controlImage.hidden = false
//        } else if (self.player.playbackState == MPMoviePlaybackState.Paused) {
//            self.player.play()
//            self.controlImage.hidden = true
//        }
    }
}

