//
//  DbController.swift
//  LibraryApp
//
//  Created by Angelo Vittorio Zapponi on 24/08/15.
//  Copyright (c) 2015 Angelo Vittorio Zapponi. All rights reserved.
//

import Cocoa

class DbController: NSObject {
    var context: NSManagedObjectContext!
    
    // MARK: metodi per DB
    func clearBooks(){
        print("CLEAR BOOKS --------------------->")
//        let request = NSFetchRequest(entityName: "Book")
        var request:NSFetchRequest<Book>
        if #available(OSX 10.12, *) {
            request = Book.fetchRequest() as! NSFetchRequest<Book>
        } else {
            // Fallback on earlier versions
            request = NSFetchRequest(entityName: "Book")
        }

        request.returnsObjectsAsFaults = false
        request.includesPropertyValues = false
        do{
            let results:[Book] = try context!.fetch(request)
            if results.count > 0{
                for dsp in results{
                    let myDsp = dsp 
                    context!.delete(myDsp)
                }
                do{
                    try context!.save()
                }
                catch{
                    print("Errore nel savataggio")
                }
            }
        }
        catch{
            print("Errore nella ricerca")
        }
    }
    func getBookVuoto() -> Book{
        let entLis = NSEntityDescription.entity(forEntityName: "Book", in: context!)
        let book = Book(entity: entLis!, insertInto: context)
        return book
    }
    func findAllBooks() -> [Book]{
        var request:NSFetchRequest<Book>
        if #available(OSX 10.12, *) {
            request = Book.fetchRequest() as! NSFetchRequest<Book>
        } else {
            // Fallback on earlier versions
            request = NSFetchRequest(entityName: "Book")
        }
        let sortDesc:Array = [NSSortDescriptor(key: "titolo", ascending: true)]
        request.sortDescriptors = sortDesc
        var results:[Book] = []
        do{
            results = try context!.fetch(request) 
            print(">>>>>>> \(results.count)")
        }
        catch{
            print("Errore nel find all books")
        }
        return results
    }
    func removeBook(_ book: Book){
        context!.delete(book)
    }
    func save() throws {
        try context.save()
    }
    

}
