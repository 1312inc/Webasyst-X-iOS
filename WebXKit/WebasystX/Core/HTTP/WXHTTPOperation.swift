//
//  WXHTTPOperation.swift
//  WebasystX
//
//  Created by Administrator on 10.11.2020.
//

import Foundation

public typealias WXHTTPOperationCompletionBlock = (_ result: Data?, _ sender: Any?) -> Void
public typealias WXHTTPOperationErrorBlock = (_ error: NSError?, _ sender:Any?) -> Void
public typealias WXHTTPOperationProgressBlock = (_ result: Double) -> Void

enum WXOperationStatus: Int {
    case none
    case inProgress
    case done
    case failed
}

enum WXOperationError: Int {
    case http
    case invalidContentType
    case unknow
    case invalidConnectivity
    case startup
}

public class WXHTTPOperation: Operation {
    
    private var _opStatus: WXOperationStatus = .none
    
    // MARK: - Instance Properties
    public var tag: String!
    private var opUrl: URL!
    private var opError: NSError?
    private var opRequest: URLRequest!
    private var opDataTask: URLSessionDataTask?
    private var actualResponseBody:Data?

    public var opCompletionBlock: WXHTTPOperationCompletionBlock?
    public var opProgressBlock: WXHTTPOperationProgressBlock?
    public var opErrorBlock: WXHTTPOperationErrorBlock?
    public var opResponse:HTTPURLResponse?
    
    public var bodyStream: InputStream? {
        get {
            return self.opRequest.httpBodyStream
        }
        
        set {
            self.opRequest.httpBodyStream = newValue
        }
    }
    
    public var contentType: String? {
        get {
            return self.opRequest.allHTTPHeaderFields?["Content-Type"]
        }

        set {
            self.opRequest.allHTTPHeaderFields?["Content-Type"] = newValue
        }
    }

    public var contentLength: String? {
        get {
            return self.opRequest.allHTTPHeaderFields?["Content-Length"]
        }

        set {
            self.opRequest.allHTTPHeaderFields?["Content-Length"] = newValue
        }
    }
    
    public var allHeaders: [String: String]? {
        get {
            return self.opRequest.allHTTPHeaderFields
        }
        
        set {
            self.opRequest.allHTTPHeaderFields = newValue
        }
    }
    
    public var method: String? {
        get {
           return self.opRequest.httpMethod
        }
        
        set {
            self.opRequest.httpMethod = newValue
        }
    }
    
    public var bodyData: Data? {
        get {
            return self.opRequest.httpBody
        }
        
        set {
            self.opRequest.httpBody = newValue
        }
    }
    
    private var opStatus: WXOperationStatus {
        set {
            let transitionArray: [UInt8] = [
                // None ->
                /* None */ 0, /* InProgress */ 1, /* Done */ 3, /* Failed */ 3,
                           
                           // InProgress ->
                /* None */ 1, /* InProgress */ 0, /* Done */ 3, /* Failed */ 3,
                           
                           // Done ->
                /* None */ 0, /* InProgress */ 3, /* Done */ 0, /* Failed */ 0,
                           
                           // Failed ->
                /* None */ 0, /* InProgress */ 3, /* Done */ 0, /* Failed */ 0,
                           ]
            
            let trx:UInt8 = transitionArray[(_opStatus.rawValue & 3) * 4 + (newValue.rawValue & 3)]
            
            if ( (trx & 1) != 0) {
                self.willChangeValue(forKey: "isExecuting")
            }
            
            if ( (trx & 2) != 0) {
                self.willChangeValue(forKey: "isFinished")
            }
            
            _opStatus = newValue;
            
            if ( (trx & 1) != 0) {
                self.didChangeValue(forKey: "isExecuting")
            }
            if ( (trx & 2) != 0) {
                self.didChangeValue(forKey: "isFinished")
            }
        }
        get {
            return _opStatus
        }
    }
    
    open override var isAsynchronous: Bool {
        return true
    }
    
    open override var isExecuting: Bool {
        return self.opStatus == .inProgress
    }
    
    open override var isReady: Bool {
        return true
    }
    
    open override var isFinished: Bool {
        return self.opStatus == .done || self.opStatus == .failed
    }

    // MARK: - Initializers
    
    init(url: URL!, tag: String) {
        super.init()
        
        self.opUrl = url
        self.opRequest = URLRequest(url: url)
        self.tag = tag
    }
    
    init(urlRequest: URLRequest!, tag: String) {
        super.init()
        
        self.opRequest = urlRequest
        self.opUrl = urlRequest.url
        self.tag = tag
    }
    
    // MARK: - Operation methods
    
    open override func start() {
        self.opStatus = .inProgress;
        
        if self.isAsynchronous {
            Thread.detachNewThreadSelector(#selector(self.executeOperation), toTarget: self, with: nil)
        } else {
            self.executeOperation()
        }
    }
    
    open override func cancel() {
        var actuallyCancel: Bool
        
        let oldCancelled = self.isCancelled;
        super.cancel()
        actuallyCancel = !oldCancelled && self.opStatus == .inProgress
        
        if actuallyCancel {
            self.cancelOperation()
        }
    }
    
    // MARK: Base operation methods
    
    @objc func executeOperation() {
        if (!self.startOperation()) {
            self.opStatus = .failed
        }
    }
    
    func startOperation() -> Bool {
        let urlRequest: URLRequest = self.opRequest
        let urlSession = URLSession.shared
        
        urlSession.configuration.timeoutIntervalForRequest = 15
        urlSession.configuration.requestCachePolicy = .reloadIgnoringCacheData
        urlSession.configuration.networkServiceType = .default
        urlSession.configuration.httpShouldUsePipelining = false
        urlSession.configuration.waitsForConnectivity = false
        urlSession.configuration.httpShouldSetCookies = false
        urlSession.configuration.httpCookieStorage = nil
        urlSession.configuration.urlCache = nil

        self.opDataTask = urlSession.dataTask(with: urlRequest, completionHandler: { [weak self] (body, response,error) in
           
            guard let blockSelf = self else {
                return
            }
            
            guard let opResp =  response as? HTTPURLResponse else {
                var err:NSError? = nil
                if let sError = error {
                    let nsError = sError as NSError
                    let operationError: WXOperationError = nsError.code == -1009 ? .invalidConnectivity : .http
                    err = blockSelf.error(code: operationError, description:  error!.localizedDescription)
                } else {
                    err = blockSelf.error(code: WXOperationError.unknow, description:  error?.localizedDescription)
                }
                
                blockSelf.finishWithFailure(error: err)
                return
            }
            
            blockSelf.opResponse = opResp
            blockSelf.actualResponseBody = body
        
            if (opResp.statusCode >= 200 && opResp.statusCode <= 226) {
                blockSelf.finishWithSuccess()
                return
            }
            
            var err:NSError? = nil
            
            if (error != nil) {
                err = blockSelf.error(code: WXOperationError.http, description:  error!.localizedDescription)
            } else {
                err = blockSelf.error(code: WXOperationError.http, description:  error?.localizedDescription)
            }

            blockSelf.finishWithFailure(error: err)
        })

        self.opDataTask?.resume()
        
        return true
    }
    
    func cancelOperation() {
        self.opDataTask?.cancel()
        self.opDataTask = nil
        
        self.opError = NSError.init(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: nil)
        
        if ((self.opErrorBlock) != nil) {
            self.opErrorBlock!(self.opError,self)
        }
        
        self.opStatus = .failed;
    }
    
    private func error(code: WXOperationError, description: String?) -> NSError {
        var errDict = [String:Any]()
        
        if (self.opResponse != nil) {
            errDict["HTTPOperationErrorHTTPResponseKey"] = self.opResponse
        }
        
        if ( self.actualResponseBody != nil) {
            errDict["HTTPOperationErrorHTTPBodyKey"] = self.actualResponseBody
        }
        
        if ( self.opRequest.url != nil ){
            errDict["HTTPOperationErrorHTTPTargetKey"] = self.opRequest.url?.absoluteString
        }
        
        if (description != nil) {
            errDict[NSLocalizedDescriptionKey] = description;
        }
        
        return NSError.init(domain: "HTTPOperationErrorDomain", code: code.rawValue, userInfo: errDict)
    }
    
    // MARK: - Utils
    
    private func finishFailureEmptyResponse() {
        
    }
    
    // MARK: Public API methods
    
    public func finishWithSuccess() {
        self.opDataTask?.cancel()
        self.opDataTask = nil
        
        if ((self.opCompletionBlock) != nil) {
            self.opCompletionBlock!(self.actualResponseBody,self)
        }
        
        print(self.opResponse ?? "Response empty")
        
        self.opStatus = .done
    }
    
    public func finishWithFailure(error: NSError?) {
        self.opDataTask?.cancel()
        self.opDataTask = nil
        self.opError = error
        
        if ((self.opErrorBlock) != nil) {
            self.opErrorBlock!(self.opError,self)
        }
        print(opResponse ?? "Response empty")
        
        self.opStatus = .failed
    }
    
    public func finishWithCancel() {
        let dict: [String:String] = [NSLocalizedDescriptionKey: "Cancelled"]
        let error = NSError.init(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: dict)
        
        self.finishWithFailure(error: error)
    }
    
    public func setURLParamas(params: Dictionary<String,Any>) {
        var urlString = self.opUrl.absoluteString
        let keys = params.keys
        
        for key in keys {
            let value = params[key]
            let prefix = keys.endIndex == keys.index(of: key) ? "?" : "&"
            
            if (value != nil) {
                let query:String = urlString.appendingFormat("%@%@=%@", prefix,key,value as! CVarArg)
                urlString = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            }
        }
        
        self.opUrl = URL.init(string: urlString)
        self.opRequest.url = self.opUrl
    }
    
}
