//
//  SceneDelegate.swift
//  TikDog
//
//  Created by Anastasia Petrova on 20/04/2021.
//

import Combine
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var app: App?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: scene)
        let app = App(service: .live(baseURL: URL(string: "https://dog.ceo/api")!), imageLoader: .live)
//        let app = App(service: .mock, imageLoader: .live)
        app.start(in: window)
        
        self.app = app
        self.window = window
    }
}

