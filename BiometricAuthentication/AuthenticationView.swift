//
//  AuthenticationView.swift
//  BiometricAuthentication
//
//  Created by Dinh Quang Hieu on 09/03/2022.
//

import SwiftUI
import LocalAuthentication

struct AuthenticationView: View {
  
  @ObservedObject var authenticator = Authenticator.shared
  
  var body: some View {
    ZStack {
      Color(.systemBackground)
        .opacity(0.1)
        .background(.ultraThinMaterial)
      VStack(spacing: 16) {
        Button {
          authenticator.invalidate()
          authenticator.validate()
        } label: {
          VStack(spacing: 16) {
            Image(systemName: authenticator.lockImageName)
              .resizable()
              .scaledToFit()
              .frame(width: 40, height: 40)
            Text("Tap to unlock")
          }
        }
        if let error = authenticator.authenticationError {
          Text(error)
            .foregroundColor(.red)
        }
      }
    }
    .edgesIgnoringSafeArea(.all)
  }
}

#if DEBUG
struct AuthenticationView_Previews: PreviewProvider {
  static var previews: some View {
    AuthenticationView()
  }
}
#endif
