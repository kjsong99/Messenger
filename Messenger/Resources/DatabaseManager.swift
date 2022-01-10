//
//  DatabaseManager.swift
//  Messanger
//
//  Created by 송경진 on 2022/01/07.
//

import Foundation
import FirebaseDatabase
import Firebase

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    static func safeEmail(emailAddress: String)-> String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    
}

// MARK: - Account Management
extension DatabaseManager{
    
    public func userExists(with email: String,
                           completion: @escaping ((Bool) -> Void)) {
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            
            completion(true)
        })
    }
    
    
    ///Inserts new user to database
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void){
        database.child(user.safeEmail).setValue([
            "name" : user.name,
            "birth" : user.birth
        ], withCompletionBlock: { error, _ in
            guard error == nil else {
                print("failed ot write to database")
                completion(false)
                return
            }
            
            
            self.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                if var usersCollection = snapshot.value as? [[String : String]] {
                    //append to user dictionary
                    let newElement = [
                        "name": user.name,
                        "email": user.safeEmail
                    ]
                    usersCollection.append(newElement)
                    
                    self.database.child("users").setValue(usersCollection, withCompletionBlock: {error,_ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                    })
                }
                else {
                    //create that array
                    let newCollection : [[String : String]] = [
                        ["name": user.name,
                         "email": user.safeEmail
                        ]
                    ]
                    
                    self.database.child("users").setValue(newCollection, withCompletionBlock: {error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                    })
                }
            })
            
            
        })
    }
    
    public func getAllUsers(completion : @escaping(Result<[[String: String]],Error>) -> Void){
        database.child("users").observeSingleEvent(of: .value, with: { snapshopt in
            guard let value = snapshopt.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        })
    }
    
    public enum DatabaseError: Error{
        case failedToFetch
    }
}

/*
 users => [
 [
 "name":
 "safe_email":
 ],
 [
 "name":
 "safe_email":
 ]
 ]
 */

struct ChatAppUser {
    let name : String
    let birth : String?
    let emailAddress: String
    
    var safeEmail:String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var profilePictureFileNmae: String {
        return "\(safeEmail)_profile_picture.png"
    }
}
