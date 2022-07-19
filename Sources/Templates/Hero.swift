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
        public enum Selection {
            case a
            case b
        }

        @Published public var selection: Selection?

        public init() {}

        public func transitionForwards() {
            guard selection == nil else { return }
            selection = .a
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation {
                    self.selection = .b
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.selection = nil
            }
        }

        public func moveForwards() {
            guard selection == nil else { return }
            selection = .a
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation {
                    self.selection = .b
                }
            }
        }

        public func moveBackwards() {
            guard selection == .b else { return }
            selection = .a

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.selection = nil
            }
        }

        public func toggleMove() {
            if selection == .none {
                moveForwards()
            } else {
                moveBackwards()
            }
        }
    }
}
