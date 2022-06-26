//
//  HeaderView.swift
//  isItUp
//
//  Created by Paul van Woensel on 5/30/22.
//

import SwiftUI

struct HeaderView: View {
    @AppStorage("timeout") private var timeout = 120
    let timeouts = [30,60,120,300,600]
    var body: some View {
        ZStack {
            HStack {
                Button {
                    exit(0)
                } label: {
                    Image(systemName: "slash.circle")
                }
                .cornerRadius(8)
                Spacer()
            }
            .padding()
            HStack {
                Spacer()
                Text("Is it UP")
                Spacer()
            }
            HStack {
                Spacer()
                Picker("", selection: $timeout) {
                    ForEach(self.timeouts, id:\.self) { time in
                        Text("\(time) sec interval")
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 150)
                .onChange(of: timeout) { _ in
                    CheckTimer.shared.startTimer()
                }
            }
        }
        .frame(height: 50)
        
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView()
    }
}
