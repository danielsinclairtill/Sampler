//
//  SamplerAPI.swift
//  Sampler
//
//
//

import Foundation
import Network
import Alamofire

class SamplerAPI: APIContract {
    let baseUrl = "https://dummyjson.com"
    let imageManager: ImageManagerContract = SamplerAPIImageManager()
    
    func isConnectedToInternet() -> Bool {
        NetworkReachabilityManager()?.isReachable ?? false
    }
    
    func get<R>(request: R, result: ((Result<R.Response, APIError>) -> Void)?) where R : APIRequestContract {
        guard var url = URLComponents(string: baseUrl + request.path) else {
            assertionFailure("url for api request was not formatted correctly")
            result?(.failure(.serverError))
            return
        }
        
        url.queryItems = request.parameters?.map({ key, value in
            URLQueryItem(name: key, value: value)
        })
        
        guard let url = url.url else {
            assertionFailure("url for api request was not formatted correctly")
            result?(.failure(.serverError))
            return
        }
        let urlRequest = URLRequest(url: url, timeoutInterval: request.timeoutInterval)
        
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: urlRequest) { data, response, error in
            if let error = error as? URLError {
                if error.code == .notConnectedToInternet || error.code == .timedOut {
                    result?(.failure(.lostConnection))
                } else {
                    result?(.failure(.serverError))
                }
                return
            }
            
            if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                result?(.failure(.serverError))
                return
            }
            
            guard let data = data else {
                result?(.failure(.serverError))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let data = try decoder.decode(R.Response.self, from: data)
                result?(.success(data))
            }
            catch {
                result?(.failure(.serverError))
            }
        }
        task.resume()
    }
}
