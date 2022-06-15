//
//  ScreenMapView.swift
//  GBMaps
//
//  Created by Vitalii Sukhoroslov on 14.06.2022.
//

import UIKit
import GoogleMaps

// MARK: - ScreenMapView
final class ScreenMapView: UIView {
    
    /// MapView
    private(set) lazy var mapView: GMSMapView = {
        let map = GMSMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    /// Инициализтор
    /// - Parameter frame: frame
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
        self.addUIInView()
        self.setupConstreints()
    }
    
    /// - Parameter aDecoder: aDecoder
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

//MARK: - Private
private extension ScreenMapView {
    
    /// Настройка view
    func setupView() -> Void {
        self.backgroundColor = .red
    }
    
    /// Добавим UI на SettingsView
    func addUIInView() -> Void {
        self.addSubview(mapView)
    }
    
    /// Раставим констрейнты
    func setupConstreints() -> Void {
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: self.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
