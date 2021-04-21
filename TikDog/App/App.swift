//
//  App.swift
//  TikDog
//
//  Created by Anastasia Petrova on 21/04/2021.
//

import UIKit

class App {
    let service: DogAPIService
    lazy var rootViewController = UINavigationController()
    
    init(service: DogAPIService) {
        self.service = service
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
        BreedPhotosViewController(breed: breed, getBreedPhotos: service.getBreedPhotos)
    }
}
