//
//  FirebaseDataService.swift
//  ZPMAPP
//
//  Created by Felipe Rocha Oliveira on 11/10/21.
//

import Foundation
import Firebase
import FirebaseAuth
import CodableFirebase
import SwiftUI

enum Model: Codable {
    case customer
    case myMovie
    case friend
}

protocol FirebaseRecoveryPasswordProtocol: AnyObject {
    func recovery()
    func errorRecovery(error: Error?)
}

protocol FirebaseDataServiceProtocol: AnyObject {
    func success(_ collection: String)
    func failure(error: Error?)
}

class FirebaseDataService {
    
    private let firebaseDB = Firestore.firestore()
    private let storage = Storage.storage()
    private let firebaseDBRealTime: DatabaseReference!

    private var user: User?
    private var friends: Friend?
    private var customer: Customer?
    private var myMovies: [MyMovie]? = []
    
    weak var delegate: FirebaseDataServiceProtocol?
    weak var delegateRecovery: FirebaseRecoveryPasswordProtocol?
    
    init() {
        self.firebaseDBRealTime = Database.database().reference()
        self.user = getUser()
    }
    
    // MARK: - Helper functions for creating encoders and decoders
    
    func loadCustomer() -> Customer? {
        return self.customer
    }
    
    func loadMyMovies() -> [MyMovie]? {
        return self.myMovies
    }
    
    func loadFriends() -> Friend? {
        return self.friends
    }
    
    func updateUser(
        customerData: Customer,
        password: String?
    ) {
        if !self.userIsLoggedIn() {
            return
        }

        self.updateEmail(email: customerData.email)

        if let _name = customerData.name {
            self.updateName(name: _name)
        }
        
        if let _password = password {
            self.updatePass(password: _password)
        }
        
        self.delegate?.success("users")
    }
    
    func resetPassword(password: String) {
        self.updatePass(password: password)
    }
    
    func addDocument(collection: String, data: [String: Any]) {
        firebaseDB.collection(collection).addDocument(data: data) { error in
            if error != nil {
                self.delegate?.failure(error: error)
                return
            }
            print("Insert executed with success")
            self.delegate?.success(collection)
        }
    }
    
    func addDocumentWithId(collection: String, id: String, data: [String: Any]) {
        firebaseDB.collection(collection).document(id).setData(data, merge: true) { error in
            if error != nil {
                self.delegate?.failure(error: error)
                return
            }
            print("Insert executed with success")
            self.delegate?.success(collection)
        }
    }
    
    func firebaseDecodable(response: [String: Any], collection: String) {
        var data: [String: Any] = response
        do {
            switch collection {
            case "users":
                data.removeValue(forKey: "myMovies")
                data.removeValue(forKey: "friends")
                self.customer = try FirestoreDecoder().decode(Customer.self, from: data)
            case "users_movies":
                for (movieID, myMoviesData) in data {
                    guard let _myMoviesData = myMoviesData as? Array<AnyObject> else { return }
                    let dict: [String: Any] = ["tag": _myMoviesData[0], "id": movieID]
                    let myMovie = try FirestoreDecoder().decode(MyMovie.self, from: dict)
                    
                    if let movies = self.myMovies {
                        for (key, _myMovie) in movies.enumerated() {
                            if myMovie.id == _myMovie.id {
                                self.myMovies?.remove(at: key)
                            }
                        }
                    }
                    
                    self.myMovies?.append(myMovie)
                    
                    self.getDocumentWithId(collection: "movies", id: movieID)
                }
            case "movies":
                let movie = try FirestoreDecoder().decode(Movie.self, from: data)
                let movieID = String(movie.id)
                
                if let index = self.myMovies?.firstIndex(where: {$0.id == movieID}) {
                    self.myMovies?[index].movie = movie
                }
            case "friends":
                let friends = try FirebaseDecoder().decode(Friend.self, from: data)
                self.friends = friends
            default :
                print("\(collection) is not found")
            }
        } catch {
            print("Error decode \(error.localizedDescription)")
        }
    }
    
    func getDocumentWithId(collection: String, id: String) {
        let docRef = self.firebaseDB.collection(collection).document(id)
        docRef.getDocument(completion: { (document, error) in
            if error != nil {
                self.delegate?.failure(error: error)
                return
            }
            
            guard let response = document?.data() else { return }
            self.firebaseDecodable(response: response, collection: collection)
            self.delegate?.success(collection)
        })
    }
    
    func getDocumentRefWithId(collection: String, id: String) -> DocumentReference {
        let subRef = firebaseDB.collection(collection).document(id)

        return subRef
    }
    
    func getSubDocumentRefWithId(collection: String, id: String, subCollection: String, subDocument: String) -> DocumentReference {
        let subRef = firebaseDB
            .collection(collection).document(id)
            .collection(subCollection).document(subDocument)

        return subRef
    }
    
    func getReference() -> StorageReference {
        let storageRef = storage.reference()
        let avatarRef = storageRef.child("avatar")
        return avatarRef
    }
    
    func getAvatar() {
        let avatarRef = self.getReference()
        avatarRef.child("oSbOu3BuQkUaTtqnFqYJgBFWJvw1.jpeg").getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
            } else {
                //self.delegateAvatar?.loadAvatar(avatar: data!)
                print("Image OK")
            }
        }
    }
    
    func uploadAvatar(localFile: URL) {
        let fileExtension = localFile.pathExtension
        let fileName = "oSbOu3BuQkUaTtqnFqYJgBFWJvw1.\(fileExtension)"
        let avatarRef = self.getReference()

        avatarRef.child(fileName).putFile(from: localFile, metadata: nil) {
            metadata, error in
            
            guard let metadata = metadata else {
                print("Error metadata")
                return
            }

            let size = metadata.size
            print(size)
            avatarRef.child("oSbOu3BuQkUaTtqnFqYJgBFWJvw1.jpeg").downloadURL { (url, error) in
                guard let downloadURL = url else { return }
                
                if let error = error {
                    print(error)
                }
                
                self.addDocumentWithId(collection: "users", id: "oSbOu3BuQkUaTtqnFqYJgBFWJvw1", data: ["avatar": downloadURL.absoluteString])
            }
        }
    }
    
    func userIsLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    // TODO -> Remove with feature Vitor
    func getUser() -> User?  {
        let user = Auth.auth().currentUser
        guard let _user = user else {
            return nil
        }

        return _user
    }
    
    //TODO -> Remove with feature Vitor, case exists
    func recoveryPassword() {
        guard let email = self.customer?.email else { return }
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if error != nil {
                self.delegateRecovery?.errorRecovery(error: error)
            }
            
            self.delegateRecovery?.recovery()
        }
    }
    
    private func updateName(name: String) {
        let request = Auth.auth().currentUser?.createProfileChangeRequest()
        request?.displayName = name
        request?.commitChanges { error in
            if error != nil {
                self.delegate?.failure(error: error)
            }
            
            self.delegate?.success("users")
        }
    }
    
    private func updateEmail(email: String) {
        Auth.auth().currentUser?.updateEmail(to: email) { error in
            if error != nil {
                self.delegate?.failure(error: error)
            }
            
            self.delegate?.success("users")
        }
    }
    
    private func updatePass(password: String) {
        Auth.auth().currentUser?.updatePassword(to: password) { error in
            if error != nil {
                self.delegate?.failure(error: error)
            }
            
            self.delegate?.success("users")
        }
    }
    
    private func sendVerificationEmail() {
        Auth.auth().currentUser?.sendEmailVerification { error in
            if error != nil {
                self.delegate?.failure(error: error)
            }
            
            self.delegate?.success("users")
        }
    }
}

extension DocumentReference: DocumentReferenceType {}
extension GeoPoint: GeoPointType {}
extension FieldValue: FieldValueType {}
extension Timestamp: TimestampType {}