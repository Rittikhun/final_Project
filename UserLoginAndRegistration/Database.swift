//
//  Database.swift
//  sqlLite
//
//  Created by iOS Dev on 11/14/2559 BE.
//  Copyright © 2559 iOS Dev. All rights reserved.
//

import Foundation

class Database {
    
    fileprivate var databasePathString:String! = nil
    
    fileprivate var database:OpaquePointer? = nil
    
    struct Memo {
        
        var username: String = ""
        
        var name: String = ""
        
        var password: String = ""
        
    }
    
    struct friend {
        
        var username: String = ""
        
        var friendusername: String = ""
        
    }
    
    struct property {
        
        static var shareInstance: Database! = nil
        
    }
    
    fileprivate init() {
        
        
        
    }
    
    static fileprivate func createDB() -> Bool {
        
        let db = Database()
        
        var isSuccess:Bool = true;
        
        let fm = FileManager.default
        
        //Get Documents url
        do {
            print("kuyaum")
            let docsurl = try fm.url(
                for: FileManager.SearchPathDirectory.documentDirectory,
                in: FileManager.SearchPathDomainMask.userDomainMask,
                appropriateFor: nil, create: true)
            
            // Creat folder
            let myFolderUrl = docsurl.appendingPathComponent("Database")
            try fm.createDirectory(at: myFolderUrl,
                                   withIntermediateDirectories: true,
                                   attributes: nil)
            // Create path to database file
            let myDbFileUrl = myFolderUrl.appendingPathComponent("projectios.sqlite")
            db.databasePathString = myDbFileUrl.path
            
            print(myDbFileUrl)
            
            if(!fm.fileExists(atPath: db.databasePathString)){
                print("dsadjklasdaskldjasldkasjdklas;djsalkdj")
                // Db File not exists.  Lets make one
                if(sqlite3_open(db.databasePathString, &db.database) == SQLITE_OK){
                    var errMSG:UnsafeMutablePointer<Int8>? = nil
                    
                    let text =
                    "CREATE TABLE \"user\" (\"email\" TEXT PRIMARY KEY  NOT NULL , \"password\" TEXT, \"name\" TEXT)"
                    let sql_stmt = text.cString(using: String.Encoding.utf8);
                    
                    if(sqlite3_exec(db.database, sql_stmt!, nil, nil, &errMSG)
                        != SQLITE_OK){
                        isSuccess = false
                        NSLog("Failed to create memo table")
                    }
                    
                    sqlite3_close(db.database);
                    
                    // Store shared when successful
                    property.shareInstance = db;
                }else{
                    
                    isSuccess = false
                    NSLog("Failed to open/create database");
                }
            }else{
                property.shareInstance = db;
            }
        }catch{
            
        }
        return isSuccess
        
        
    }
    
    static func getSharedInstance() -> Database{
        if (property.shareInstance == nil) {
            createDB();
        }
        
        return property.shareInstance
    }
    
    // Create record and return the record number
    func addNote(_ name:String, username:String, password:String) -> Int{
        var recordNumber:Int = 1;
        var statement:OpaquePointer? = nil;
        print("no eiei")
        if (sqlite3_open(self.databasePathString, &self.database) == SQLITE_OK) {
            
            }
            
        if (sqlite3_open(self.databasePathString, &self.database) == SQLITE_OK){
            print("eiei no")
            var errMsg:UnsafeMutablePointer<Int8>? = nil
            
            let insertSQL =
                "INSERT INTO USER (EMAIL, PASSWORD, NAME) VALUES (\"" + name + "\",\"" + username + "\",\"" + password + "\")"
            var sql_stmt = insertSQL.cString(using: String.Encoding.utf8)
            
            if (sqlite3_exec(self.database, sql_stmt!, nil, nil, &errMsg)
                != SQLITE_OK){
                NSLog("Failed to insert into memo table ");
            }else{
                // Get the latest record number
                let lookupSQL = "SELECT MAX(username) FROM user"
                sql_stmt = lookupSQL.cString(using: String.Encoding.utf8)
                
                sqlite3_prepare_v2(self.database, sql_stmt!, -1, &statement, nil);
                if (sqlite3_step(statement) == SQLITE_ROW)
                {
                    recordNumber = Int(sqlite3_column_int(statement, 0));
                }
                
                sqlite3_finalize(statement);
                sqlite3_close(database);
                print("ssuv")
            }
        }
        return recordNumber;
    }
//    
//    func countRecords() -> Int{
//        var recordNumber:Int = 1;
//        var statement:OpaquePointer? = nil;
//        
//        if (sqlite3_open(self.databasePathString, &self.database) == SQLITE_OK)
//        {
//            // Get the latest record number
//            let lookupSQL = "SELECT count(Record) FROM RecordSet"
//            let sql_stmt = lookupSQL.cString(using: String.Encoding.utf8)
//            
//            sqlite3_prepare_v2(self.database, sql_stmt!,-1, &statement, nil)
//            if (sqlite3_step(statement) == SQLITE_ROW){
//                recordNumber = Int(sqlite3_column_int(statement, 0));
//            }
//            
//            sqlite3_finalize(statement);
//            sqlite3_close(database);
//            
//        }
//        return recordNumber;
//    }
    
    func getNote(_ email:String) -> Memo{
        print("asds")
        var result:Memo = Memo();
        var statement:OpaquePointer? = nil;

        print(self.databasePathString)
        if (sqlite3_open(self.databasePathString, &self.database) == SQLITE_OK) {
            
            }
        
        if (sqlite3_open(self.databasePathString, &self.database) == SQLITE_OK){
            // Get the latest record number
            
            
            print(email)
            
            let lookupSQL = "SELECT email, password, name FROM  user WHERE email = \"" + email + "\""
            
            let sql_stmt = lookupSQL.cString(using: String.Encoding.utf8)
            
            sqlite3_prepare_v2(self.database, sql_stmt!,-1, &statement, nil)
            if (sqlite3_step(statement) == SQLITE_ROW){
                result.username = String(cString: UnsafePointer(sqlite3_column_text(statement, 0)))
                result.name = String(cString: UnsafePointer(sqlite3_column_text(statement, 2)))
                result.password = String(cString: UnsafePointer(sqlite3_column_text(statement, 1)))
                
            }
            
            sqlite3_finalize(statement);
            sqlite3_close(database);
        }
        return result;
    }
}



