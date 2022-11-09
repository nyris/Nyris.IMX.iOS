//
//  FeedbackService.swift
//  NyrisSDK
//
//  Created by MOSTEFAOUIM on 08/11/2022.
//  Copyright © 2022 nyris. All rights reserved.
//

import Foundation

public enum EventType {
    case click(positions:[Int], productIds:[String])
    var name:String {
        switch self {
        case .click:
            return "click"
        
        }
    }
    var data:[String: Any] {
        switch self {
        case .click(let positions, let productIds):
            return [
                "product_ids": productIds,
                "positions": positions
            ]
        
        }
    }
}

//public enum TimeZone {
//    case utc(date: Date)
//
//    func formatedString() {
//        if case .utc(let date) = self {
//            return ""
//        }
//        return ""
//    }
//}

public final class FeedbackService : BaseService {
    
    private let contentType = "application/event+json"
    private let feedbackDispatchQueue:DispatchQueue = DispatchQueue(label: "com.nyris.feedbackQueue", qos: .background)
    
    public func sendEvent(eventType: EventType,
                          timestamp: String,
                          requestID: String,
                          sessionID: String, completion: @escaping (_ result: Result<String>) -> Void) {
        
        if let error = self.checkForError() {
            completion(.error(error: error, json: nil))
            return
        }
        
        guard !requestID.isEmpty || !sessionID.isEmpty else {
            completion(.error(error: RequestError.invalidInput(message: "sessionID or requestID are missing"), json: nil))
            return
        }
        guard !timestamp.isEmpty else {
            completion(.error(error: RequestError.invalidInput(message: "Timestamp is not provided"), json: nil))
            return
        }
        
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        guard let validDate = dateFormatter.date(from: timestamp) else {
            completion(.error(error: RequestError.invalidInput(message: "Timestamp is not valid"), json: nil))
            return
        }
        
        var request = URLRequest(url: API.feedback.endpoint(provider: self.endpointProvider))
        request.setValue(self.contentType, forHTTPHeaderField: "Content-Type")
        request.httpMethod = API.feedback.method
        let feedbackData: [String : Any] = [
            "request_id": requestID,
            "session_id": sessionID,
            "timestamp": timestamp,
            "event": eventType.name,
            "data": eventType.data
        ]
        do {
            let json = try JSONSerialization.data(withJSONObject: feedbackData, options: [])
            let str = String(decoding: json, as: UTF8.self)
            request.httpBody = json
        } catch {
            completion(.error(error: RequestError.invalidData(message: "The event Data resulted into an invalid json"), json: nil))
        }

        self.feedbackDispatchQueue.async {
            let task = self.jsonTask.execute(request: request, onSuccess: { data in
                completion(.success(""))
            }, onFailure: { (error, json) in
                completion(.error(error: error, json: json))
            })
            
            self.currentTask = task
            task?.resume()
        }
    }
}
