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
                if backgroundStyle == .dark{
                    myLayer.backgroundColor = NSColor.yellow.cgColor
                    txtTitolo.backgroundColor = NSColor.yellow
                    txtAutore.backgroundColor = NSColor.yellow
                }
                    //else go back to the standard color
                else{
                    myLayer.backgroundColor = NSColor.clear.cgColor
                    txtTitolo.backgroundColor = NSColor.clear
                    txtAutore.backgroundColor = NSColor.clear
                }
            }
        }
    }
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
        self.wantsLayer = true
        txtTitolo.font = NSFont(name: "Helvetica-Bold", size: CGFloat(14))
        txtAutore.font = NSFont(name: "Helvetica", size: CGFloat(12))
        txtAutore.textColor = NSColor.gray
    }

    
}
