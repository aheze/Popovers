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
        }

        public func revert() {
            guard present != nil else { return }
            withAnimation {
                present = false
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
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
