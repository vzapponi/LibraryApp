//
//  MyTableCell.swift
//  LibraryApp
//
//  Created by Angelo Vittorio Zapponi on 25/08/15.
//  Copyright (c) 2015 Angelo Vittorio Zapponi. All rights reserved.
//

import Cocoa

class MyTableCell: NSTableCellView {
    @IBOutlet weak var txtTitolo: NSTextField!
    @IBOutlet weak var txtAutore: NSTextField!
    override var backgroundStyle:NSBackgroundStyle{
        //check value when the style was setted
        didSet{
            //if it is dark the cell is highlighted -> apply the app color to it
            if let myLayer = self.layer{
                if backgroundStyle == .Dark{
                    myLayer.backgroundColor = NSColor.yellowColor().CGColor
                    txtTitolo.backgroundColor = NSColor.yellowColor()
                    txtAutore.backgroundColor = NSColor.yellowColor()
                }
                    //else go back to the standard color
                else{
                    myLayer.backgroundColor = NSColor.clearColor().CGColor
                    txtTitolo.backgroundColor = NSColor.clearColor()
                    txtAutore.backgroundColor = NSColor.clearColor()
                }
            }
        }
    }
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        // Drawing code here.
        self.wantsLayer = true
        txtTitolo.font = NSFont(name: "Helvetica-Bold", size: CGFloat(14))
        txtAutore.font = NSFont(name: "Helvetica", size: CGFloat(12))
        txtAutore.textColor = NSColor.grayColor()
    }

    
}
