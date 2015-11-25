//
//  NetworkManager.swift
//  Roomguru
//
//  Created by Radoslaw Szeja on 12/03/15.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import Async

final class NetworkManager: NSObject {
    
    var clientID = ""
    private var key: String { return "?key=" + clientID }
    
    private var tokenStore: GIDTokenStore?
    
    class var sharedInstance: NetworkManager {
        struct Static {
            static let instance = NetworkManager()
        }
        
        return Static.instance
    }
    
    // Enable token store AFTER receiving auth from Google
    func enableTokenStore(enable: Bool = true, auth: GIDAuthentication? = nil) {
        tokenStore = (enable && auth != nil) ? GIDTokenStore(auth: auth!) : nil
    }
    
    func request<Queryable: Query>(var request: Request<Queryable>, success: ResponseBlock, failure: ErrorBlock) {
        
        refreshTokenWithFailure(failure) {
            request.resume(success, failure: failure)
        }
    }
    
    /**
    Executes requests with provided queries. Number of request matches number of queries.
    Each request result has to conform to ModelJSONProtocol. The final result can be of any type.
    
    :param: queries is an array of PageableQuery to be perform one after another, ordered as provided
    :param: construct a block where results from each request can be processed, or transformed to some other type, and returned
    :param: success a block invoked if every request was succesful
    :param: failure a block invoked if error occur
    */
    func chainedRequest<T: ModelJSONProtocol, U>(queries: [PageableQuery], construct: (PageableQuery, [T]?) -> [U], success: [U]? -> Void, failure: ErrorBlock) {
        
        refreshTokenWithFailure(failure) {
            
            var result: [U] = []
            var requestError: NSError?
            
            let queue: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            let group: dispatch_group_t = dispatch_group_create();
            
            for query in queries {
                dispatch_group_enter(group)
                
                self.requestList(query, success: { (response: [T]?)  in
                    result += construct(query, response)
                    dispatch_group_leave(group)
                    
                    }, failure: { error in
                        requestError = error
                        dispatch_group_leave(group)
                })
            }
            
            dispatch_group_notify(group, queue) {
                if let requestError = requestError {
                    failure(error: requestError)
                } else {
                    success(result)
                }
            }
        }
    }
}

private extension NetworkManager {
    
    func requestList<T: ModelJSONProtocol>(query: PageableQuery, success: (response: [T]?) -> (), failure: ErrorBlock) {
        
        query.setFullPath(self.serverURL, authKey: self.key)
        PageableRequest<T>(query).resume(success, failure)
    }
    
    func refreshTokenWithFailure(failure: ErrorBlock, success: VoidBlock) {
        
        if let currentUser = GIDSignIn.sharedInstance().currentUser {
            currentUser.authentication.refreshTokensWithHandler { (auth, error) in
                if let error = error {
                    failure(error: error)
                    
                } else {
                    success()
                }
            }
        }
    }
}
