//
//  PlantViewModel.swift
//  GrowSense
//
//  Created by Aiko Jones on 3/26/25.
//

import Foundation
import FirebaseFirestore

struct Plant: Identifiable, Codable {
    var id: String = ""
    var name: String
    var imageName: String
    var scientificName: String
    var description: String
    var minLight: Int
    var maxLight: Int
    var waterFrequency: String
}

class PlantViewModel: ObservableObject {
    @Published var myPlants: [Plant] = []
    @Published var allPlants: [Plant] = [] // ✅ New for global plant list

    private var db = Firestore.firestore()

    // 🔄 Fetch all global plants from 'plants' collection
    func fetchAllPlants() {
        db.collection("plants").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("No global plants found")
                return
            }

            self.allPlants = documents.compactMap { doc in
                let data = doc.data()

                guard let name = data["name"] as? String,
                      let imageName = data["imageName"] as? String,
                      let scientificName = data["scientificName"] as? String,
                      let description = data["description"] as? String,
                      let minLight = data["minLight"] as? Int,
                      let maxLight = data["maxLight"] as? Int,
                      let waterFrequency = data["waterFrequency"] as? String
                else {
                    print("Missing one or more fields in document \(doc.documentID)")
                    return nil
                }

                return Plant(
                    id: doc.documentID,
                    name: name,
                    imageName: imageName,
                    scientificName: scientificName,
                    description: description,
                    minLight: minLight,
                    maxLight: maxLight,
                    waterFrequency: waterFrequency
                )
            }
        }
    }

    // ✅ Already great — just adding to userPlants using name
    func addPlantByName(_ name: String) {
        db.collection("plants").whereField("name", isEqualTo: name).getDocuments { snapshot, error in
            if let error = error {
                print("Error finding plant: \(error.localizedDescription)")
                return
            }
            guard let doc = snapshot?.documents.first else {
                print("Plant not found in database")
                return
            }

            let plantData = doc.data()
            let imageName = plantData["imageName"] as? String ?? "defaultPlant"
            let scientificName = plantData["scientificName"] as? String ?? ""
            let description = plantData["description"] as? String ?? ""
            let minLight = plantData["minLight"] as? Int ?? 0
            let maxLight = plantData["maxLight"] as? Int ?? 1000
            let waterFrequency = plantData["waterFrequency"] as? String ?? "Weekly"

            self.db.collection("userPlants").addDocument(data: [
                "name": name,
                "imageName": imageName,
                "scientificName": scientificName,
                "description": description,
                "minLight": minLight,
                "maxLight": maxLight,
                "waterFrequency": waterFrequency
            ]) { err in
                if let err = err {
                    print("Error adding to userPlants: \(err.localizedDescription)")
                } else {
                    print("Successfully added to userPlants")
                    self.fetchUserPlants()
                }
            }
        }
    }

    // ✅ Already solid
    func fetchUserPlants() {
        db.collection("userPlants").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("No userPlants found")
                return
            }

            self.myPlants = documents.compactMap { doc in
                let data = doc.data()

                guard let name = data["name"] as? String,
                      let imageName = data["imageName"] as? String,
                      let scientificName = data["scientificName"] as? String,
                      let description = data["description"] as? String,
                      let minLight = data["minLight"] as? Int,
                      let maxLight = data["maxLight"] as? Int,
                      let waterFrequency = data["waterFrequency"] as? String
                else {
                    print("Missing one or more fields in document \(doc.documentID)")
                    return nil
                }

                return Plant(
                    id: doc.documentID,
                    name: name,
                    imageName: imageName,
                    scientificName: scientificName,
                    description: description,
                    minLight: minLight,
                    maxLight: maxLight,
                    waterFrequency: waterFrequency
                )
            }
        }
    }
}
