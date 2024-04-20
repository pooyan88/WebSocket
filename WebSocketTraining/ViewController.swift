//
//  ViewController.swift
//  WebSocketTraining
//
//  Created by Pooyan J on 1/27/1403 AP.
//

import UIKit

class ViewController: UIViewController {
    
    private var webSocket: URLSessionWebSocketTask?
    private var closeButton: UIButton = {
        var button = UIButton()
        button.backgroundColor = .white
        button.setTitle("close session", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .blue
        createWebSocket()
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        closeButton.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        closeButton.center = view.center
        view.addSubview(closeButton)
    }
}

//MARK: - Setup Functions
extension ViewController {
    
    func createWebSocket() {
        let url = URL(string: "wss://echo.websocket.org/.ws")!
        //first of all we have to create a session.
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        //next step we have to create web socket
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
    }
}

//MARK: - WebSocket Delegate Functions
extension ViewController: URLSessionWebSocketDelegate {
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("did connect to socket")
        ping()
        receive()
        send()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("connection closed for \(String(describing: reason))")
    }
}

// MARK: - WebSocket Functions
extension ViewController {
    
    func ping() {
        webSocket?.sendPing(pongReceiveHandler: { error in
            if let error = error {
                print("time out", error)
            }
        })
    }
    
    @objc func close() {
        webSocket?.cancel(with: .goingAway, reason: "Demo Ended".data(using: .utf8))
    }
    
    func send() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            self.send()
            self.webSocket?.send(.string("Sending This Message ==> \(Int.random(in: 0...100))"), completionHandler: { error in
                if let error = error {
                    print("sending error", error.localizedDescription)
                }
            })
        }
    }
    
    func receive() {
        webSocket?.receive(completionHandler: { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    print("Received Data =>", data)
                case .string(let message):
                    print("Received String =>", message)
                @unknown default:
                    break
                }
            case .failure(let error):
                print("Receive Error ===> ", error)
            }
            receive()
        })
    }
}

