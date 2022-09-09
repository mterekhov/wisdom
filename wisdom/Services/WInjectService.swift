//
//  WInjectService.swift
//  wisdom
//
//  Created by cipher on 09.09.2022.
//

import Foundation
import CoreData

fileprivate let CatalogAsanasListKey = "asanas_list"
fileprivate let CatalogDiseasesListKey = "diseases_list"
fileprivate let CatalogDiseaseTitleKey = "title"
fileprivate let CatalogSanskritKey = "sanskrit"
fileprivate let CatalogIASTKey = "iast"
fileprivate let CatalogAboutKey = "about"
fileprivate let CatalogTechniqueStepsListKey = "technique_steps_list"
fileprivate let CatalogEffectKey = "effect"
fileprivate let CatalogAyengarIndexKey = "ayengar_index"
fileprivate let CatalogAyengarRankKey = "ayengar_rank"
fileprivate let CatalogImagesListKey = "images_list"
fileprivate let CatalogDemoImageKey = "demo_image"

protocol WInjectServiceProtocol {

    func resetCatalogInitialization()
    func initializeCatalog(completionBlock: @escaping VoidCompletionHandler)

}

class WInjectService: WInjectServiceProtocol {

    private let UserDefaultsCatalogInitializedKey = "DataBaseInitialized"
    private let TextsFileName = "texts"
    
    public var userDefaults = UserDefaults.standard
    public var coreDataService: WCoreDataServiceProtocol?
    
    convenience init(_ coreDataService: WCoreDataServiceProtocol?, _ userDefaults: UserDefaults) {
        self.init()
        
        self.coreDataService = coreDataService
        self.userDefaults = userDefaults
    }
    
    // MARK: - WInjectServiceProtocol -

    func resetCatalogInitialization() {
        userDefaults.set(false, forKey: UserDefaultsCatalogInitializedKey)
        userDefaults.synchronize()
    }
    
    func initializeCatalog(completionBlock: @escaping VoidCompletionHandler) {
        if checkCatalogInitialization() == true {
            completionBlock()
            return
        }
        
        destroyExistingData { [weak self] in
            guard let self = self else {
                completionBlock()
                return
            }
            
            self.readDataFromJSON(completionBlock: completionBlock)
        }
        
    }
    
    // MARK: - Routine -
    
    private func readDataFromJSON(completionBlock: @escaping VoidCompletionHandler) {
        guard let catalogURL = Bundle.main.url(forResource: TextsFileName, withExtension: "json") else {
            completionBlock()
            return
        }
        
        do {
            let jsonData = try Data(contentsOf: catalogURL)
            guard let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                completionBlock()
                return
            }
            
            transferJSONIntoCoreData(jsonDict: jsonDict)
        }
        catch let error {
            completionBlock()
            return
        }
        
        userDefaults.set(true, forKey: UserDefaultsCatalogInitializedKey)
        userDefaults.synchronize()
        
        completionBlock()
    }
    
    private func destroyExistingData(completionBlock: @escaping VoidCompletionHandler) {
        guard let coreDataService = coreDataService else {
            completionBlock()
            return
        }
        
        coreDataService.asyncExecute { localContext in
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CDText")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                _ = try localContext.execute(deleteRequest)
            }
            catch {
                completionBlock()
            }
            completionBlock()
        }
    }

    /// returns true in case catalog already parsed from JSON into CoreData
    /// - Returns: true or false
    private func checkCatalogInitialization() -> Bool {
        guard let alreadyInitialized = userDefaults.value(forKey: UserDefaultsCatalogInitializedKey) as? Bool else {
            return false
        }
        
        return alreadyInitialized
    }
    
    private func transferJSONIntoCoreData(jsonDict: [String: Any]) {
        guard let coreDataService = coreDataService else {
            return
        }
        
        coreDataService.execute { localContext in
            guard let jsonAsanasList = jsonDict[CatalogAsanasListKey] as? [[String:Any]] else {
                return
            }
            
            for jsonDict in jsonAsanasList {
                let newAsana = CDAsana(context: localContext)
                newAsana.uuid = UUID().uuidString
                newAsana.sanskrit = jsonDict[CatalogSanskritKey] as? String ?? ""
                newAsana.iast = jsonDict[CatalogIASTKey] as? String ?? ""
                newAsana.about = jsonDict[CatalogAboutKey] as? String ?? ""
                newAsana.effect = jsonDict[CatalogEffectKey] as? String ?? ""
                newAsana.ayengarRank = jsonDict[CatalogAyengarRankKey] as? Int64 ?? 0
                newAsana.ayengarIndex = jsonDict[CatalogAyengarIndexKey] as? Int64 ?? 0
                
                newAsana.techniqueStepsList = jsonDict[CatalogTechniqueStepsListKey] as? [String]
                newAsana.imagesList = jsonDict[CatalogImagesListKey] as? [String]
                newAsana.demoImage = jsonDict[CatalogDemoImageKey] as? String
                localContext.yogadipika_saveContext()
            }

            guard let jsonDiseasesList = jsonDict[CatalogDiseasesListKey] as? [[String:Any]] else {
                return
            }

            for jsonDict in jsonDiseasesList {
                let newDisease = CDDisease(context: localContext)
                newDisease.title = jsonDict[CatalogDiseaseTitleKey] as? String ?? ""
                localContext.yogadipika_saveContext()
            }
        }
    }
    
}
