//
//  ContentView.swift
//  customersfcrud
//
//  Created by rkedlor on 5/26/20.
//  Copyright © 2020 rkedlor. All rights reserved.
//
import Firebase
import SwiftUI
import FirebaseFirestore
struct Restaurant: Identifiable {
  var id = UUID()
  var name:String
  var rating:String
}
struct ContentView: View {
  @State var restaurantName = ""
  @State var restaurantRating = ""
  @State var reviewedRestaurants : [Restaurant]
  @State var showSheet = false
  @State var rating_id = ""
  @State var showActionSheet = false
  var body: some View {
    VStack {
      TextField("Great this restaurant",text:$restaurantName).padding()
      TextField("Great this restaurant",text:$restaurantRating).keyboardType(.numberPad)
        .padding()
      
      ScrollView{
        if reviewedRestaurants.count > 0 {
          
          ForEach(reviewedRestaurants, id: \.id){ thisRestaurant in
            Button(action:{
              self.restaurantName = thisRestaurant.name
              self.restaurantRating = thisRestaurant.rating
              self.showSheet = true
              self.rating_id = thisRestaurant.id.uuidString
            }){
              HStack{
                Text("\(thisRestaurant.name) || \(thisRestaurant.rating)")
                  .frame(maxWidth:UIScreen.main.bounds.size.width)
                  .foregroundColor(Color.white)
              }.background(Color.blue)
            }.sheet(isPresented: self.$showSheet){
              VStack{
                Text("Modify rating - \(thisRestaurant.id)")
                TextField("Great this restaurant",text:self.$restaurantName).padding()
                TextField("Great this restaurant",text:self.$restaurantRating).keyboardType(.numberPad)
                  .padding()
                HStack{
                  Button(action:{
                    let ratingDictionary = [
                      "name": self.restaurantName,
                      "rating": self.restaurantRating
                    ]
                    let docRef = Firestore.firestore().document("ratings/\(self.rating_id)")
                    docRef.setData(ratingDictionary,merge: true){
                      (error) in
                      if let error = error {
                        print("error = \(error)")
                      } else {
                        print("data uploaded successfully")
                        self.showSheet = false
                        self.restaurantName = ""
                        self.restaurantRating = ""
                      }
                    }
                  }){
                    Text("Update")
                      .background(Color.init(red: 0.92, green: 0.92, blue: 0.92))
                    .cornerRadius(5)
                  }
                  Button(action:{
                    self.showActionSheet = true
                  }){
                    Text("Delete")
                      .background(Color.init(red: 1, green: 0.9, blue: 0.9))
                      .foregroundColor(.red)
                    .cornerRadius(5)
                  }.padding()
                    .actionSheet(isPresented: self.$showActionSheet){
                      ActionSheet(title: Text("Delete"), message: Text("Are you sure you want to delete thisi item?"), buttons: [
                        .default(Text("Yes"), action: {
                          print("deleting")
                          Firestore.firestore().collection("ratings").document("\(self.rating_id)").delete(){
                            err in
                            if let err = err {
                              print("Error removing document: \(err))")
                            } else {
                              print("document successfully removed!")
                              self.showSheet = false
                            }
                          }
                        }),
                        .cancel()
                      ])
                  }
                }
                
              }
            }
          }
        } else {
          Text("Submit a review")
        }
      }.frame(width:UIScreen.main.bounds.size.width).background(Color.red)
      
      Button(action: {
        let ratingDictionary = [
          "name": self.restaurantName,
          "rating": self.restaurantRating
        ]
        let docRef = Firestore.firestore().document("ratings/\(UUID().uuidString)")
        docRef.setData(ratingDictionary){
          (error) in
          if let error = error {
            print("error = \(error)")
          } else {
            print("data uploaded successfully")
            self.restaurantName = ""
            self.restaurantRating = ""
          }
        }
      }){
        Text("Add Rating")
      }.padding()
    }.onAppear(){
      Firestore.firestore().collection("ratings")
        .addSnapshotListener { querySnapshot, error in
          guard let documents = querySnapshot?.documents else {
            print("Error fetching documents: \(error)")
            return
          }
          let names = documents.map{$0["name"]}
          let ratings = documents.map{$0["rating"]}
          self.reviewedRestaurants.removeAll()
          for i in 0..<names.count {
            self.reviewedRestaurants.append(Restaurant(
              id: UUID(uuidString:documents[i].documentID) ?? UUID(),
              name: names[i] as! String,
              rating: ratings[i] as! String
            ))
          }
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
      ContentView( reviewedRestaurants: [])
    }
}
