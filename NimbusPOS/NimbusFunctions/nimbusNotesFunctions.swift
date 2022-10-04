//
//  nimbusNotesFunctions.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-16.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class nimbusNotesFunctions: NimbusBase {
    override init(master: NimbusFramework?){
        super.init(master: master)
    }

    let notesOnServer = NoteAPIs()
    
    func syncNotesServerDataToLocal(){
        notesOnServer.getAllDocumentsFromServer()
    }
    
    func processServerChangeLog(log: serverChangeLog){
        notesOnServer.processChangeLog(log: log)
    }
    
    func getNoteById(noteId: String) -> Note? {
        var fetchNotes = [Note]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Note")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "id = %@", noteId)
        
        do {
            fetchNotes = try managedContext.fetch(fetchRequest) as! [Note]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return fetchNotes.first
    }
    
    func fetchAllNotesSortedByDate() -> [Note]{
        var fetchNotes = [Note]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Note")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            fetchNotes = try managedContext.fetch(fetchRequest) as! [Note]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        var sortedNotes = fetchNotes
        
        sortedNotes = sortedNotes.sorted(by: {$0.createdOn?.compare($1.createdOn as? Date ?? Date()) == ComparisonResult.orderedDescending})

        return sortedNotes
    }
    
    func uploadNoteMO(noteMO: Note) -> Bool {
        return notesOnServer.uploadNoteMO(noteMO: noteMO)
    }

    func createNewNote(note: noteSchema){
        note.saveToCoreData()
    }
    
    func deleteNoteById(noteId: String){
        if let note = getNoteById(noteId: noteId) {
            deleteNote(note: note)
        }
    }
    
    func deleteNote(note: Note){
        managedContext.delete(note)
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func deleteAllNotes(){
        deleteAllRecords(entityName: Note.entity().managedObjectClassName )
    }
    
}
