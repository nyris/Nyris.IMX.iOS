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
    case conversion(positions:[Int], productIds:[String])
    case feedback(success: Bool, comment:String)
    case region(rect: CGRect)
    
    var name:String {
        switch self {
        case .click:
            return "click"
        case .conversion:
            return "conversion"
        case .feedback:
            return "feedback"
        case .region:
            return "region"
        
        }
    }
    var data:[String: Any] {
        switch self {
        case .click(let positions, let productIds),
             .conversion(let positions, let productIds):
            return [
                "product_ids": productIds,
                "positions": positions
            ]
        case .feedback(let success, let comment):
            return [
                "success": success,
                "comment": comment
            ]
        case .region(let rect):
            return [
                "rect": [
                    "x": rect.origin.x,
                    "y": rect.origin.y,
                    "w": rect.size.width,
                    "h": rect.size.height
                ]
            ]
        }
    }
}

public final class FeedbackService : BaseService {
    
    private let contentType = "application/event+json"
    private let feedbackDispatchQueue:DispatchQueue = DispatchQueue(label: "com.nyris.feedbackQueue", qos: .background)
    
    /**
        
     */
    public func sendEvent(eventType: EventType,
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
        
        if  case .region(let rect) = eventType, !rect.isNormalized() {
            completion(.error(error: RequestError.invalidInput(message: "Rect is not normalized"), json: nil))
            return
        }
    
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        let timestamp = dateFormatter.string(from: Date())
        guard !timestamp.isEmpty else {
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
