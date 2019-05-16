//
//  APIController.swift
//  AnimalSpotter
//
//  Created by Moses Robinson on 5/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class APIController {
    
    private let baseURL = URL(string: "https://lambdaanimalspotter.vapor.cloud/api")!
    
    var bearer: Bearer?
    
    
    func signUp(with username: String, password: String, completion: @escaping (Error?) -> Void) {
        
        let requestURL = baseURL.appendingPathComponent("users").appendingPathComponent("signup")
        
        var request = URLRequest(url: requestURL)
        
        request.httpMethod = HTTPMethod.post.rawValue
        
        // the body of our request is JSON.
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let user = User(username: username, password: password)
        
        do {
            request.httpBody = try JSONEncoder().encode(user)
        } catch {
            NSLog("Error encoding User: \(error)")
            completion(nil)
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: request) { (_, response, error) in
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                
                // Something went wrong
                completion(NSError())
                return
            }
            
            if let error = error {
                NSLog("Error signing up: \(error)")
                completion(error)
                return
            }
            
            completion(nil)
        }
        dataTask.resume()
    }
    
    func logIn(with username: String, password: String, completion: @escaping (Error?) -> Void ) {
        
        let requestURL = baseURL.appendingPathComponent("users").appendingPathComponent("login")
        
        var request = URLRequest(url: requestURL)
        
        request.httpMethod = HTTPMethod.post.rawValue
        
        // the body of our request is JSON.
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let user = User(username: username, password: password)
        
        do {
            request.httpBody = try JSONEncoder().encode(user)
        } catch {
            NSLog("Error encoding User: \(error)")
            completion(nil)
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                
                // Something went wrong
                completion(NSError())
                return
            }
            
            if let error = error {
                NSLog("Error logging up: \(error)")
                completion(error)
                return
            }
            
            // Get the bearer token by decoding it.
            
            guard let data = data else {
                NSLog("No data returnd from data task")
                completion(NSError())
                return
            }
            
            let jsonDecoder = JSONDecoder()
            
            do {
                
                let bearer = try jsonDecoder.decode(Bearer.self, from: data)
                
                // We now have the bearer to authenticate the other requests
                self.bearer = bearer
                completion(nil)
                
            } catch {
                NSLog("Error decoding Bearer: \(error)")
                completion(error)
                return
            }
        }
        dataTask.resume()
    }
    
    func getAllAnimalNames(completion: @escaping (Result<[String], NetworkError>) -> Void) {
        
        guard let bearer = bearer else {
            NSLog("No bearer token available")
            completion(.failure(.noBearer))
            return
        }
        
        let requestURL = baseURL
            .appendingPathComponent("animals")
            .appendingPathComponent("all")
        
        var request = URLRequest(url: requestURL)
        
        // If the method is GET, there is no body.
        request.httpMethod = HTTPMethod.get.rawValue
        
        // This is out method of authenticating with the API.
        request.addValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let response = response as? HTTPURLResponse,
                response.statusCode == 401 {
                completion(.failure(.badAuth))
                return
            }
            
            if let error = error {
                NSLog("Error getting animal names: \(error)")
                completion(.failure(.apiError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noDataReturned))
                return
            }
            
            let jsonDecoder = JSONDecoder()
            
            do {
                
                let animalNames = try jsonDecoder.decode([String].self, from: data)
                completion(.success(animalNames))
    
            } catch {
                NSLog("Error decoding animal names: \(error)")
                completion(.failure(.noDecode))
            }
            
        }
        dataTask.resume()
    }
    
    enum NetworkError: Error {
        case noDataReturned
        case noBearer
        case badAuth
        case apiError
        case noDecode
    }
    
    enum HTTPMethod: String {
        case get = "GET"
        case put = "PUT"
        case post = "POST"
        case delete = "DELETE"
    }
}
