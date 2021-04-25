//
//  App.swift
//  TikDog
//
//  Created by Anastasia Petrova on 21/04/2021.
//

import UIKit

class App {
    let service: DogAPIService
    let imageLoader: ImageLoader
    lazy var rootViewController = UINavigationController()
    
    init(service: DogAPIService, imageLoader: ImageLoader) {
        self.service = service
        self.imageLoader = imageLoader
    }
    
    func start(in window: UIWindow) {
        rootViewController.setViewControllers([makeBreedListScreen()], animated: false)
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
    
    func show(_ viewController: UIViewController) {
        rootViewController.pushViewController(viewController, animated: true)
    }
    
    func makeBreedListScreen() -> UIViewController {
        BreedListViewController(
            breedListFetcher: service.getBreedsList,
            didSelectBreed: { [weak self] breed in
                guard let self = self else { return }
                
                self.show(self.makeBreedPhotosScreen(breed: breed))
            }
        )
    }
    
    func makeBreedPhotosScreen(breed: Breed) -> UIViewController {
        BreedPhotosViewController(getBreedPhotos: { self.service.getBreedPhotos(breed) }, loadImage: imageLoader.load)
    }
}
