// CWID:     897709721
// Question: 3.1

import Kitura
import Cocoa

let router = Router()

router.all("/PersonService/add", middleware: BodyParser())

router.get("/"){
    request, response, next in
    response.send("Hello! Welcome to visit the service. ")
    next()
}

router.get("PersonService/getAll"){
    request, response, next in
    let pList = PersonDao().getAll()
    // JSON Serialization
    let jsonData : Data = try JSONEncoder().encode(pList)
    //JSONArray 
    let jsonStr = String(data: jsonData, encoding: .utf8)
    // set Content-Type
    response.status(.OK)
    response.headers["Content-Type"] = "application/json"
    response.send(jsonStr)
    // response.send("getAll service response data : \(pList.description)")
    next()
}

router.post("PersonService/add") {
    request, response, next in
    // JSON deserialization on Kitura server 
    let body = request.body
    let jObj = body?.asJSON //JSON object
    if let jDict = jObj as? [String:String] {
        if let fn = jDict["firstName"],let ln = jDict["lastName"],let n = jDict["ssn"] {
            let pObj = Person(fn:fn, ln:ln, n:n)
            PersonDao().addPerson(pObj: pObj)
        }
    }
    response.send("The Person record was successfully inserted (via POST Method).")
    next()
}

// Q.3.1
router.post("PersonService/addList") {
    request, response, next in
    if let parts = request.body?.asMultiPart {
        for part in parts {
            let jObj = part.body.asJSON
            if let jDict = jObj as? [String:String] {
                if let fn = jDict["firstName"],let ln = jDict["lastName"],let n = jDict["ssn"] {
                    let pObj = Person(fn:fn, ln:ln, n:n)
                    PersonDao().addPerson(pObj: pObj)
                }
            }
        }
    }
    response.send("The Person list was successfully inserted (via POST Method).")
    next()
}

router.get("/PersonService/add") {
    request, response, next in
    let fn = request.queryParameters["FirstName"]
    let ln = request.queryParameters["LastName"]
    //
    // let n = ....
    // if n != nil {
    // ... }
    if let n = request.queryParameters["SSN"] {
        let pObj = Person(fn:fn, ln:ln, n:n)
        PersonDao().addPerson(pObj: pObj)
        response.send("The Person record was successfully inserted.")
    } else {
        
    }
    next() 
}

Kitura.addHTTPServer(onPort: 8020, with: router)
Kitura.run()

