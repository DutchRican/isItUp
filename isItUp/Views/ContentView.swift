//
//  ContentView.swift
//  isItUp
//
//  Created by Paul van Woensel on 5/29/22.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var moc
    var body: some View {
        return VStack {
            HeaderView()
            Divider()
            MainContentView().environment(\.managedObjectContext, moc)
            Divider()
            BottomRowView().environment(\.managedObjectContext, moc)
        }.frame(width: 400, height: 400)
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
