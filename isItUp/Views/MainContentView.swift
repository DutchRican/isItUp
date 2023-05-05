//
//  MainContentView.swift
//  isItUp
//
//  Created by Paul van Woensel on 5/29/22.
//

import SwiftUI

struct MainContentView: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key: "id", ascending: true)],
        animation: .default
    ) private var endpoints: FetchedResults<Endpoint>
    
    @State private var showingEntries: Bool = false
    @State private var selectedEntry: Endpoint? = nil
    
    var body: some View {
        VStack(spacing: 10) {
            List {
                Section(header:
                            HStack {
                    Text("Status")
                    Spacer().frame(width: 20)
                    Text("Endpoint")
                    Spacer()
                    
                }){
                    ForEach(endpoints, id:\.id) { endpoint in
                        HStack{
                            Spacer().frame(width: 15)
                            Circle()
                                .fill()
                                .foregroundColor(endpoint.isUp ? .green : .red)
                                .frame(width: 10, height: 10, alignment: .center)
                            Spacer().frame(width: 35)
                            Text("\(endpoint.url ?? "no url")")
                                .font(.footnote)
                            Spacer()
                            Button(action: {
                                onDelete(item: endpoint)
                            }){ Image(systemName: "xmark") .foregroundColor(.red)}
                                .cornerRadius(8)
                            
                        }
                        .onTapGesture {
                            self.selectedEntry = endpoint
                            showingEntries.toggle()
                        }
                    }
                }
            }//: LIST
            .listStyle(PlainListStyle())
        }
        .sheet(isPresented: $showingEntries) {
            EntriesView(selectedEndpoint: self.$selectedEntry)
                .frame(width: 500, height: 500)
                .environment(\.managedObjectContext, moc)
        }
    }
    
    func onDelete(item: Endpoint) {
        moc.delete(item)
        do {
            try moc.save()
            let newEndpoints = endpoints.filter { $0 != item}
            CheckTimer.shared.setItems(newEndpoints, moc: moc)
        } catch {
            print(error)
        }
    }
}

struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView().environment(\.managedObjectContext,
                                       PersistenceController.preview.container.viewContext)
    }
}
