//
//  BreedPhotosViewController.swift
//  TikDog
//
//  Created by Anastasia Petrova on 20/04/2021.
//

import Combine
import UIKit

final class BreedPhotosViewController: UIViewController {
    let breed: Breed
    let getBreedPhotos: () -> AnyPublisher<Result<BreedPhotosResponse, WebError>, Never>
    
    init(
        breed: Breed,
        getBreedPhotos: @escaping () -> AnyPublisher<Result<BreedPhotosResponse, WebError>, Never>
    ) {
        self.breed = breed
        self.getBreedPhotos = getBreedPhotos
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .red
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
