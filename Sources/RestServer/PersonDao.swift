//
//  PersonDao.swift
//  RestServer
//
//  Created by ITLoaner on 9/24/20.
//

import SQLite3

// Textbook uses JSONSerialization API (in Foundation module)
// JSONEncoder/JSONDecoder

struct Person : Codable {
    var firstName : String?
    var lastName : String?
    var ssn : String
    
    init(fn : String?, ln:String?, n: String) {
        firstName = fn
        lastName = ln
        ssn = n
    }
}

class PersonDao {
    
    func addPerson(pObj : Person) {
        let sqlStmt = String(format:"insert into person (first_name, last_name, ssn) values ('%@', '%@', '%@')", (pObj.firstName)!, (pObj.lastName)!, pObj.ssn)
        // get database connection
        let conn = Database.getInstance().getDbConnection()
        // submit the insert sql statement
        if sqlite3_exec(conn, sqlStmt, nil, nil, nil) != SQLITE_OK {
            let errcode = sqlite3_errcode(conn)
            print("Failed to insert a Person record due to error \(errcode)")
        }
        // close the connection 
        sqlite3_close(conn)
    }
    
    func getAll() -> [Person] {
        var pList = [Person]()
        var resultSet : OpaquePointer?
        let sqlStr = "select first_name, last_name, ssn from person"
        let conn = Database.getInstance().getDbConnection()
        if sqlite3_prepare_v2(conn, sqlStr, -1, &resultSet, nil) == SQLITE_OK {
            while(sqlite3_step(resultSet) == SQLITE_ROW) {
                // Convert the record into a Person object
                // Unsafe_Pointer<CChar> Sqlite3
                let fn_val = sqlite3_column_text(resultSet, 0)
                let fn = String(cString: fn_val!)
                let ln_val = sqlite3_column_text(resultSet, 1)
                let ln = String(cString: ln_val!)
                let ssn_val = sqlite3_column_text(resultSet, 2)
                let ssn = String(cString: ssn_val!)
                pList.append(Person(fn:fn, ln:ln, n:ssn))
            }
        }
        return pList
    }
}
