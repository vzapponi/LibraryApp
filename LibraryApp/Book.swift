//
//  Book.swift
//  LibraryApp
//
//  Created by Angelo Vittorio Zapponi on 23/08/15.
//  Copyright (c) 2015 Angelo Vittorio Zapponi. All rights reserved.
//

import Foundation
import CoreData

@objc(Book)
class Book: NSManagedObject {

    @NSManaged var dataCreazione: String
    @NSManaged var dataModifica: String
    @NSManaged var titolo: String
    @NSManaged var autore: String
    @NSManaged var collocazione: String
    @NSManaged var volumi: NSNumber
    @NSManaged var dataPrestito: String
    @NSManaged var prestatoA: String
    @NSManaged var barCode: String
    
    func fillWithArrayOfString(_ arrai:[String]){
        self.dataCreazione = arrai[0]
        self.dataModifica = arrai[1]
        self.titolo = arrai[2]
        self.autore = arrai[3]
        self.collocazione = arrai[4]
        let s = arrai[5]
        if s.isEmpty{
            self.volumi = 1
        }
        else{
            self.volumi = NSNumber(value: Int(s)! as Int)
        }
        self.dataPrestito = arrai[6]
        self.prestatoA = arrai[7]
        self.barCode = arrai[8]
    }
    func toString() -> String{
        return titolo + " " + autore + " " + collocazione
    }
    
    func fillWithBookDiMezzo(_ bookDiMezzo: BookDiMezzo){
        self.dataCreazione = bookDiMezzo.dataCreazione
        self.dataModifica = bookDiMezzo.dataModifica
        self.titolo = bookDiMezzo.titolo
        self.autore = bookDiMezzo.autore
        self.collocazione = bookDiMezzo.collocazione
        self.volumi = bookDiMezzo.volumi as NSNumber
        self.dataPrestito = bookDiMezzo.dataPrestito
        self.prestatoA = bookDiMezzo.prestatoA
        self.barCode = bookDiMezzo.barCode
    }

}
