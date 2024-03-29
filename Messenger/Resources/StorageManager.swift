//
//  StorageManager.swift
//  Messenger
//
//  Created by 송경진 on 2022/01/10.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    /*
     
     /images/afraz9-gmail-com_profile_picture.png
     
     */
    
    public typealias UploadPictureCompetion = (Result<String, Error>) -> Void
    
     // MARK: - UPLOAD PROFILE PICTURE TO FIREBASE
    public func uploadProfilePicture(with data: Data ,
                                     fileName: String,
                                     completion : @escaping UploadPictureCompetion){
        storage.child("images/\(fileName)").putData(data,metadata: nil, completion: { metadata, error in
            guard error == nil else {
                //failed
                print("failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("download url returnned : \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    
    // MARK: - UPLOAD MESSAGE PICTURE TO FIREBASE
   public func uploadMessagePicture(with data: Data ,
                                    fileName: String,
                                    completion : @escaping UploadPictureCompetion){
       storage.child("message_images/\(fileName)").putData(data,metadata: nil, completion: { metadata, error in
           guard error == nil else {
               //failed
               print("failed to upload data to firebase for picture")
               completion(.failure(StorageErrors.failedToUpload))
               return
           }
           
           self.storage.child("message_images/\(fileName)").downloadURL(completion: { url, error in
               guard let url = url else {
                   print("Failed to get download url")
                   completion(.failure(StorageErrors.failedToGetDownloadUrl))
                   return
               }
               
               let urlString = url.absoluteString
               print("download url returnned : \(urlString)")
               completion(.success(urlString))
           })
       })
   }
    
    public enum StorageErrors: Error {
            case failedToUpload
            case failedToGetDownloadUrl
                
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void){
        let reference = storage.child(path)
        
        reference.downloadURL(completion: { url, error in
            guard let url = url,
                  error == nil else{
                      completion(.failure(StorageErrors.failedToGetDownloadUrl))
                      return
                  }
            
            completion(.success(url))
        })
    }
}
