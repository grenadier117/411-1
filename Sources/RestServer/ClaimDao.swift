//
//  ClaimDao.swift
//  RestServer
//
//  Created by ITLoaner on 9/24/20.
//

import SQLite3
import Foundation

// Textbook uses JSONSerialization API (in Foundation module)
// JSONEncoder/JSONDecoder

extension Bool {
    func toInt() -> Int {
        return self ? 1 : 0
    }
}

struct Claim : Codable {
    var id : UUID
    var title : String
    var date : String
    var isSolved: Bool
    
    init(title: String, date: String) {
        self.id = UUID()
        self.title = title
        self.date = date
        self.isSolved = false
    }
    
    init(id: String, title: String, date: String, isSolved: Int) {
        self.id = UUID(uuidString: id)!
        self.title = title
        self.date = date
        self.isSolved = isSolved != 0
    }
}

class ClaimDao {
    
    func addClaim(pObj : Claim) {
        let sqlStmt = String(format:"insert into claims (id, title, date, isSolved) values ('%@', '%@', '%@', %i)", pObj.id.uuidString, pObj.title, pObj.date, pObj.isSolved.toInt())
        // get database connection
        let conn = Database.getInstance().getDbConnection()
        // submit the insert sql statement
        if sqlite3_exec(conn, sqlStmt, nil, nil, nil) != SQLITE_OK {
            let errcode = sqlite3_errcode(conn)
            print("Failed to insert a Claims record due to error \(errcode)")
        }
        // close the connection 
        sqlite3_close(conn)
    }
    
    func getAll() -> [Claim] {
        var pList = [Claim]()
        var resultSet : OpaquePointer?
        let sqlStr = "select id, title, date, isSolved from claims"
        let conn = Database.getInstance().getDbConnection()
        if sqlite3_prepare_v2(conn, sqlStr, -1, &resultSet, nil) == SQLITE_OK {
            while(sqlite3_step(resultSet) == SQLITE_ROW) {
                // Convert the record into a Claim object
                let id = sqlite3_column_text(resultSet, 0)
                let idStr = String(cString: id!)
                let title = sqlite3_column_text(resultSet, 1)
                let titleStr = String(cString: title!)
                let date = sqlite3_column_text(resultSet, 2)
                let dateStr = String(cString: date!)
                let isSolved = sqlite3_column_int(resultSet, 3)
                pList.append(Claim(id: idStr, title: titleStr, date: dateStr, isSolved: Int(isSolved)))
            }
        }
        return pList
    }
}
