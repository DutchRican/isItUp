//
//  EntriesView.swift
//  isItUp
//
//  Created by Paul van Woensel on 5/30/22.
//

import SwiftUI

struct EntriesView: View {
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedEndpoint: Endpoint?
    
    private enum Field: Int, Hashable {
        case urlField, expectedResponseField
    }
    
    @State private var url: String = ""
    @State private var statusCode: Int16 = 200
    @State private var expectedResponse: String = ""
    @State private var requestType: String = "GET"
    @State private var headers: [HeaderPair] = []
    @FocusState private var focusedField: Field?
    
    let statusCodes: [Int16] = [200, 201, 202, 204, 206, 207]
    let requestTypes: [String] = ["GET", "POST"]
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                }
                .padding(.trailing, 15)
            }
            
            Divider()
                .padding(.vertical, 3)
            HStack {
                VStack {
                    HStack {
                        Text("Target Url: ")
                            .frame(width: 130, alignment: .leading)
                        TextField("http://google.com", text: $url)
                            .textFieldStyle(.roundedBorder)
                            .focusable()
                            .focused($focusedField, equals: .urlField)
                    }
                    .padding(.horizontal)
                    Picker("Request Method        ", selection: $requestType) { // very ugly spacing :(
                        ForEach(self.requestTypes, id:\.self) { method in
                            Text("\(method)")
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    HStack {
                        Text("Expected Response")
                            .frame(width: 130, alignment: .leading)
                        TextField("Leave me empty if just the status code is enough", text:$expectedResponse)
                            .textFieldStyle(.roundedBorder)
                            .focused($focusedField, equals: .expectedResponseField)
                    }
                    .padding(.horizontal)
                    Picker("Expected StatusCode", selection: $statusCode) {
                        ForEach(self.statusCodes, id:\.self) { code in
                            Text("\(code)")
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                }
                .onAppear {
                    focusedField = .urlField
                }
            } // : FIRST HSTACK
            Divider()
            VStack {
                HStack {
                    Spacer()
                    Button(action: addEmptyHeader) {
                        Text("Add header")
                    }
                }
                .padding(.horizontal)
                List {
                    ForEach($headers.indices, id: \.self) { idx in
                        HStack{
                            TextField("Header Key", text: $headers[idx].key_name)
                            TextField("Header Value", text: $headers[idx].key_value)
                            Spacer()
                            Button(action: {
                                self.headers.remove(at: idx)
                            }){
                                Image(systemName: "xmark")
                            }
                        }
                    }
                }
                
            }
            HStack {
                Spacer()
                Button(action: self.selectedEndpoint == nil ? addItem : updateItem){
                    Text(self.selectedEndpoint == nil ? "Add item" : "Update Item")
                }.disabled(self.url.isEmpty)
                
            } // : SECOND HSTACK
            .padding([.bottom, .trailing], 15)
        }
        .padding(.top, 5)
        .onAppear {
            if self.selectedEndpoint != nil {
                self.url = self.selectedEndpoint!.url ?? ""
                self.statusCode = self.selectedEndpoint!.expectedStatus
                self.requestType = self.selectedEndpoint!.requestType ?? "GET"
                self.expectedResponse = self.selectedEndpoint!.expectedResponse ?? ""
                if let headers = selectedEndpoint?.headers {
                    for header in headers {
                        self.headers.append(HeaderPair(key_value: (header as! Header).key_value ?? "", key_name: (header as! Header).key_name ?? ""))
                    }
                }
            }
        }
    }
    
    private func addEmptyHeader() {
        self.headers.append(HeaderPair( key_value: "", key_name: ""))
    }
    
    private func addItem() {
        let item = Endpoint(context: moc)
        item.id = UUID()
        item.expectedStatus = self.statusCode
        item.expectedResponse = self.expectedResponse
        item.requestType = self.requestType
        item.isUp = true
        item.lastUp = Date()
        item.url = self.url
        for header in self.headers {
            let newHeader = Header(context: moc)
            newHeader.id = UUID()
            newHeader.key_name = header.key_name
            newHeader.key_value = header.key_value
            item.addToHeaders(newHeader)
        }
        
        do {
            try moc.save()
            self.url = ""
            self.headers = []
            self.statusCode = 200
            self.expectedResponse = ""
            Task {
                await CheckTimer.shared.setItems(CheckTimer.shared.itemsToCheck + [item], moc: moc)
            }
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func updateItem() {
        self.selectedEndpoint!.url = self.url
        self.selectedEndpoint!.expectedStatus = self.statusCode
        self.selectedEndpoint!.expectedResponse = self.expectedResponse
        self.selectedEndpoint!.headers = []
        for header in self.headers {
            let newHeader = Header(context: moc)
            newHeader.id = UUID()
            newHeader.key_name = header.key_name
            newHeader.key_value = header.key_value
            self.selectedEndpoint!.addToHeaders(newHeader)
        }
        do {
            try moc.save()
            Task {
                var items = await CheckTimer.shared.itemsToCheck
                let idx = items.firstIndex { $0.id == self.selectedEndpoint!.id}
                items[idx!] = self.selectedEndpoint!
                await CheckTimer.shared.setItems(items, moc: moc)
            }
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct EntriesView_Previews: PreviewProvider {
    static var previews: some View {
        EntriesView(selectedEndpoint: .constant(nil))
    }
}
