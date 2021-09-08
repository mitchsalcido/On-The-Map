//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by 1203 Broadway on 9/6/21.
//

import Foundation

class UdacityClient {

    static var userStudentLocation = StudentLocationRequest(uniqueKey: UdacityClient.Auth.key, firstName: "Engelbert", lastName: "Humperdinck", mapString: "Leicester England", mediaURL: "https://www.engelbert.com", latitude: 52.63333, longitude: -1.13333)

    struct Auth {
        static var students = [StudentInformation]()
        static var key = ""     // used as uniqueKey for posting StudentLocation..retreived at login
        static var objectId: String?    // used to put(update) student location..retrieved at initial posting of location
        static var deleteSessionResponse: DeleteSessionResponse! // not required, but stored for future use
    }
    
    enum EndPoints {
        case getStudents
        case postSession
        case deleteSession
        case postStudentLocation
        case updateStudentLocation
        case publicUserData
        
        var urlString: String {
            switch self {
            case .getStudents:
                return "https://onthemap-api.udacity.com/v1/StudentLocation?order=-updatedAt&limit=5"
            case .postSession:
                return "https://onthemap-api.udacity.com/v1/session"
            case .deleteSession:
                return "https://onthemap-api.udacity.com/v1/session"
            case .postStudentLocation:
                return "https://onthemap-api.udacity.com/v1/StudentLocation"
            case .updateStudentLocation:
                return "https://onthemap-api.udacity.com/v1/StudentLocation" + "/\(Auth.objectId!)"
            case .publicUserData:
                return "https://onthemap-api.udacity.com/v1/users/3903878747"
            }
        }
        
        var url: URL {
            return URL(string: urlString)!
        }
    }
    
    class func getPublicUserData(completion: @escaping (Bool, Error?) -> Void) {
        let request = URLRequest(url: EndPoints.publicUserData.url)
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            let newData = data.subdata(in: 5..<data.count) /* subset response data! */
            do {
                let json = try JSONSerialization.jsonObject(with: newData, options: []) as! [String:Any]
                if let firstName = json["first_name"] as? String {
                    userStudentLocation.firstName = firstName
                }
                if let lastName = json["last_name"] as? String {
                    userStudentLocation.lastName = lastName
                }
                if let mediaURL = json["_image_url"] as? String {
                    userStudentLocation.mediaURL = mediaURL
                }
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, nil)
                }
            }
        }
        task.resume()
    }
    
    class func updateStudentLocation(studentLocation: StudentLocationRequest, completion: @escaping (Bool, Error?) -> Void) {
        
        var request = URLRequest(url: EndPoints.updateStudentLocation.url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let json = try JSONEncoder().encode(studentLocation)
            request.httpBody = json
        } catch {
            DispatchQueue.main.async {
                completion(false, error)
            }
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            do {
                let responseObject = try JSONDecoder().decode(UpdateStudentLocationResponse.self, from: data)
                print(responseObject)
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
        task.resume()
    }
    
    class func postStudentLocation(studentLocation: StudentLocationRequest, completion: @escaping (Bool, Error?) -> Void) {
        
        var request = URLRequest(url: EndPoints.postStudentLocation.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let json = try JSONEncoder().encode(studentLocation)
            request.httpBody = json
        } catch {
            DispatchQueue.main.async {
                completion(false, error)
            }
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            do {
                let responseObject = try JSONDecoder().decode(StudentLocationResponse.self, from: data)
                Auth.objectId = responseObject.objectId
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
        task.resume()
    }
    
    class func getStudents(completion: @escaping (Bool, Error?) -> Void) {
        
        let request = URLRequest(url: EndPoints.getStudents.url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            do {
                let responseObject = try JSONDecoder().decode(StudentResultsResponse.self, from: data)
                let resultsArray = responseObject.results
                Auth.students.removeAll()
                for student in resultsArray {
                    Auth.students.append(student)
                }
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
        task.resume()
    }
    
    class func postSession(username: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        
        var request = URLRequest(url: EndPoints.postSession.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let userRequest = SessionUserInfo(username: username, password: password)
        let sessionRequest = PostSessionRequest(udacity: userRequest)
        var jsonData: Data!
        do {
            jsonData = try JSONEncoder().encode(sessionRequest)
        } catch {
            completion(false, error)
            return
        }
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            guard let data = data else {
                completion(false, error)
                return
            }
            
            let range = 5..<data.count
            let newData = data.subdata(in: range) /* subset response data! */
            
            do {
                let responseObject = try JSONDecoder().decode(PostSessionResponse.self, from: newData)
                Auth.key = responseObject.account.key
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch {
                do {
                    let errorResponse = try JSONDecoder().decode(PostSessionErrorResponse.self, from: newData)
                    DispatchQueue.main.async {
                        completion(false, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(false, error)
                    }
                }
            }
        }
        task.resume()
    }
    
    class func deleteSession(completion: @escaping (Bool, Error?) -> Void) {
        
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
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }
            
            let range = 5..<data.count
            let newData = data.subdata(in: range) /* subset response data! */

            do {
                let responseObject = try JSONDecoder().decode(DeleteSessionResponse.self, from: newData)
                Auth.deleteSessionResponse = responseObject
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
        task.resume()
    }
}
