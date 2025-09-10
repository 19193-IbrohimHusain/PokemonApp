//
//  LoadingHUDNode.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 05/09/25.
//

import AsyncDisplayKit
import UIKit

final class LoadingHUDNode: ASDisplayNode {
    private let blurNode = ASDisplayNode {
        UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
    }.configure {
        $0.cornerRadius = 16
        $0.clipsToBounds = true
    }
    
    private let indicatorNode = ASDisplayNode {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.startAnimating()
        return activityIndicator
    }
    
    private let labelNode = ASTextNode()
    
    private init(text: String?) {
        super.init()
        automaticallyManagesSubnodes = true
        accessibilityViewIsModal = true
        backgroundColor = .black.withAlphaComponent(0.15)
        labelNode.attributedText = NSAttributedString(
            string: text.orEmpty,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                .foregroundColor: UIColor.label
            ]
        )
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        var children = [indicatorNode]
        if let text = labelNode.attributedText?.string, !text.isEmpty {
            children.append(labelNode)
        }
        
        let stack = ASStackLayoutSpec(
            direction: .vertical,
            spacing: 12,
            justifyContent: .center,
            alignItems: .center,
            children: children
        )
        
        let stackInset = ASInsetLayoutSpec(insets: .init(top: 40, left: 40, bottom: 40, right: 40), child: stack)
        let bubble = ASBackgroundLayoutSpec(child: stackInset, background: blurNode)
        return ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: bubble)
    }
    
    private func setTitle(with text: String?) {
        labelNode.attributedText = NSAttributedString(
            string: text.orEmpty,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                .foregroundColor: UIColor.label
            ]
        )
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    static func show(in node: ASDisplayNode, text: String? = nil) {
        // If already exists, update text
        if let existing = node.subnodes?.first(where: { $0 is LoadingHUDNode }) as? LoadingHUDNode {
            existing.labelNode.attributedText = NSAttributedString(
                string: text.orEmpty,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                    .foregroundColor: UIColor.label
                ]
            )
            existing.alpha = 1
            return
        }
        let hud = LoadingHUDNode(text: text)
        current = hud
        node.addSubnode(hud)
        hud.frame = node.bounds
        hud.alpha = 0
        UIView.animate(withDuration: 0.2) { hud.alpha = 1 }
    }
    
    static func hide() {
        guard let hud = current else { return }
        UIView.animate(withDuration: 0.2, animations: { hud.alpha = 0 }) { _ in
            hud.removeFromSupernode()
            current = nil
        }
    }
}

extension LoadingHUDNode {
    private static weak var current: LoadingHUDNode?

    static func show(text: String? = nil) {
        guard let window = UIWindow.keyWindow else { return }
        if let existing = current {
            if existing.view.superview == nil {
                window.addSubview(existing.view)
                existing.frame = window.bounds
            }
            existing.setTitle(with: text)
            if existing.alpha < 1 {
                UIView.animate(withDuration: 0.2) { existing.alpha = 1 }
            }
            return
        }

        let hud = LoadingHUDNode(text: text)
        current = hud
        window.addSubview(hud.view)
        hud.frame = window.bounds
        hud.alpha = 0
        UIView.animate(withDuration: 0.2) { hud.alpha = 1 }
    }
}
