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
    
    /// UserDefaults Coordinate
    private lazy var coordinate = Coordinate.shared
    
    /// Таймер
    var timer: Timer?
    
    /// Время, когда таймер был запущен
    var startTime: Date?
    
    /// Интервал, в течение которого должен работать таймер, в секундах
    let timeInterval: TimeInterval = 180
    
    /// Идентификатор фоновой задачи
    var beginBackgroundTask: UIBackgroundTaskIdentifier?
    
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
    
    var route: GMSPolyline?
    var routePath: GMSMutablePath?
    
    var oldCoordinate = [CLLocationCoordinate2D]()
    var currentCoordintae = [CLLocationCoordinate2D]()
    
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
        self.configureCoordinate(locations: locations)
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
        locationManager?.delegate = self
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
//        locationManager?.startMonitoringSignificantLocationChanges()
        locationManager?.requestAlwaysAuthorization()
    }
    
    /// Конфигурация начальной карты
    @objc func configureMap() {
        let camera = GMSCameraPosition.camera(withTarget: coordinateCenterMSK, zoom: 15)
        mapView.mapView.camera = camera
    }
    
    /// Обновление карты на новый маршрут
    @objc func updateLocation() {
        self.clearMap()
        locationManager?.startUpdatingLocation()
    }
    
    /// Остановка слежения
    @objc func stopUpdateLocation() {
        locationManager?.stopUpdatingLocation()
        self.coordinate.clearCoordinate()
        routePath.flatMap { routePath in
            for index in 0..<routePath.count() {
                self.coordinate.saveCoordinate(
                    ModelCoordinate(
                        latitude: routePath.coordinate(at: index).latitude,
                        longitude: routePath.coordinate(at: index).longitude)
                )
            }
        }
    }
    
    /// Настройка навибара
    func setupNavigation() -> Void {
        
        self.navigationItem.leftBarButtonItems = [
            UIBarButtonItem(
                title: "New Track",
                style: .done,
                target: self,
                action: #selector(updateLocation))]
        
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                title: "Stop Track",
                style: .done,
                target: self,
                action: #selector(stopUpdateLocation)),
            UIBarButtonItem(
                title: "Old track",
                style: .done,
                target: self,
                action: #selector(actionOldTrackButton)
            )]
    }
    
    /// DelegateSetup
    func setupDelegate() {
        mapView.mapView.delegate = self
        locationManager?.delegate = self
    }
    
    func configureTimer() {
        beginBackgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            guard let self = self else { return }
            guard let beginBackgroundTask = self.beginBackgroundTask else { return }
            UIApplication.shared.endBackgroundTask(beginBackgroundTask)
            self.beginBackgroundTask = UIBackgroundTaskIdentifier.invalid
        }
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            print(Date())
            guard let startTime = self?.startTime,
                  let timeInterval = self?.timeInterval,
                  let beginBackgroundTask = self?.beginBackgroundTask else { return }
            let leftSeconds = Date().timeIntervalSince1970 - startTime.timeIntervalSince1970
            if leftSeconds >= timeInterval {
                self?.timer?.invalidate()
                self?.timer = nil
                UIApplication.shared.endBackgroundTask(beginBackgroundTask)
                self?.beginBackgroundTask = UIBackgroundTaskIdentifier.invalid }
        }
    }
    
    func configureTimerTwo(location: CLLocation) {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            print(Date())
        }
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: OperationQueue.main) { [weak self] _ in
                self?.timer?.invalidate()
                self?.timer = nil
            }
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: OperationQueue.main) { [weak self] _ in
                self?.configureTimerTwo(location: location)
        }
    }
    
    func configureCoordinate(locations: [CLLocation]) {
        beginBackgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            guard let self = self else { return }
            guard let beginBackgroundTask = self.beginBackgroundTask else { return }
            UIApplication.shared.endBackgroundTask(beginBackgroundTask)
            self.beginBackgroundTask = UIBackgroundTaskIdentifier.invalid
        }
        startTime = Date()
        guard let location = locations.last else { return }
        geocoder.reverseGeocodeLocation(location) { [weak self] places, error in
            guard let startTime = self?.startTime,
                  let timeInterval = self?.timeInterval,
                  let beginBackgroundTask = self?.beginBackgroundTask else { return }
            let leftSeconds = Date().timeIntervalSince1970 - startTime.timeIntervalSince1970
            guard let self = self else { return }
            self.routePath?.add(location.coordinate)
            self.route?.path = self.routePath
            let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 14)
            self.mapView.mapView.animate(to: position)
            if leftSeconds >= timeInterval {
                self.timer?.invalidate()
                self.timer = nil
                print(location.coordinate, "ТУТ БЫЛА ПОСЛЕДННЯЯ ВЫПОЛНЕНАЯ ЗАДАЧА ТАРМ ПАМ ПАМ МАП ПАМ ПАМ ПАМ")
                UIApplication.shared.endBackgroundTask(beginBackgroundTask)
                self.beginBackgroundTask = UIBackgroundTaskIdentifier.invalid
            }
        }
    }
    
    /// ActionOldTrackButton
    @objc func actionOldTrackButton() {
        guard let locationManager = locationManager else { return }
        if locationManager.isAuthorizedForWidgetUpdates {
            self.showAlert(title: "Трекер запущен", message: "Нажмимая ОК, трекер остановиться и покажет последний маршрут")
        } else {
            self.clearMap()
            for location in self.coordinate.coordinate {
                self.routePath?.addLatitude(location.latitude, longitude: location.longitude)
                self.route?.path = self.routePath
            }
        }
    }
    
    /// Показ алерта
    func showAlert(title: String, message: String) -> Void {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (result : UIAlertAction) -> Void in
            self.locationManager?.stopUpdatingLocation()
            self.clearMap()
            for location in self.coordinate.coordinate {
                self.routePath?.addLatitude(location.latitude, longitude: location.longitude)
                self.route?.path = self.routePath
            }
            let coordinate = CLLocationCoordinate2D(latitude: self.coordinate.coordinate.last!.latitude, longitude: self.coordinate.coordinate.last!.longitude)
            let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: 17)
            self.mapView.mapView.camera = camera
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    /// Очистка карты
    func clearMap() {
        // Отвязываем от карты старую линию
        route?.map = nil
        // Заменяем старую линию новой
        route = GMSPolyline()
        // Заменяем старый путь новым, пока пустым (без точек)
        routePath = GMSMutablePath()
        // Добавляем новую линию на карту
        route?.map = mapView.mapView
    }
}
