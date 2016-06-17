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
        let request = NSFetchRequest(entityName: "Book")
        request.returnsObjectsAsFaults = false
        request.includesPropertyValues = false
        do{
            let results:NSArray = try context!.executeFetchRequest(request)
            if results.count > 0{
                for dsp in results{
                    let myDsp = dsp as! Book
                    context!.deleteObject(myDsp)
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
        let entLis = NSEntityDescription.entityForName("Book", inManagedObjectContext: context!)
        let book = Book(entity: entLis!, insertIntoManagedObjectContext: context)
        return book
    }
    func findAllBooks() -> [Book]{
        let request = NSFetchRequest(entityName: "Book")
        let sortDesc:Array = [NSSortDescriptor(key: "titolo", ascending: true)]
        request.sortDescriptors = sortDesc
        var results:[Book] = []
        do{
            results = try context!.executeFetchRequest(request) as! [Book]
            print(">>>>>>> \(results.count)")
        }
        catch{
            print("Errore nel find all books")
        }
        return results
    }
    func removeBook(book: Book){
        context!.deleteObject(book)
    }
    func save() throws {
        try context.save()
    }
    

}
