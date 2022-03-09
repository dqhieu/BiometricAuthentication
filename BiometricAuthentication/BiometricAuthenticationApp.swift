//
//  BiometricAuthenticationApp.swift
//  BiometricAuthentication
//
//  Created by Dinh Quang Hieu on 09/03/2022.
//

import SwiftUI
import Foundation

@main
struct BiometricAuthenticationApp: App {
  
  @State var lastActiveTime: Date? = nil
  var authenticator = Authenticator.shared
  var authenticationDelayDuration: Double = 0 // change this to delay the authentication
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
          if authenticator.isAuthenticated {
            lastActiveTime = Date()
          }
          authenticator.showValidationView()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
          if authenticationDelayDuration <= 0 || abs(lastActiveTime?.timeIntervalSinceNow ?? 0) > authenticationDelayDuration {
            authenticator.validate()
          } else {
            authenticator.hideValidationView()
          }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
          authenticator.invalidate()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
          if let lastActiveTime = lastActiveTime,
             abs(lastActiveTime.timeIntervalSinceNow) < authenticationDelayDuration {
            authenticator.hideValidationView()
          }
        }
        .onAppear {
          if !authenticator.isAuthenticated {
            authenticator.showValidationView()
            authenticator.validate()
          }
        }
    }
  }
}
