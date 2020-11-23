// CWID:     897709721
// Question: 3.1

import Kitura
import Cocoa

let router = Router()

router.all("/ClaimsService/add", middleware: BodyParser())

router.get("/"){
    request, response, next in
    response.send("Hello! Welcome to visit the service. ")
    next()
}

router.get("ClaimsService/getAll"){
    request, response, next in
    let pList = ClaimDao().getAll()
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

router.post("ClaimsService/add") {
    request, response, next in
    // JSON deserialization on Kitura server 
    let body = request.body
    let jObj = body?.asJSON //JSON object
    if let jDict = jObj {
        if let title = jDict["title"],
            let date = jDict["date"]
        {
            let pObj = Claim(title: "\(title)", date: "\(date)")
            ClaimDao().addClaim(pObj: pObj)
        }
    }
    response.send("The Person record was successfully inserted (via POST Method).")
    next()
}

Kitura.addHTTPServer(onPort: 8020, with: router)
Kitura.run()

