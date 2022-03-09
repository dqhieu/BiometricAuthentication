//
//  Authenticator.swift
//  BiometricAuthentication
//
//  Created by Dinh Quang Hieu on 09/03/2022.
//

import Foundation
import LocalAuthentication
import UIKit
import SwiftUI

class Authenticator: ObservableObject {
  
  @Published var isAuthenticated = false
  @Published var authenticationError: String? = nil
  
  var lockImageName: String = ""
  
  static let shared = Authenticator()
  
  private var context = LAContext()
  private var overlayWindow: UIWindow?
  
  private init() {
    initContext()
  }
  
  private func initContext() {
    context = LAContext()
    var error: NSError?
    if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
      switch context.biometryType {
      case .faceID:
        lockImageName = "faceid"
      case .touchID:
        lockImageName = "touchid"
      case .none:
        if #available(iOS 15.0, *) {
          lockImageName = "lock.iphone"
        } else {
          lockImageName = "lock"
        }
      @unknown default:
        if #available(iOS 15.0, *) {
          lockImageName = "lock.iphone"
        } else {
          lockImageName = "lock"
        }
      }
    } else {
      if #available(iOS 15.0, *) {
        lockImageName = "lock.iphone"
      } else {
        lockImageName = "lock"
      }
    }
  }
  
  func validate() {
    context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "To use the app, you must unlock first") { [weak self] success, error in
      guard let this = self else { return }
      DispatchQueue.main.async {
        if success {
          this.hideValidationView()
          this.isAuthenticated = true
          this.authenticationError = nil
        } else {
          this.showValidationView()
          this.isAuthenticated = false
          this.authenticationError = error?.localizedDescription
        }
      }
    }
  }
  
  func invalidate() {
    showValidationView()
    isAuthenticated = false
    context.invalidate()
    initContext()
  }
  
  func showValidationView() {
    guard overlayWindow == nil else { return }
    if let currentWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
      overlayWindow = UIWindow(windowScene: currentWindowScene)
    }
    overlayWindow?.windowLevel = UIWindow.Level.alert + 1
    let hostVC = UIHostingController(rootView: AuthenticationView())
    hostVC.view.backgroundColor = .clear
    overlayWindow?.rootViewController = hostVC
    overlayWindow?.backgroundColor = UIColor.clear
    overlayWindow?.makeKeyAndVisible()
  }
  
  func hideValidationView() {
    overlayWindow?.isHidden = true
    overlayWindow = nil
  }
  
  var biometryType: LABiometryType {
    return context.biometryType
  }
}
