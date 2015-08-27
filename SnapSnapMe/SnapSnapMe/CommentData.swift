//
//  CommentData.swift
//  Gegder
//
//  Copyright (c) 2015 Genesys. All rights reserved.
//

import Foundation

class CommentData {
    class CommentEntry {
        var name : String?
        var datetime : String?
        var comment : String?
        var commentId : String?
        var status : String?
        var postId: String?
        var userId: String?
    }
    
    var entries = [CommentEntry]()
    
    func clearEntries() {
        entries.removeAll(keepCapacity: false)
    }
    
    func addEntriesFromJSON(data: JSON) {
        
        for (index: String, post: JSON) in data {
            
            let entry = CommentEntry()
            entry.commentId = post["id"].string!
            entry.userId = post["user_id"].string!
            entry.postId = post["dphodto_id"].string!
            entry.comment = post["comment"].string!
            entry.status = post["status"].string!
            entry.datetime = post["created_datetime"].string!
            entry.name = post["username"].string!
            
            entries.append(entry)
        }
    }
    
    func removeEntry(commentId: String) {
        
        for (index, entry) in enumerate(entries) {
            
            if entry.commentId == commentId {
                
                entries.removeAtIndex(index)
                break
            }
        }
    }
}