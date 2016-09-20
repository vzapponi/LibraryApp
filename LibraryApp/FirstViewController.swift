//
//  FirstViewController.swift
//  LibraryApp
//
//  Created by Angelo Vittorio Zapponi on 24/08/15.
//  Copyright (c) 2015 Angelo Vittorio Zapponi. All rights reserved.
//

import Cocoa

class FirstViewController: NSViewController,NSTableViewDataSource,NSTableViewDelegate, NSTextFieldDelegate {
    let appDel = NSApplication.shared().delegate as! AppDelegate
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
        vindow = NSApplication.shared().windows[0] as NSWindow
        // Do view setup here.
        
        table.selectionHighlightStyle = NSTableViewSelectionHighlightStyle.regular
        comboTipo.selectItem(at: 0)
    }
    override func viewDidLayout() {
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    override func viewWillAppear() {
        NotificationCenter.default.addObserver(self, selector: #selector(initializeListener), name: NSNotification.Name(rawValue: MyNotificationKeys.addObserver), object: nil)
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()

    }
    override func viewDidDisappear() {
        NotificationCenter.default.removeObserver(self)
    }
    // MARK: - Persitence notification
    func initializeListener(){
        if let mocH = appDel.dbController.context{
            print("HO IL MOC")
            self.moc = mocH
            NotificationCenter.default.addObserver(self, selector: #selector(self.persisteStoreDidChange), name:NSNotification.Name.NSPersistentStoreCoordinatorStoresDidChange, object: moc.persistentStoreCoordinator)
            NotificationCenter.default.addObserver(self, selector: #selector(self.persistenceStoreWillChange(_:)), name: NSNotification.Name.NSPersistentStoreCoordinatorStoresWillChange, object: moc.persistentStoreCoordinator)
            NotificationCenter.default.addObserver(self, selector: #selector(self.receiveICloudChanges(_:)), name: NSNotification.Name.NSPersistentStoreDidImportUbiquitousContentChanges, object: moc.persistentStoreCoordinator)
            statusICloud()
            reloadBooks()
        }
    }
    func persisteStoreDidChange() {
        print("persisteStoreDidChange")

    }
    func persistenceStoreWillChange(_ notification: Notification){
        print("persistenceStoreWillChange")
        moc.perform{() -> Void in
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
    func receiveICloudChanges(_ notification: Notification){
        print("receiveICloudChanges")
        moc.perform({() -> Void in
            self.moc.mergeChanges(fromContextDidSave: notification)
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
    func numberOfRows(in tableView: NSTableView) -> Int {
        var nRows = 0
        if (activeSearch){
            nRows = filteredBooks.count
        }
        else{
            nRows = books.count
        }
        return nRows
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return CGFloat(48)
    }
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if (activeSearch){
            return filteredBooks[row]
        }
        else{
            return books[row]
        }
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = table.make(withIdentifier: "cell", owner: self) as! MyTableCell
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
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
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
    @IBAction func piuPressed(_ sender: NSButton) {
        veroBook = appDel.dbController.getBookVuoto()
        currentBook = BookDiMezzo()
        showDati()
        sender.isEnabled = false
    }
    @IBAction func salva(_ sender: NSButton) {
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
                avviso.alertStyle = NSAlertStyle.critical
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
                avviso.beginSheetModal(for: vindow!, completionHandler: nil)
                return
            }
            clearDati()
            reloadBooks()
            self.reset(sender)
        }
        modifica = false
        veroBook = nil
    }
    
    @IBAction func reset(_ sender: NSButton) {
        clearDati()
        table.deselectAll(self)
        piuButt.isEnabled = true
    }
    @IBAction func delete(_ sender: NSButton) {
        let avviso = NSAlert()
        avviso.addButton(withTitle: "SI")
        avviso.addButton(withTitle: "NO")
        avviso.messageText = "CHIEDO CONFERMA"
        avviso.informativeText = "Stai cancellando un libro!"
        avviso.alertStyle = NSAlertStyle.critical
        avviso.beginSheetModal(for: vindow!, completionHandler: {(returnCode) -> Void in
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
        let dateForm = DateFormatter()
        dateForm.locale = Locale.current
        dateForm.dateFormat = "yyyy/MMM/dd HH:mm"
        currentBook.titolo = txtTitolo.stringValue
        currentBook.autore = txtAutore.stringValue
        currentBook.collocazione = txtCollocazione.stringValue
        currentBook.volumi = txtNVolumi.integerValue
        if (currentBook.dataCreazione.isEmpty){
            currentBook.dataCreazione = dateForm.string(from: Date())
        }
        currentBook.dataModifica = dateForm.string(from: Date())
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

    override func controlTextDidChange(_ obj: Notification) {
        let info = (obj as NSNotification).userInfo as! [String : AnyObject]
        let text = info["NSFieldEditor"] as! NSTextView
        if let myString = text.string{
            clearDati()
            if myString.isEmpty{
                activeSearch = false
                comboTipo.selectItem(at: 0)
                lblTotale.integerValue = books.count
            }
            else{
                activeSearch = true
                filtraBooks(myString)
            }
            table.reloadData()
        }
        
    }
    func filtraBooks(_ stringa: String){
        filteredBooks.removeAll(keepingCapacity: false)
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
        let array = (books as NSArray).filtered(using: searchPredicate)
        filteredBooks = array as! [Book]
        lblTotale.integerValue = filteredBooks.count
    }
    // MARK: - messages
    func statusICloud(){
        let message = "ICloud OK!"
        let avviso = NSAlert()
        avviso.addButton(withTitle: "OK")
        avviso.messageText = "STATUS ICLOUD"
        avviso.informativeText = message
        avviso.alertStyle = NSAlertStyle.informational
        avviso.beginSheetModal(for: self.vindow!, completionHandler: {(returnCode) -> Void in
        })
        
    }
    
    
}

    
