//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by 1203 Broadway on 9/6/21.
//

import Foundation

class UdacityClient {
    
    struct Auth {
        static var students = [Student]()
        static var sessionId = ""
        static var deleteSessionResponse: DeleteSessionResponse! // not required, but stored for future use
    }
    
    enum EndPoints {
        case postSession
        case deleteSession
        
        var urlString: String {
            switch self {
            case .postSession:
                return "https://onthemap-api.udacity.com/v1/session"
            case .deleteSession:
                return "https://onthemap-api.udacity.com/v1/session"
            }
        }
        
        var url: URL {
            return URL(string: urlString)!
        }
    }
    
    class func getStudents(completion: @escaping (Bool, Error?) -> Void) {
        let request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/StudentLocation?order=-updatedAt&limit=5")!)
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
                Auth.sessionId = responseObject.session.sessionId
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
        
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
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
