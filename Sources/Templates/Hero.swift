//
//  Hero.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 7/17/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

public extension Templates {
    class Hero: ObservableObject {
        @Published public var present: Bool?

        public init() {}
        
        public func go() {
            guard present == nil else { return }
            present = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                withAnimation {
                    self.present = true
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.present = nil
            }
        }

        public func revert() {
            guard present == nil else { return }
            present = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.005) {
                withAnimation {
                    self.present = false
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.present = nil
            }
        }

        public func toggle() {
            if present == nil {
                go()
            } else {
                revert()
            }
        }
    }
}
