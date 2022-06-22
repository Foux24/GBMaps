//
//  Coordinates.swift
//  GBMaps
//
//  Created by Vitalii Sukhoroslov on 19.06.2022.
//

import Foundation

// MARK: - Coordinates
final class Coordinate {
    
    /// Singltone
    static let shared = Coordinate()
    
    /// Coordinates
    private(set) var coordinate: [ModelCoordinate] {
        didSet {
            сoordinatesCaretaker.saveCoordinate(coordinate: coordinate)
        }
    }
    
    /// Инициализтор
    private init() {
        self.coordinate = self.сoordinatesCaretaker.loadCoordinate()
    }
    
    /// CoordinatesCaretaker
    private let сoordinatesCaretaker = CoordinatesCaretaker()
    
    /// Сохранения координат
    /// - Parameter coordinate: Координаты
    func saveCoordinate(_ coordinate: ModelCoordinate) {
        self.coordinate.append(coordinate)
    }
    
    /// Удаления астероидов
    func clearCoordinate() {
        self.coordinate = []
    }
}
