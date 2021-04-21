//
//  SceneDelegate.swift
//  TikDog
//
//  Created by Anastasia Petrova on 20/04/2021.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        let viewController = BreedListViewController(state: .loading)
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            viewController.update(with: .loaded(
                [.init(name: "shpitz"), .init(name: "affenpinscher affenpinscher affenpinscher affenpinscher affenpinscher")]
            )
            )
        }
    }
}

