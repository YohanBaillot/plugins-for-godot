//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc.
//
// Licensed under the MIT license (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// LICENSE
//
//===----------------------------------------------------------------------===//

import RealityKit

#if os(macOS)
import AppKit
#else
import UIKit
#endif

// Stores references to debug visualization entities as a RealityKit component,
// so the extension on `Entity` does not need stored properties.
struct DebugVisualizationComponent: Component {
    var sphereEntity: RealityKit.Entity?
    var boxEntity: RealityKit.Entity?
}

extension Entity {

    // MARK: - Private helpers

    private var debugVisualization: DebugVisualizationComponent {
        get {
            MainActor.assumeIsolated {
                self.value.components[DebugVisualizationComponent.self] ?? .init()
            }
        }
        set {
            MainActor.assumeIsolated {
                self.value.components[DebugVisualizationComponent.self] = newValue
            }
        }
    }

    // MARK: - Public API

    public mutating func setDebugCullingSphere(rootEntity: Entity, position: Vector3, radius: Float, alpha: Float = 0.3) {
        MainActor.assumeIsolated {
            let sphereEntity: RealityKit.Entity
            if let existing = debugVisualization.sphereEntity {
                sphereEntity = existing
            } else {
                sphereEntity = RealityKit.Entity()
                debugVisualization.sphereEntity = sphereEntity
            }
            // Retry parenting on every call in case parent wasn't available yet.
            if sphereEntity.parent == nil {
                rootEntity.value.addChild(sphereEntity)
            }
            sphereEntity.name = self.value.name + "__debug_sphere"
            var material = UnlitMaterial()
            #if os(macOS)
            material.color = .init(tint: NSColor(calibratedRed: 0, green: 0.5, blue: 1, alpha: CGFloat(alpha)))
            #else
            material.color = .init(tint: UIColor(red: 0, green: 0.5, blue: 1, alpha: CGFloat(alpha)))
            #endif
            // Use .none so the sphere is visible from inside (camera is often within the culling radius).
            material.faceCulling = .none
            material.blending = alpha < 0.99
                ? .transparent(opacity: .init(floatLiteral: alpha))
                : .opaque
            sphereEntity.components[ModelComponent.self] = ModelComponent(
                mesh: .generateSphere(radius: radius),
                materials: [material]
            )
            sphereEntity.setPosition(position.to_simd(), relativeTo: rootEntity.value)
        }
    }

    public mutating func setDebugBoundingBox(rootEntity: Entity, min: Vector3, max: Vector3, alpha: Float = 0.3) {
        MainActor.assumeIsolated {
            let boxEntity: RealityKit.Entity
            if let existing = debugVisualization.boxEntity {
                boxEntity = existing
            } else {
                boxEntity = RealityKit.Entity()
                debugVisualization.boxEntity = boxEntity
            }
            // Retry parenting on every call in case parent wasn't available yet.
            if boxEntity.parent == nil {
                rootEntity.value.addChild(boxEntity)
            }
            boxEntity.name = self.value.name + "__debug_box"
            let size = SIMD3<Float>(max.x - min.x, max.y - min.y, max.z - min.z)
            let center = SIMD3<Float>((min.x + max.x) / 2, (min.y + max.y) / 2, (min.z + max.z) / 2)
            var material = UnlitMaterial()
            #if os(macOS)
            material.color = .init(tint: NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: CGFloat(alpha)))
            #else
            material.color = .init(tint: UIColor(red: 1, green: 1, blue: 1, alpha: CGFloat(alpha)))
            #endif
            material.faceCulling = .none
            material.blending = alpha < 0.99
                ? .transparent(opacity: .init(floatLiteral: alpha))
                : .opaque
            boxEntity.components[ModelComponent.self] = ModelComponent(
                mesh: .generateBox(size: size),
                materials: [material]
            )
            boxEntity.setPosition(center, relativeTo: rootEntity.value)
        }
    }

    public mutating func clearDebugVisualizations() {
        MainActor.assumeIsolated {
            debugVisualization.sphereEntity?.removeFromParent()
            debugVisualization.boxEntity?.removeFromParent()
            self.value.components.remove(DebugVisualizationComponent.self)
        }
    }
}
