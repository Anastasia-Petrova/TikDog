//
//  SceneDelegate.swift
//  TikDog
//
//  Created by Anastasia Petrova on 25/04/2021.
//

import Combine
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var app: App?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: scene)
        let imageLoader = ImageLoader.live
        
        var service =  WebService.live(baseURL: URL(string: "https://dog.ceo/api")!)
//        replace with mocks if needed
//        var service =  WebService.mockSuccess
//        service.getBreedPhotos = WebService.mockFailure.getBreedPhotos
        
        let app = App(service: service, imageLoader: imageLoader)
        app.start(in: window)
        
        self.app = app
        self.window = window
    }
}

