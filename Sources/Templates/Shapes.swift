//
//  Shapes.swift
//  Popovers
//
//  Created by A. Zheng (github.com/aheze) on 2/4/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

public extension Templates {
    // MARK: - Background With Arrow

    /**
     A shape that has an arrow protruding.
     */
    struct BackgroundWithArrow: Shape {
        /// The side of the rectangle to have the arrow
        public var arrowSide: ArrowSide

        /// The shape's corner radius
        public var cornerRadius: CGFloat

        /// The rectangle's width.
        public static var width = CGFloat(48)

        /// The rectangle's height.
        public static var height = CGFloat(12)

        /// The corner radius for the arrow's tip.
        public static var tipCornerRadius = CGFloat(4)

        /// The inverse corner radius for the arrow's base.
        public static var edgeCornerRadius = CGFloat(10)

        /// Offset the arrow from the sides - otherwise it will overflow out of the corner radius.
        /// This is multiplied by the `cornerRadius`.
        /**

                      /\
                     /_ \
            ----------     <---- Avoid this gap.
                        \
             rectangle  |
         */
        public static var arrowSidePadding = CGFloat(1.8)

        /// Path for the triangular arrow.
        public func arrowPath() -> Path {
            let arrowHalfWidth = (BackgroundWithArrow.width / 2) * 0.6

            let arrowPath = Path { path in
                let arrowRect = CGRect(x: 0, y: 0, width: BackgroundWithArrow.width, height: BackgroundWithArrow.height)

                path.move(to: CGPoint(x: arrowRect.minX, y: arrowRect.maxY))
                path.addArc(
                    tangent1End: CGPoint(x: arrowRect.midX - arrowHalfWidth, y: arrowRect.maxY),
                    tangent2End: CGPoint(x: arrowRect.midX, y: arrowRect.minX),
                    radius: BackgroundWithArrow.edgeCornerRadius
                )
                path.addArc(
                    tangent1End: CGPoint(x: arrowRect.midX, y: arrowRect.minX),
                    tangent2End: CGPoint(x: arrowRect.midX + arrowHalfWidth, y: arrowRect.maxY),
                    radius: BackgroundWithArrow.tipCornerRadius
                )
                path.addArc(
                    tangent1End: CGPoint(x: arrowRect.midX + arrowHalfWidth, y: arrowRect.maxY),
                    tangent2End: CGPoint(x: arrowRect.maxX, y: arrowRect.maxY),
                    radius: BackgroundWithArrow.edgeCornerRadius
                )
                path.addLine(to: CGPoint(x: arrowRect.maxX, y: arrowRect.maxY))
            }
            return arrowPath
        }

        /// Draw the shape.
        public func path(in rect: CGRect) -> Path {
            var arrowPath = arrowPath()
            arrowPath = arrowPath.applying(
                .init(translationX: -(BackgroundWithArrow.width / 2), y: -(BackgroundWithArrow.height))
            )

            var path = Path()
            path.addRoundedRect(in: rect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))

            /// Rotation transform to make the arrow hit a different side.
            let arrowTransform: CGAffineTransform

            /// Half of the rectangle's smallest side length, used for the arrow's alignment.
            let popoverRadius: CGFloat

            let alignment: ArrowSide.ArrowAlignment
            switch arrowSide {
            case let .top(arrowAlignment):
                alignment = arrowAlignment
                arrowTransform = .init(translationX: rect.midX, y: 0)
                popoverRadius = (rect.width / 2) - BackgroundWithArrow.arrowSidePadding * cornerRadius
            case let .right(arrowAlignment):
                alignment = arrowAlignment
                arrowTransform = .init(rotationAngle: 90.degreesToRadians)
                    .translatedBy(x: rect.midY, y: -rect.maxX)
                popoverRadius = (rect.height / 2) - BackgroundWithArrow.arrowSidePadding * cornerRadius
            case let .bottom(arrowAlignment):
                alignment = arrowAlignment
                arrowTransform = .init(rotationAngle: 180.degreesToRadians)
                    .translatedBy(x: -rect.midX, y: -rect.maxY)
                popoverRadius = (rect.width / 2) - BackgroundWithArrow.arrowSidePadding * cornerRadius
            case let .left(arrowAlignment):
                alignment = arrowAlignment
                arrowTransform = .init(rotationAngle: 270.degreesToRadians)
                    .translatedBy(x: -rect.midY, y: 0)
                popoverRadius = (rect.height / 2) - BackgroundWithArrow.arrowSidePadding * cornerRadius
            }

            switch alignment {
            case .mostCounterClockwise:
                arrowPath = arrowPath.applying(
                    .init(translationX: -popoverRadius, y: 0)
                )
            case .centered:
                break
            case .mostClockwise:
                arrowPath = arrowPath.applying(
                    .init(translationX: popoverRadius, y: 0)
                )
            }

            path.addPath(arrowPath, transform: arrowTransform)

            return path
        }
    }

    // MARK: - Curve Connector

    /**
     A curved line between 2 points.
     */
    struct CurveConnector: Shape {
        /// The start point.
        public var start: CGPoint

        /// The end point.
        public var end: CGPoint

        /// The curve's steepness.
        public var steepness = CGFloat(0.3)

        /// The curve's direction.
        public var direction = Direction.vertical

        /**
         A curved line between 2 points.
         - parameter start: The start point.
         - parameter end: The end point.
         - parameter steepness: The curve's steepness.
         - parameter direction: The curve's direction.
         */
        public init(
            start: CGPoint,
            end: CGPoint,
            steepness: CGFloat = CGFloat(0.3),
            direction: Templates.CurveConnector.Direction = Direction.vertical
        ) {
            self.start = start
            self.end = end
            self.steepness = steepness
            self.direction = direction
        }

        /**
         Horizontal or Vertical line.
         */
        public enum Direction {
            case horizontal
            case vertical
        }

        /// Allow animations. From https://www.objc.io/blog/2020/03/10/swiftui-path-animations/
        public var animatableData: AnimatablePair<CGPoint.AnimatableData, CGPoint.AnimatableData> {
            get { AnimatablePair(start.animatableData, end.animatableData) }
            set { (start.animatableData, end.animatableData) = (newValue.first, newValue.second) }
        }

        /// Draw the curve.
        public func path(in _: CGRect) -> Path {
            let startControlPoint: CGPoint
            let endControlPoint: CGPoint

            switch direction {
            case .horizontal:
                let curveWidth = end.x - start.x
                let curveSteepness = curveWidth * steepness
                startControlPoint = CGPoint(x: start.x + curveSteepness, y: start.y)
                endControlPoint = CGPoint(x: end.x - curveSteepness, y: end.y)
            case .vertical:
                let curveHeight = end.y - start.y
                let curveSteepness = curveHeight * steepness
                startControlPoint = CGPoint(x: start.x, y: start.y + curveSteepness)
                endControlPoint = CGPoint(x: end.x, y: end.y - curveSteepness)
            }

            var path = Path()
            path.move(to: start)
            path.addCurve(to: end, control1: startControlPoint, control2: endControlPoint)
            return path
        }
    }
}
