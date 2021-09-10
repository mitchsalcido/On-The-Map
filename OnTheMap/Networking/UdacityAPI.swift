//
//  UdacityAPI.swift
//  OnTheMap
//
//  Created by 1203 Broadway on 9/6/21.
//
/*
 About UdacityAPI:
 Handle Udacity API network interaction. Store student(s) location info
 */

import Foundation

class UdacityAPI {

    // user(person using app and logged in) info for simulating student location...polulate with pseudo-info for security
    // Upon retieving user data (get PublicUserData). This struct will be partially overwritten with random student data
    // supplied by Udacity intended to mmic an actual student... for security
    static var userStudentLocation = StudentLocationRequest(uniqueKey: UdacityAPI.Auth.key, firstName: "Engelbert", lastName: "Humperdinck", mapString: "Leicester England", mediaURL: "https://www.engelbert.com", latitude: 52.63333, longitude: -1.13333)

    // storage for students on the map..filled in when getStudents invoked
    static var students = [StudentInformation]()

    // login and auth info credentials
    struct Auth {
        static var key = ""             // used as uniqueKey for posting StudentLocation..retreived at login
        static var objectId: String?    // to detect put(update) student location..retrieved at posting of location
        static var deleteSessionResponse: DeleteSessionResponse! // response data from deleteSession
    }
    
    // URL endpoints
    enum EndPoints {
        case getStudents
        case postSession
        case deleteSession
        case postLocation
        case putLocation
        case publicUserData
        
        // create url string
        var urlString: String {
            switch self {
            case .getStudents:
                return "https://onthemap-api.udacity.com/v1/StudentLocation?order=-updatedAt&limit=100"
            case .postSession:
                return "https://onthemap-api.udacity.com/v1/session"
            case .deleteSession:
                return "https://onthemap-api.udacity.com/v1/session"
            case .postLocation:
                return "https://onthemap-api.udacity.com/v1/StudentLocation"
            case .putLocation:
                return "https://onthemap-api.udacity.com/v1/StudentLocation" + "/\(Auth.objectId!)"
            case .publicUserData:
                return "https://onthemap-api.udacity.com/v1/users/3903878747"
            }
        }
        
        // create url
        var url: URL {
            return URL(string: urlString)!
        }
    }
    
    // update location
    class func putLocation(studentLocation: StudentLocationRequest, completion: @escaping (Bool, Error?) -> Void) {
        /*
         API function to update user location
         */
        taskForPUT(url: EndPoints.putLocation.url, body: studentLocation, responseType: UpdateStudentLocationResponse.self) {
            (response, error) in
            guard let _ = response else {
                completion(false, error)
                return
            }
            // return data is unused. Only required to verify good respose decode
            completion(true, nil)
        }
    }
    
    // post location
    class func postLocation(studentLocation: StudentLocationRequest, completion: @escaping (Bool, Error?) -> Void) {
        /*
         API function for initial post of user location
         */
        taskForPOST(url: EndPoints.postLocation.url, httpHeaderValues: nil, body: studentLocation, responseType: StudentLocationResponse.self) {
            (response, error) in
            
            guard let response = response else {
                completion(false, error)
                return
            }
            
            // save objectId. Use to build body object in putLocation function..reference to student
            Auth.objectId = response.objectId
            completion(true, nil)
        }
    }
    
    // get students who have posted their locations
    class func getStudents(completion: @escaping (Bool, Error?) -> Void) {
        /*
         API function to retrieve list of students who have posted/updated their locations
         */
        taskForGet(url: EndPoints.getStudents.url, responseType: StudentResultsResponse.self) {
            (response, error) in
            
            guard let response = response else {
                completion(false, error)
                return
            }
            
            // overwrite and update students data array
            students.removeAll()
            for student in response.results {
                students.append(student)
            }
            completion(true, nil)
        }
    }
    
    // get user data (user is person currently using app)
    class func getPublicUserData(completion: @escaping (Bool, Error?) -> Void) {
        /*
         API function to retrieve user data (user is person using this app and logged in)
         */
        taskForGet(url: EndPoints.publicUserData.url, responseType: DataResponse.self) {
            (response, error) in
            
            guard let response = response else {
                completion(false, error)
                return
            }
            
            // Update userStudentLocation object with new data
            // response.data is a data object requiring deserialization into a [String:Any] dictionary
            do {
                let json = try JSONSerialization.jsonObject(with: response.data, options: []) as! [String:Any]
                if let firstName = json["first_name"] as? String {
                    userStudentLocation.firstName = firstName
                }
                if let lastName = json["last_name"] as? String {
                    userStudentLocation.lastName = lastName
                }
                if let mediaURL = json["_image_url"] as? String {
                    userStudentLocation.mediaURL = mediaURL
                }
                completion(true, nil)
            } catch {
                completion(false, error)
            }
        }
    }
    
    // post a new session (log in to Udacity)
    class func postSession(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        /*
         API function to post a new session. This is the log in process
         */
        let header = ["Accept":"application/json"]
        let userRequest = SessionUserInfo(username: username, password: password)
        let sessionRequest = PostSessionRequest(udacity: userRequest)
        
        taskForPOST(url: EndPoints.postSession.url, httpHeaderValues: header, body: sessionRequest, responseType: PostSessionResponse.self) {
            (response, error) in
            
            guard let response = response else {
                completion(false, error)
                return
            }
            
            // store credential. Required to post location
            Auth.key = response.account.key
            completion(true, nil)
        }
    }
    
    // From Udacity class material, some modification
    class func deleteSession(completion: @escaping (Bool, Error?) -> Void) {
        /*
         Per Udacity class materials, function to delete a session. Used
         as "logout" function... modifying from Udacity class material by
         adding function "taskDecode" to handle dataTask response 
         */
        var request = URLRequest(url: EndPoints.deleteSession.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
          if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
          request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        taskDecode(request: request, responseType: DeleteSessionResponse.self) {
            (response, error) in
            
            guard let response = response else {
                completion(false, error)
                return
            }
            
            // save response object
            Auth.deleteSessionResponse = response
            completion(true, nil)
        }
    }
}

// MARK: Helpers
extension UdacityAPI {
    
    // PUT request
    class func taskForPUT<RequestType: Encodable, ResponseType: Decodable>(url: URL, body: RequestType, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        /*
         Handle PUT request. Request/Response objects are Encodable/Decobale objects
         */
        
        // create request, populate
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // create/add RequestType body
        do {
            let body = try JSONEncoder().encode(body)
            request.httpBody = body
        } catch {
            DispatchQueue.main.async {
                completion(nil, error)
            }
        }
        
        // perform data task and handle response
        taskDecode(request: request, responseType: responseType, completion: completion)
    }
    
    // POST request
    class func taskForPOST<RequestType: Encodable, ResponseType: Decodable>(url: URL, httpHeaderValues:[String:String]?, body: RequestType, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        /*
         Handle POST request. Request/Response objects are Encodable/Decobale objects
         */
        
        // create request, populate
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // additional header values, if any
        if let values = httpHeaderValues {
            for (key, value) in values {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        // create/add RequestType body
        do {
            let body = try JSONEncoder().encode(body)
            request.httpBody = body
        } catch {
            DispatchQueue.main.async {
                completion(nil, error)
            }
        }
        
        // perform data task and handle response
        taskDecode(request: request, responseType: responseType, completion: completion)
    }
    
    // GET request
    class func taskForGet<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        /*
         Handle POST request. Request/Response objects are Encodable/Decobale objects
         */
        
        // create request, populate
        let request = URLRequest(url: url)
        
        // perform data task and handle response
        taskDecode(request: request, responseType: responseType, completion: completion)
    }
    
    // invoke data task, decode response and invoke completion
    class func taskDecode<ResponseType: Decodable>(request: URLRequest, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
        /*
         Handle dataTask. Creates a dataTask and resume()'s. Returned data (task closure) is
         decoded into proper response object. The response object is passed into completion, or
         set to nil if error during the decode process.
         */
        
        // new data task
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            // decode data into response object
            do {
                let object = try JSONDecoder().decode(responseType.self, from: data)
                DispatchQueue.main.async {
                    completion(object, nil)
                }
            } catch {
                /* Workaround to pull data that might be shifted right by (5) bytes
                 test for data shifted (5) bytes, per udacity class materials.
                 Perform two more attempts. Last attempt test for data resolving to [String:Any]
                */
                let data = data.subdata(in: 5..<data.count)
                do {
                    // trying again for valid decode
                    let object = try JSONDecoder().decode(responseType.self, from: data)
                    DispatchQueue.main.async {
                        completion(object, nil)
                    }
                } catch {
                    do {
                        // failed. Try one last time, testing for decoding into [String:Any]
                        let _ = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                        let object = DataResponse(data: data)
                        DispatchQueue.main.async {
                            completion(object as? ResponseType, nil)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completion(nil, error)
                        }
                    }
                }
            }
        }
        task.resume()
    }
}
