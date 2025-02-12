//
//  TypeStore.swift
//  EasyAccounts
//
//  Created by 沈俊杰 on 2025/2/11.
//

import Foundation


struct TypeResponse: Codable {
    let code: Int
    let data: [TypeListResponseDto]?
    let msg: String?
}

struct TypeListResponseDto: Identifiable, Codable {
    var id: Int
    var parent: Int?
    var childrenTypes: [TypeListResponseDto]?
    var disable: Bool
    var hasChild: Bool
    var archive: Bool
    var action: Action?
    var tname: String
}

// 更新单条分类的实体类，提供parent默认值，删除children
struct TypeSingleDto: Identifiable, Codable {
    var id: Int?           // 当新增一个分类时，id可能为空，由数据库自增
    var tname: String
    var parent = -1
    var disable = false    // 逻辑删除 标记位
    var archive: Bool
    var actionId: Int?
}

class TypeStore: ObservableObject {
    @Published var typeListResponseDtoList = [TypeListResponseDto(id: 1, parent: -1, childrenTypes: [], disable: false, hasChild: false, archive:false, action: nil, tname: "测试")]
    
    init(){
        loadTypes()
    }
    
    // 向后端请求获取所有类别信息列表
    func loadTypes() {
        let url = URL(string: "http://localhost:8085/type/getType")!
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print("No data received: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            guard let baseDto = try? JSONDecoder().decode(TypeResponse.self, from: data) else {
                print("Unable to decode JSON data")
                return
            }
            
//            print(baseDto)
            
            DispatchQueue.main.async {
                self.typeListResponseDtoList = baseDto.data!
            }
        }.resume()
    }
    
    // 更新Type
    func updateType(typeSingleDto: TypeSingleDto){
        guard let url = URL(string: "http://localhost:8085/type/updateType/\(typeSingleDto.id!)") else {
                print("Invalid URL")
                return
            }
        
        print(url)
        
        print(typeSingleDto)
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
        do {
            let jsonData = try JSONEncoder().encode(typeSingleDto)
            request.httpBody = jsonData
        } catch {
            print("Error encoding JSON: \(error)")
            return
        }
            
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error with request: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                return
            }
            
            if let mimeType = response?.mimeType, mimeType == "application/json",
               let data = data {
                do {
                    let jsonResponse = try JSONDecoder().decode(TypeResponse.self, from: data)
                    print("JSON: \(jsonResponse)")
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            }
            
            DispatchQueue.main.async {
                // 在更新成功后，本地更新数据列表
                if let index = self.typeListResponseDtoList.firstIndex(where: { $0.id == typeSingleDto.id! }) {
                    // typeSingleDto 转为 typeListResponseDto
                    // TODO 转换的时候没有考虑hasChild属性
                    self.typeListResponseDtoList[index] = TypeListResponseDto(id: typeSingleDto.id!, disable: typeSingleDto.disable, hasChild: false, archive: typeSingleDto.archive, tname: typeSingleDto.tname)
                }
            }
        }
        task.resume()
    }
    
    // 新增一个Type
    // http://localhost:8085/type/addType
    func addType(typeSingleDto: TypeSingleDto) {
        let url = URL(string: "http://localhost:8085/type/addType")!
            
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(typeSingleDto)
            request.httpBody = jsonData
        } catch {
            print("Error encoding JSON: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error with request: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                return
            }
            
            if let mimeType = response?.mimeType, mimeType == "application/json",
               let data = data {
                do {
                    let jsonResponse = try JSONDecoder().decode(TypeSingleDto.self, from: data)
                    print("JSON: \(jsonResponse)")
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            }
            
            // 更新published的属性
            DispatchQueue.main.async {
                // 在成功新增之后，更新本地数据
                // 将TypeSingleDto转化为TypeListResponseDto
                // TODO 转换的时候没有考虑hasChild属性
                // TODO addType向后端传递的时候，id还没有生成，是nil（且后端响应也没有响应受影响的id或实体类，这是不对的，我去修改后端响应）
                self.typeListResponseDtoList.append(TypeListResponseDto(id: typeSingleDto.id!, disable: typeSingleDto.disable, hasChild: false, archive: typeSingleDto.archive, tname: typeSingleDto.tname))
            }
        }
        task.resume()
    }
    
    // 删除一个Type,基于id
    func deleteType(typeSingleDto: TypeSingleDto){
        guard let url = URL(string: "http://localhost:8085/type/deleteType/\(typeSingleDto.id!)") else {
                print("Invalid URL")
                return
            }
        
        print(url)
        
        print(typeSingleDto)
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
        do {
            let jsonData = try JSONEncoder().encode(typeSingleDto)
            request.httpBody = jsonData
        } catch {
            print("Error encoding JSON: \(error)")
            return
        }
            
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error with request: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                return
            }
            
            if let mimeType = response?.mimeType, mimeType == "application/json",
               let data = data {
                do {
                    let jsonResponse = try JSONDecoder().decode(TypeResponse.self, from: data)
                    print("JSON: \(jsonResponse)")
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            }
            
            // 更新published的属性
            DispatchQueue.main.async {
                // 在成功新增之后，更新本地数据
                self.typeListResponseDtoList.removeAll { $0.id == typeSingleDto.id }
            }
        }
        task.resume()
    }
}
