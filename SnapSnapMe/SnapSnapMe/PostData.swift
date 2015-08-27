//
//  PostData.swift
//  Gegder
//
//  Copyright (c) 2015 Genesys. All rights reserved.
//

import Foundation

class PostData {
    class PostEntry {
//        var title : String?
//        var username : String?
//        var location : String?
        var media_url : String?
        var created_datetime : String?
        var hash_tag : String?
        var description : String?
        var total_comments : String?
        var total_likes : String?
        var is_like : Bool
        var post_id : String?
        var display_order : String?
        
        init() {
            is_like = false
        }
    }
    
    var entries = [PostEntry]()
    
    init() {
        let entry = PostEntry()
        entries.append(entry)
    }
    
    func clearEntries() {
        entries.removeAll(keepCapacity: false)
    }
    
    func addEntriesFromJSON(data: JSON) {
        
        for (index: String, post: JSON) in data {
            
            let entry = PostEntry()
//            entry.title = post["title"].string!
//            entry.username = post["username"].string!
//            entry.location = post["location"].string!
            entry.media_url = post["link_url"].string!
            entry.created_datetime = post["created_datetime"].string!
            
            var dateString = post["created_datetime"].string!
            var dateFormatter = NSDateFormatter()
            dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 28800)
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            if let date = dateFormatter.dateFromString(dateString) {
                // Format into desired format
                dateFormatter.dateFormat = "dd MMM yyyy, HH:mm"
                entry.created_datetime = dateFormatter.stringFromDate(date)
                
            } else {
                entry.created_datetime = dateString
            }
            
            entry.hash_tag = post["hash_tag"].string!
            entry.description = post["description"].string!
            entry.total_comments = post["total_comments"].string!
            entry.total_likes = post["total_likes"].string!
            entry.is_like = post["is_like"].bool!
            entry.post_id = post["id"].string!
            entry.display_order = post["display_order"].string!
            
            entries.append(entry)
        }
    }
    
    func addEntriesToFrontFromJSON(data: JSON) {
        
        var oldEntries = entries
        var newEntries = [PostEntry]()
        
        for (index: String, post: JSON) in data {
            
            let entry = PostEntry()
//            entry.title = post["title"].string!
//            entry.username = post["username"].string!
//            entry.location = post["location"].string!
            entry.media_url = post["link_url"].string!
            entry.created_datetime = post["created_datetime"].string!
            entry.hash_tag = post["hash_tag"].string!
            entry.description = post["description"].string!
            entry.total_comments = post["total_comments"].string!
            entry.total_likes = post["total_likes"].string!
            entry.is_like = post["is_like"].bool!
            entry.post_id = post["id"].string!
            entry.display_order = post["display_order"].string!
            
            newEntries.append(entry)
        }
        
        entries = newEntries + oldEntries
    }
    
    func removeEntry(postId: String) {
        
        for (index, entry) in enumerate(entries) {
            
            if entry.post_id == postId {
                
                entries.removeAtIndex(index)
                break
            }
        }
    }
    
    func findEntry(postId: String) -> PostEntry! {
        
        for entry in entries {
            if entry.post_id == postId {
                return entry
            }
        }
        
        return nil
    }
    
    func likePost(postId: String) {
        for entry in entries {
            if entry.post_id == postId {
                
                entry.is_like = true
                var likesInt = entry.total_likes?.toInt()
                likesInt!++
                entry.total_likes = String(likesInt!)
            }
        }
    }
    
    func incrementComment(postId: String) {
        for entry in entries {
            if entry.post_id == postId {
                
                var commentsInt = entry.total_comments?.toInt()
                commentsInt!++
                entry.total_comments = String(commentsInt!)
            }
        }
    }
}