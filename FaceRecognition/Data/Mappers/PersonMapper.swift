//
//  PersonMapper.swift
//  FaceRecognition
//
//  Created by Mohd Khan on 27/12/25.
//

import Foundation

extension Persons{
    func toDomain() -> Person {
        Person(id: id ?? UUID(), name: name ?? "", imageURLs: imageUrls ?? [], embedings: embeding ?? [[]], averageEmbedings: averageEmbeding ?? [])
           
        }
}
