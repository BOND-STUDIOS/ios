import Foundation
import FirebaseFirestore
import FirebaseAuth

class JourneyManager: ObservableObject {
    @Published var journeys: [Journey] = []
    @Published var isLoading = true // ✅ Add this
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?

    deinit {
        listenerRegistration?.remove()
    }
    
    func fetchJourneys() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        listenerRegistration?.remove()
        
        self.listenerRegistration = db.collection("users").document(userId).collection("journeys")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("No journey documents")
                    return
                }
                
                self.journeys = documents.compactMap { queryDocumentSnapshot -> Journey? in
                    return try? queryDocumentSnapshot.data(as: Journey.self)
                }
                self.isLoading = false 
            }
    }
    
    func addJourney(_ journey: Journey) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            _ = try db.collection("users").document(userId).collection("journeys").addDocument(from: journey)
        } catch {
            print("Error adding journey: \(error)")
        }
    }

    func updateJourney(_ journey: Journey) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // ✅ This guard let now works because journey.id is an optional String
        guard let journeyId = journey.id else { return }
        
        do {
            // ✅ And journeyId is now the correct String type for this function
            try db.collection("users").document(userId).collection("journeys").document(journeyId).setData(from: journey)
        } catch {
            print("Error updating journey: \(error)")
        }
    }
    func deleteJourney(_ journey: Journey) {
        guard let userId = Auth.auth().currentUser?.uid, let journeyId = journey.id else { return }
        
        db.collection("users").document(userId).collection("journeys").document(journeyId).delete { error in
            if let error = error {
                print("Error removing journey: \(error)")
            } else {
                print("Journey successfully removed!")
            }
        }
    }
}
