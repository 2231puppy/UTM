//
// Copyright © 2021 osy. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import SwiftUI

@available(iOS 14, macOS 11, *)
struct VMRunButton: View {
    var padding: CGFloat
    @EnvironmentObject private var data: UTMData

    @State private var commandDown = false

    #if os(macOS)
    private var playImageName: String { commandDown ? "play" : "play.fill" }
    #else
    private var playImageName: String { "play.fill" }
    #endif

    var body: some View {
        Button {
            #if os(macOS)
            data.run(vm: data.selectedVM!, runAsSnapshot: commandDown)
            #else
            data.run(vm: data.selectedVM!)
            #endif
        } label: {
            Label("Run", systemImage: playImageName)
                .labelStyle(IconOnlyLabelStyle())
                .contextMenu {
                    #if !os(macOS)
                    Button {
                        data.run(vm: data.selectedVM!)
                    } label: {
                        Label("Run selected VM", systemImage: "play.fill")
                    }
                    Button {
                        data.run(vm: data.selectedVM!, runAsSnapshot: true)
                    } label: {
                        Label("Run as Snapshot", systemImage: "play")
                    }
                    #endif
                }
        }.modifier(VMRunHelpModifer(commandDown: $commandDown))
        .padding(.leading, padding)
    }
}

@available(iOS 14, macOS 11, *)
struct VMRunHelpModifer: ViewModifier {
    @Binding var commandDown: Bool

    func body(content: Content) -> some View {
        #if os(macOS)
        content.help(commandDown ? "Run as Snapshot" : "Run selected VM")
            .onAppear {
                NSEvent.addLocalMonitorForEvents(matching: [.flagsChanged]) { event in
                    commandDown = event.modifierFlags.contains(.command)
                    return event
                }
            }
        #else
        content.help("Run selected VM")
        #endif
    }
}

@available(iOS 14, macOS 11, *)
struct VMRunButton_Previews: PreviewProvider {
    static var previews: some View {
        VMRunButton(padding: 0)
            .environmentObject(UTMData())
    }
}
