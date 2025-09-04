//
//  LoadingHUD.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 04/09/25.
//

import UIKit
import SnapKit

final class LoadingHUD: UIView {
    private let indicator = UIActivityIndicatorView(style: .large)
    
    private let blur = UIVisualEffectView().configure {
        $0.setCornerRadius(radius: 16)
        $0.effect = UIBlurEffect(style: .systemChromeMaterial)
    }
    
    private let stack = UIStackView().configure {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 12
    }
    
    private let label = UILabel().configure {
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.textAlignment = .center
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        accessibilityViewIsModal = true
        backgroundColor = .black.withAlphaComponent(0.15)
        stack.addArrangedSubviews(indicator, label)
        blur.contentView.addSubview(stack)
        addSubview(blur)
        blur.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        stack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    static func show(in view: UIView, text: String? = nil) {
        // If already showing, just update text
        if let existing = view.subviews.first(where: { $0 is LoadingHUD }) as? LoadingHUD {
            existing.label.text = text
            existing.label.isHidden = text == nil
            return
        }
        let hud = LoadingHUD()
        hud.indicator.startAnimating()
        hud.label.text = text
        hud.label.isHidden = text == nil
        view.addSubview(hud)
        hud.snp.makeConstraints { $0.edges.equalToSuperview() }
        hud.alpha = 0
        UIView.animate(withDuration: 0.2) { hud.alpha = 1 }
    }

    static func hide(from view: UIView) {
        guard let hud = view.subviews.first(where: { $0 is LoadingHUD }) as? LoadingHUD else { return }
        UIView.animate(
            withDuration: 0.2,
            animations: { hud.alpha = 0 }
        ) { _ in
            hud.indicator.stopAnimating()
            hud.removeFromSuperview()
        }
    }
}
