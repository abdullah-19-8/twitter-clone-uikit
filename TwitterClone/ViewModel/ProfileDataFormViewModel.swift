//
//  ProfileDataFormViewModel.swift
//  TwitterClone
//
//  Created by Abdulla Ahmad on 8/10/24.
//

import Foundation
import Combine

final class ProfileDataFormViewModel: ObservableObject {
    
    @Published var displayName: String?
    @Published var username: String?
    @Published var bio: String?
    @Published var avatarPath: String?
    
    
}
