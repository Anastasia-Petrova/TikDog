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
    lazy var navigationController = UINavigationController()
    
    init(service: WebService, imageLoader: ImageLoader) {
        self.service = service
        self.imageLoader = imageLoader
    }
    
    func start(in window: UIWindow) {
        let breedListViewController = makeBreedListViewController(didSelectBreed: { [weak self] breed in
            guard let self = self else { return }
            
            self.navigationController.pushViewController(
                self.makeBreedPhotosScreen(breed: breed),
                animated: true
            )
        })
        
        navigationController.setViewControllers([breedListViewController], animated: false)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    private func makeBreedListViewController(didSelectBreed: @escaping (Breed) -> Void) -> BreedListViewController {
        BreedListViewController(
            breedListPublisher: service.getBreedsList,
            didSelectBreed: didSelectBreed
        )
    }
    
    private func makeBreedPhotosScreen(breed: Breed) -> BreedPhotosViewController {
        BreedPhotosViewController(
            breedPhotosPublisher: { self.service.getBreedPhotos(breed) },
            loadImage: imageLoader.load
        )
    }
}
