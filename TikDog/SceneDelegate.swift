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
    var s: AnyCancellable?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        
        let service = DogAPIService.live
        let breedListRequest = service.getRequest(for: .breedList)
        
        let viewController = BreedListViewController(
            breedListFetcher: {
                DogAPIService.get(request: breedListRequest)
            },
            didSelectBreed: { breed in
                
            }
        )
        
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }
}

struct BreedListResponse: Decodable {
    let message: Dictionary<String, [String]>
    
    var breeds: [Breed] {
        message
            .map { Breed(name: $0, subBreeds: $1.map(Breed.init)) }
            .sorted { $0.name < $1.name}
    }
}
