//
//  AppDelegate.swift
//  LibraryApp
//
//  Created by Angelo Vittorio Zapponi on 17/08/15.
//  Copyright (c) 2015 Angelo Vittorio Zapponi. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var dbController: DbController = DbController()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        self.dbController.context = managedObjectContext
        NotificationCenter.default.post(name: Notification.Name(rawValue: MyNotificationKeys.addObserver), object: nil)
    }
        
    override func awakeFromNib() {
//        let fileManager = NSFileManager.defaultManager()
        
//        println(currentiCloudToken)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "iCloudAccountAvailabilityChanged:", name: NSUbiquityIdentityDidChangeNotification, object: nil)
//        dbController = DbController()
//        dbController?.context = managedObjectContext
//        dbController!.clearBooks()
//        let location = NSBundle.mainBundle().pathForResource("Libreria3", ofType:"csv")
//        //"Libreria3.csv".stringByExpandingTildeInPath
//        var error: NSError?
//        let fileContent = NSString(contentsOfFile: location!, encoding: NSUTF8StringEncoding, error: &error)
//        if (error != nil){
//            println(error)
//        }
//        else{
//            if let myString = fileContent{
//                let paragraf = myString.componentsSeparatedByString("\n")
//                var csvCells = [[String]]()
//                for item in paragraf{
//                    csvCells.append(item.componentsSeparatedByString(";") as! Array<String>)
//                }
//                for riga in csvCells{
//                    var rigaCell = [String]()
//                    for cell in riga{
//                        var cellRep = cell.stringByReplacingOccurrencesOfString("\"", withString: "")
//                        rigaCell.append(cellRep)
//                    }
//                    if (rigaCell.count > 9){
//                        println(" \(rigaCell[2]) numero celle \(rigaCell.count) <<<<<<<<<<<<")
//                    }
//                    else{
//                        println(" \(rigaCell[2]) numero celle \(rigaCell.count)")
//                    }
//                    var book = dbController!.getBookVuoto()
//                    book.fillWithArrayOfString(rigaCell)
//                }
//                var error:NSError? = nil
//                dbController!.context!.save(&error)
//                if let myEr = error{
//                    println(myEr)
//                }
//            }
//        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        do{
            try dbController.save()
        }
        catch{
            print(error)
        }
    }
    func readDataFroFile(){
        dbController.clearBooks()
        let location = Bundle.main.path(forResource: "Libreria", ofType:"csv")
        //"Libreria3.csv".stringByExpandingTildeInPath
        do{
            let fileContent = try NSString(contentsOfFile: location!, encoding: String.Encoding.utf8.rawValue)
            let paragraf = fileContent.components(separatedBy: "\n")
            var csvCells = [[String]]()
            var idx = 0
            for item in paragraf{
                idx = idx+1
                print("\(idx) \(item)")
                csvCells.append(item.components(separatedBy: ";"))
            }
            for riga in csvCells{
                var rigaCell = [String]()
                for cell in riga{
                    let cellRep = cell.replacingOccurrences(of: "\"", with: "")
                    rigaCell.append(cellRep)
                }
                if (rigaCell.count > 9){
                    print(" \(rigaCell[2]) numero celle \(rigaCell.count) <<<<<<<<<<<<")
                }
                else{
                    print(" \(rigaCell[2]) numero celle \(rigaCell.count)")
                }
                let book = dbController.getBookVuoto()
                book.fillWithArrayOfString(rigaCell)
            }
            do{
                try dbController.context!.save()
            }
            catch{
                print("Errore nel salvataggio libri")
            }

        }
        catch{
            let nserror = error as NSError
            print("Errore caricamento file libri \(nserror)")
        }
    }
    
    // MARK: - Core Data stack

    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "LibraryApp", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let documentDirectory = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last! as URL
        let storeUrl = documentDirectory.appendingPathComponent("it.zapponi.LibraryApp.sqlite")
        print(">>>>>>>> \(storeUrl)")
        let storeOptions = [NSPersistentStoreUbiquitousContentNameKey:"iCloud it zapponi LibraryApp",
                            NSMigratePersistentStoresAutomaticallyOption:true,
                            NSInferMappingModelAutomaticallyOption:true] as [String : Any]
        
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            let store:NSPersistentStore = try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeUrl, options: storeOptions)
            print("URL REALE DA COORDINATOR >>>>>>>>>> \(store.url)")
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        print("managedObjectContext")
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplicationTerminateReply {
        // If we got here, it is time to quit.
        return .terminateNow
    }

}

