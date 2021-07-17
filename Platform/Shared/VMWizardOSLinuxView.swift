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
import Virtualization

@available(iOS 14, macOS 11, *)
struct VMWizardOSLinuxView: View {
    private enum SelectImage {
        case kernel
        case initialRamdisk
        case bootImage
    }
    
    @ObservedObject var wizardState: VMWizardState
    @State private var isFileImporterPresented: Bool = false
    @State private var selectImage: SelectImage = .kernel
    
    var body: some View {
        VStack {
            Text("Linux")
                .font(.largeTitle)
                .padding()
            if wizardState.useVirtualization {
                Toggle("Use Apple Virtualization", isOn: $wizardState.useAppleVirtualization)
                    .help("If set, use Apple's virtualization engine. Otherwise, use QEMU's virtualization engine.")
            }
            Toggle("Boot from kernel image", isOn: $wizardState.useLinuxKernel)
                .help("If set, boot directly from a raw kernel image and initrd. Otherwise, boot from a supported ISO.")
                .disabled(wizardState.useAppleVirtualization)
            if wizardState.useLinuxKernel {
                Text("Linux kernel (required)")
                    .padding()
                if let selected = wizardState.linuxKernelURL {
                    Text(selected.lastPathComponent)
                        .font(.caption)
                }
                Button {
                    selectImage = .kernel
                    isFileImporterPresented.toggle()
                } label: {
                    Text("Browse")
                }.buttonStyle(BigButtonStyle(width: 150, height: 50))
                .disabled(wizardState.isBusy)
                Text("Linux initial ramdisk")
                    .padding()
                if let selected = wizardState.linuxInitialRamdiskURL {
                    Text(selected.lastPathComponent)
                        .font(.caption)
                }
                Button {
                    selectImage = .initialRamdisk
                    isFileImporterPresented.toggle()
                } label: {
                    Text("Browse")
                }.buttonStyle(BigButtonStyle(width: 150, height: 50))
                .disabled(wizardState.isBusy)
                TextField("Boot Arguments", text: $wizardState.linuxBootArguments)
                    .padding()
            } else {
                #if arch(arm64)
                Link("Download Ubuntu Server for ARM", destination: URL(string: "https://ubuntu.com/download/server/arm")!)
                #else
                Link("Download Ubuntu Desktop", destination: URL(string: "https://ubuntu.com/download/desktop")!)
                #endif
                Text("Boot ISO Image")
                    .padding()
                if let selected = wizardState.bootImageURL {
                    Text(selected.lastPathComponent)
                        .font(.caption)
                }
                Button {
                    selectImage = .bootImage
                    isFileImporterPresented.toggle()
                } label: {
                    Text("Browse")
                }.buttonStyle(BigButtonStyle(width: 150, height: 50))
                .disabled(wizardState.isBusy)
            }
            if wizardState.isBusy {
                BigWhiteSpinner()
            }
            Spacer()
        }.fileImporter(isPresented: $isFileImporterPresented, allowedContentTypes: [.data], onCompletion: processImage)
    }
    
    private func processImage(_ result: Result<URL, Error>) {
        wizardState.busyWork {
            let url = try result.get()
            DispatchQueue.main.async {
                switch selectImage {
                case .kernel:
                    wizardState.linuxKernelURL = url
                case .initialRamdisk:
                    wizardState.linuxInitialRamdiskURL = url
                case .bootImage:
                    wizardState.bootImageURL = url
                }
            }
        }
    }
}

@available(iOS 14, macOS 11, *)
struct VMWizardOSLinuxView_Previews: PreviewProvider {
    @StateObject static var wizardState = VMWizardState()
    
    static var previews: some View {
        VMWizardOSLinuxView(wizardState: wizardState)
    }
}