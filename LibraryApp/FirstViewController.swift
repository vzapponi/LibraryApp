//
//  FirstViewController.swift
//  LibraryApp
//
//  Created by Angelo Vittorio Zapponi on 24/08/15.
//  Copyright (c) 2015 Angelo Vittorio Zapponi. All rights reserved.
//

import Cocoa

class FirstViewController: NSViewController,NSTableViewDataSource,NSTableViewDelegate, NSTextFieldDelegate {
    let appDel = NSApplication.sharedApplication().delegate as! AppDelegate
    var books:Array<Book> = []
    var filteredBooks:Array<Book> = []
    var activeSearch = false
    var modifica = false
    
    
    @IBOutlet weak var table: NSTableView!
    @IBOutlet weak var txtTitolo: NSTextField!
    @IBOutlet weak var txtAutore: NSTextField!
    @IBOutlet weak var txtCollocazione: NSTextField!
    @IBOutlet weak var txtNVolumi: NSTextField!
    @IBOutlet weak var txtDataCreazione: NSTextField!
    @IBOutlet weak var txtDataModifica: NSTextField!
    @IBOutlet weak var txtPrestato: NSTextField!
    @IBOutlet weak var txtDataPrestito: NSTextField!
    @IBOutlet weak var txtBarcode: NSTextField!
    @IBOutlet weak var txtSearch: NSSearchField!
    @IBOutlet weak var comboTipo: NSComboBox!
    @IBOutlet weak var lblTotale: NSTextField!
    @IBOutlet weak var piuButt: NSButton!
    
    var currentBook: BookDiMezzo = BookDiMezzo()
    var veroBook: Book?
    var vindow:NSWindow?
    var moc:NSManagedObjectContext!
    override func viewDidLoad() {
        super.viewDidLoad()
        vindow = NSApplication.sharedApplication().windows[0] as NSWindow
        // Do view setup here.
        
        table.selectionHighlightStyle = NSTableViewSelectionHighlightStyle.Regular
        comboTipo.selectItemAtIndex(0)
    }
    override func viewDidLayout() {
        
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    override func viewWillAppear() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(initializeListener), name: MyNotificationKeys.addObserver, object: nil)
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()

    }
    override func viewDidDisappear() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    // MARK: - Persitence notification
    func initializeListener(){
        if let mocH = appDel.dbController.context{
            print("HO IL MOC")
            self.moc = mocH
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.persisteStoreDidChange), name:NSPersistentStoreCoordinatorStoresDidChangeNotification, object: moc.persistentStoreCoordinator)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.persistenceStoreWillChange(_:)), name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object: moc.persistentStoreCoordinator)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.receiveICloudChanges(_:)), name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: moc.persistentStoreCoordinator)
            statusICloud()
            reloadBooks()
        }
    }
    func persisteStoreDidChange() {
        print("persisteStoreDidChange")

    }
    func persistenceStoreWillChange(notification: NSNotification){
        print("persistenceStoreWillChange")
        moc.performBlock{() -> Void in
            if (self.moc.hasChanges){
                do{
                    try self.appDel.dbController.save()
                }
                catch{
                    print(error)
                    return
                }
                self.moc.reset()
            }
        }
    }
    func receiveICloudChanges(notification: NSNotification){
        print("receiveICloudChanges")
        moc.performBlock({() -> Void in
            self.moc.mergeChangesFromContextDidSaveNotification(notification)
            self.books = self.appDel.dbController.findAllBooks()
            self.reloadBooks()
        })
    }
    func reloadBooks(){
        books = appDel.dbController.findAllBooks()
        if (books.count > 0){
            table.reloadData()
        }
        lblTotale.integerValue = books.count
    }
    // MARK: - Table view
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        var nRows = 0
        if (activeSearch){
            nRows = filteredBooks.count
        }
        else{
            nRows = books.count
        }
        return nRows
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return CGFloat(48)
    }
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        if (activeSearch){
            return filteredBooks[row]
        }
        else{
            return books[row]
        }
    }
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = table.makeViewWithIdentifier("cell", owner: self) as! MyTableCell
        if (activeSearch){
            cell.txtTitolo.stringValue = filteredBooks[row].titolo
            cell.txtAutore.stringValue = filteredBooks[row].autore
        }
        else{
            cell.txtTitolo.stringValue = books[row].titolo
            cell.txtAutore.stringValue = books[row].autore
        }
        return cell
    }
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if (activeSearch){
            veroBook = filteredBooks[row]
            currentBook = BookDiMezzo(book: filteredBooks[row])
        }
        else{
            veroBook = books[row]
            currentBook = BookDiMezzo(book: books[row])
        }
        modifica = true
        showDati()
        return true
    }
    // MARK: Maschera
    @IBAction func piuPressed(sender: NSButton) {
        veroBook = appDel.dbController.getBookVuoto()
        currentBook = BookDiMezzo()
        showDati()
        sender.enabled = false
    }
    @IBAction func salva(sender: NSButton) {
        saveDati()
        if let myBook = veroBook{
            myBook.fillWithBookDiMezzo(currentBook)
            do{
                try appDel.dbController.context!.save()
            }
            catch{
                let myErr = error as NSError
                let avviso = NSAlert()
                avviso.messageText = "ERRORE NEL SALVATAGGIO"
                avviso.alertStyle = NSAlertStyle.CriticalAlertStyle
                var s:String = ""
                let dic = myErr.userInfo as? Dictionary<String, AnyObject>
                if let myDic = dic{
                    let arr = myDic["NSDetailedErrors"] as! NSArray
                    for er in arr{
                        let myEr = er as! NSError
                        s += myEr.localizedDescription + "\n"
                    }
                    avviso.informativeText = s
                }
                avviso.beginSheetModalForWindow(vindow!, completionHandler: nil)
                return
            }
            clearDati()
            reloadBooks()
            self.reset(sender)
        }
        modifica = false
        veroBook = nil
    }
    
    @IBAction func reset(sender: NSButton) {
        clearDati()
        table.deselectAll(self)
        piuButt.enabled = true
    }
    @IBAction func delete(sender: NSButton) {
        let avviso = NSAlert()
        avviso.addButtonWithTitle("SI")
        avviso.addButtonWithTitle("NO")
        avviso.messageText = "CHIEDO CONFERMA"
        avviso.informativeText = "Stai cancellando un libro!"
        avviso.alertStyle = NSAlertStyle.CriticalAlertStyle
        avviso.beginSheetModalForWindow(vindow!, completionHandler: {(returnCode) -> Void in
            if returnCode == NSAlertFirstButtonReturn{
                if let myBook = self.veroBook{
                    do{
                    self.appDel.dbController.removeBook(myBook)
                    try self.appDel.dbController.save()
                    self.reloadBooks()
                    self.reset(sender)
                    }
                    catch{
                        print("Errore nella cancellazione di un libro")
                    }
                }
            }
        })
    }
    func clearDati(){
        txtTitolo.stringValue = ""
        txtAutore.stringValue = ""
        txtCollocazione.stringValue = ""
        txtNVolumi.stringValue = ""
        txtDataCreazione.stringValue = ""
        txtDataModifica.stringValue = ""
        txtPrestato.stringValue = ""
        txtDataPrestito.stringValue = ""
        txtBarcode.stringValue = ""
    }
    func saveDati(){
        let dateForm = NSDateFormatter()
        dateForm.locale = NSLocale.currentLocale()
        dateForm.dateFormat = "yyyy/MMM/dd HH:mm"
        currentBook.titolo = txtTitolo.stringValue
        currentBook.autore = txtAutore.stringValue
        currentBook.collocazione = txtCollocazione.stringValue
        currentBook.volumi = txtNVolumi.integerValue
        if (currentBook.dataCreazione.isEmpty){
            currentBook.dataCreazione = dateForm.stringFromDate(NSDate())
        }
        currentBook.dataModifica = dateForm.stringFromDate(NSDate())
        currentBook.prestatoA = txtPrestato.stringValue
//        if (!currentBook.prestatoA.isEmpty){
//            currentBook.dataPrestito = dateForm.stringFromDate(NSDate())
//        }
        currentBook.barCode = txtBarcode.stringValue
    }
    func showDati(){
        txtTitolo.stringValue = currentBook.titolo
        txtAutore.stringValue = currentBook.autore
        txtCollocazione.stringValue = currentBook.collocazione
        txtNVolumi.integerValue = currentBook.volumi
        txtDataCreazione.stringValue = currentBook.dataCreazione
        txtDataModifica.stringValue = currentBook.dataModifica
        txtPrestato.stringValue = currentBook.prestatoA
        txtDataPrestito.stringValue = currentBook.dataPrestito
        txtBarcode.stringValue = currentBook.barCode
        
    }
    // MARK: - Searchtext

    override func controlTextDidChange(obj: NSNotification) {
        let info = obj.userInfo as! [String : AnyObject]
        let text = info["NSFieldEditor"] as! NSTextView
        if let myString = text.string{
            clearDati()
            if myString.isEmpty{
                activeSearch = false
                comboTipo.selectItemAtIndex(0)
                lblTotale.integerValue = books.count
            }
            else{
                activeSearch = true
                filtraBooks(myString)
            }
            table.reloadData()
        }
        
    }
    func filtraBooks(stringa: String){
        filteredBooks.removeAll(keepCapacity: false)
        var cerca = stringa
        let idx = comboTipo.indexOfSelectedItem
        var sForPredi = ""
        switch idx{
        case 0:
            sForPredi = "titolo BEGINSWITH[c] %@"
        case 1:
            sForPredi = "autore BEGINSWITH[c] %@"
        case 2:
            sForPredi = "collocazione BEGINSWITH[c] %@"
        case 3:
            sForPredi = "prestatoA != %@"
            cerca = ""
        default:
            sForPredi = "titolo BEGINSWITH[c] %@"
        }
        let searchPredicate = NSPredicate(format:sForPredi , cerca)
        let array = (books as NSArray).filteredArrayUsingPredicate(searchPredicate)
        filteredBooks = array as! [Book]
        lblTotale.integerValue = filteredBooks.count
    }
    // MARK: - messages
    func statusICloud(){
        let message = "ICloud OK!"
        let avviso = NSAlert()
        avviso.addButtonWithTitle("OK")
        avviso.messageText = "STATUS ICLOUD"
        avviso.informativeText = message
        avviso.alertStyle = NSAlertStyle.InformationalAlertStyle
        avviso.beginSheetModalForWindow(self.vindow!, completionHandler: {(returnCode) -> Void in
        })
        
    }
    
    
}

    