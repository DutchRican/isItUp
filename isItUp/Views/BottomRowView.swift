//
//  BottomRowView.swift
//  isItUp
//
//  Created by Paul van Woensel on 5/29/22.
//

import SwiftUI

struct BottomRowView: View {
    @Environment(\.presentationMode) var presentation
//    @Environment(\.managedObjectContext) private var moc
    @Environment(\.managedObjectContext) var moc
    @State var showingEntries = false
    var body: some View {
        HStack {
            Spacer()
            Button {
                self.showingEntries = true
            } label: {
                Image(systemName: "plus.square")
            }
            .padding(.bottom, 5)
        }
        .padding(.trailing, 7)
        .frame(height: 35)
        .sheet(isPresented: $showingEntries) {
            EntriesView(selectedEndpoint: .constant(nil))
                .frame(width: 500, height: 500)
                .environment(\.managedObjectContext, moc)
        }
        
           
    }
}

struct BottomRowView_Previews: PreviewProvider {
    static var previews: some View {
        BottomRowView()
    }
}
