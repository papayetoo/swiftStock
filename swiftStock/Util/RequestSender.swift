//
//  RequestSender.swift
//  swiftStock
//
//  Created by 최광현 on 2021/01/16.
//

import Foundation

// MARK: URL로 request 보내는 싱글톤 클래스
class RequestSender {
    // 싱글톤 객체 생성
    static let shared = RequestSender()
    private let session: URLSession = URLSession.shared
    private let jsonEncoder: JSONEncoder = JSONEncoder()
    // MARK: 싱글톤 객체 생성자
    // 싱글톤 유지 위해 init을 private로
    private init() {}

    func send<T>(url: URL, httpMethod: HttpMethod, data: T,
                 completionHandler: @escaping ((Data) -> Void)) where T: Encodable {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        do { request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("Mobile/iPhone", forHTTPHeaderField: "User-Agent")
            request.httpBody = try self.jsonEncoder.encode(data)
        } catch let err {
            print(err.localizedDescription)
        }
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print(error?.localizedDescription)
                return
            }
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                return
            }

            completionHandler(data)
        }
        task.resume()
    }
}

enum HttpMethod: String {
    case post = "POST"
    case get = "GET"
}
