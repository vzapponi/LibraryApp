//
//  BookDiMezzo.swift
//  LibraryApp
//
//  Created by Angelo Vittorio Zapponi on 25/08/15.
//  Copyright (c) 2015 Angelo Vittorio Zapponi. All rights reserved.
//

import Cocoa

class BookDiMezzo: NSObject {
    let dateFormatter = DateFormatter()
    var dataCreazione: String
    var dataModifica: String
    var titolo: String
    var autore: String
    var collocazione: String
    var volumi: Int
    var dataPrestito: String
    var prestatoA: String{
        didSet{
            if prestatoA != ""{
                dateFormatter.locale = Locale.current
                dateFormatter.dateFormat = "yyyy/MMM/dd HH:mm"
                dataPrestito = dateFormatter.string(from: Date())
            }
            else{
                dataPrestito = ""
            }
        }
    }
    var barCode: String
    override init(){
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy/MMM/dd HH:mm"
        dataCreazione = dateFormatter.string(from: Date())
        dataModifica = dateFormatter.string(from: Date())
        titolo = ""
        autore = ""
        collocazione = ""
        volumi = 1
        dataPrestito = ""
        prestatoA = ""
        barCode = ""
    }
    init(book: Book){
        dataCreazione = book.dataCreazione
        dataModifica = book.dataModifica
        titolo = book.titolo
        autore = book.autore
        collocazione = book.collocazione
        volumi = book.volumi as Int
        dataPrestito = book.dataPrestito
        prestatoA = book.prestatoA
        barCode = book.barCode
    }

}
