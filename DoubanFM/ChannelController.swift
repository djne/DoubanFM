//
//  ChannelController.swift
//  DoubanFM
//
//  Created by DJ on 14/10/16.
//  Copyright (c) 2014年 DJ. All rights reserved.
//

import UIKit
import QuartzCore

protocol ChannelProtocol {
    func didChangeChannel(channel:String)
}

class ChannelController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var channelTableView: UITableView!
    var channelData = NSArray()
//    var channel_id = "0"
    var delegate:ChannelProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "channel")
        var rowData = channelData[indexPath.row] as NSDictionary
        cell.textLabel.text = rowData["name"] as? String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var rowData = channelData[indexPath.row] as NSDictionary
        var channel_id: AnyObject = rowData["channel_id"]!
//        println(channel)
        var channel:String = "channel=\(channel_id)"
        delegate?.didChangeChannel(channel)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1.0)
        UIView.animateWithDuration(0.5, animations: {
        cell.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        })
    }
    
}