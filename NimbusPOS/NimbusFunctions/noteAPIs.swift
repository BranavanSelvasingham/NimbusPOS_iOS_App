//
//  noteAPIs.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-04-05.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

class NoteAPIs: APIs, SyncDownDocumentBatchDelegate {
    var collectionName = "Notes"
    
    override func getOneDocumentFromServer(documentId: String){
        let notesQuery = queryParams(collectionName: collectionName, findParams: ["_id": documentId], limit: 1, sortParams: [:], selectParams: [:])
        self.queryForCollectionAsync(queryParameters: notesQuery)
    }
    
    override func deleteOneDocumentLocally(documentId: String){
        NIMBUS.Notes?.deleteNoteById(noteId: documentId)
    }
    
    func getAllDocumentsFromServer(){
        let noteQuery = queryParams(collectionName: collectionName, selectParams: ["_id": 1])
        let syncJob = SyncDownDocumentBatch(queryParameters: noteQuery, delegate: self, notificationMessage: "Loading Notes...")
        syncJob.startSync()
    }
    
    func syncDownDocumentResultsReady(documentResults: [[String : Any]]) {
        self.resultsFromQueryCollectionCall(results: documentResults)
    }
    
    override func resultsFromQueryCollectionCall(results: [[String : Any]]) {
        let noteList = convertJSONToNote(json: results)
        saveToCoreData(resultsList: noteList)
    }
    
    private func convertJSONToNote(json: [[String: Any]]) -> [noteSchema]{
        var resultsList = [noteSchema]()
        json.forEach { json in
            let note = noteSchema(withJSONDataObject: json)
            resultsList.append(note)
        }
        return resultsList
    }
    
    private func saveToCoreData(resultsList: [noteSchema]){
        resultsList.forEach {item in
            item.saveToCoreData(enableChangeLog: false)
        }
        DispatchQueue.main.async {
            let saveCompleteNotification: notificationBatchSaveToCoreDataCompleted = notificationBatchSaveToCoreDataCompleted(entityName: Note.entity().name ?? self.collectionName, syncComplete: true, message: "Notes saved to local storage.")
            NotificationCenter.default.post(name: .onBatchSaveToCoreDataCompleted, object: saveCompleteNotification)
        }
    }
    
    func uploadNoteMO(noteMO: Note) -> Bool {
        let note: noteSchema = noteSchema(withManagedObject: noteMO)
        let uploadSuccess = uploadNote(note: note)
        return uploadSuccess
    }
    
    func uploadNote(note: noteSchema) -> Bool {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        var serialized = [String: Any]()
        encoder.outputFormatting = .prettyPrinted
        
        var uploadSuccess: Bool = false
        
        let jsonOrder = try? encoder.encode(note)
        if let data = jsonOrder {
            do {
                serialized = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
            } catch {
                print("Could not convert data to json", error)
            }
            
            let upsertParameters = upsertParams(collectionName: collectionName, newDocument: serialized)
            uploadSuccess = upsertDocumentInCollection(upsertParameters: upsertParameters)
        }
        
        return uploadSuccess
    }
    
    func delteNoteOnServer(note: Note){
        removeOneDocumentFromCollection(documentId: note.id ?? "", collectionName: collectionName)
    }
    
}
