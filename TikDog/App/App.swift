//
//  App.swift
//  TikDog
//
//  Created by Anastasia Petrova on 21/04/2021.
//

import UIKit

final class App {
    let service: WebService
    let imageLoader: ImageLoader
    lazy var rootViewController = UINavigationController()
    
    init(service: WebService, imageLoader: ImageLoader) {
        self.service = service
        self.imageLoader = imageLoader
    }
    
    func start(in window: UIWindow) {
        let breedListViewController = makeBreedListViewController(didSelectBreed: { [weak self] breed in
            guard let self = self else { return }
            
            self.rootViewController.pushViewController(
                self.makeBreedPhotosScreen(breed: breed),
                animated: true
            )
        })
        
        rootViewController.setViewControllers([breedListViewController], animated: false)
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
    
    func makeBreedListViewController(didSelectBreed: @escaping (Breed) -> Void) -> UIViewController {
        BreedListViewController(
            breedListPublisher: service.getBreedsList,
            didSelectBreed: didSelectBreed
        )
    }
    
    func makeBreedPhotosScreen(breed: Breed) -> UIViewController {
        BreedPhotosViewController(breedPhotosPublisher: { self.service.getBreedPhotos(breed) }, loadImage: imageLoader.load)
    }
}
