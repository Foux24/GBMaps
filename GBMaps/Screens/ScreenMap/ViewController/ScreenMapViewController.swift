//
//  ScreenMapViewController.swift
//  GBMaps
//
//  Created by Vitalii Sukhoroslov on 14.06.2022.
//

import UIKit
import GoogleMaps
import CoreLocation

// MARK: - ScreenMapViewController
final class ScreenMapViewController: UIViewController {
    
    /// View для контроллера
    private var mapView: ScreenMapView {
        return self.view as! ScreenMapView
    }
    
    /// Центр МСК
    let coordinateCenterMSK = CLLocationCoordinate2D(latitude: 59.939095, longitude: 30.315868)
        
    /// Location Manager
    var locationManager: CLLocationManager?
    
    /// Geocoder
    var geocoder = CLGeocoder()
    
    // MARK: - LifeCycle
    override func loadView() {
        super.loadView()
        self.view = ScreenMapView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        setupNavigation()
        configureLocationManager()
        setupDelegate()
    }
}

// MARK: - Extension ScreenMapViewController on the GMSMapViewDelegate
extension ScreenMapViewController: GMSMapViewDelegate {
    
    /// Получение координат по тапу
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {}
}

// MARK: - Extension ScreenMapViewController on the CLLocationManagerDelegate
extension ScreenMapViewController: CLLocationManagerDelegate {
    
    /// Получение текущих координат
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        geocoder.reverseGeocodeLocation(location) { [weak self] places, error in
            guard let self = self else { return }
            guard let places = places?.first else { return }
            guard let placesLocation = places.location else { return }
            self.mapView.mapView.animate(toLocation: placesLocation.coordinate)
            let marker = GMSMarker(position: placesLocation.coordinate)
            marker.map = self.mapView.mapView
        }
    }
    
    /// Обработка ошибок
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error) }
}

// MARK: - Private
private extension ScreenMapViewController {
    
    /// Создаем обьект locationManager
    func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
    }
    
    /// Конфигурация начальной карты
    @objc func configureMap() {
        let camera = GMSCameraPosition.camera(withTarget: coordinateCenterMSK, zoom: 15)
        mapView.mapView.camera = camera
    }
    
    /// Переход к дворцовой площади
    @objc func updateLocation() {
        locationManager?.startUpdatingLocation()
    }
    
    /// Удаление/Добавление маркера
    @objc func currentLocation() {
        locationManager?.requestLocation()
    }
    
    /// Настройка навибара
    func setupNavigation() -> Void {
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Отслеживать",
            style: .done,
            target: self,
            action: #selector(updateLocation)
        )
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Текущее",
            style: .done,
            target: self,
            action: #selector(currentLocation)
        )
    }
    
    /// DelegateSetup
    func setupDelegate() {
        mapView.mapView.delegate = self
        locationManager?.delegate = self
    }
}
