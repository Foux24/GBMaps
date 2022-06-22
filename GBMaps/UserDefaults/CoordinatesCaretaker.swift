//
//  CoordinatesCaretaker.swift
//  GBMaps
//
//  Created by Vitalii Sukhoroslov on 19.06.2022.
//

import Foundation

// MARK: - CoordinatesCaretaker
final class CoordinatesCaretaker {
    
    /// Кодер и Декодер
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    /// Ключ для запроса данных
    private let key = "coordinate"
    
    /// Сохранение массива координат
    /// - Parameter coordinate: Массив с координатами
    func saveCoordinate(coordinate: [ModelCoordinate]) {
        do {
            let data = try self.encoder.encode(coordinate)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print(error)
        }
    }
    
    /// Загрузка координат из памяти
    func loadCoordinate() -> [ModelCoordinate] {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return []
        }
        do {
            return try self.decoder.decode([ModelCoordinate].self, from: data)
        } catch {
            print(error)
            return []
        }
    }
}
