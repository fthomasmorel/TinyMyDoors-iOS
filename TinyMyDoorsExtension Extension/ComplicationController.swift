//
//  ComplicationController.swift
//  TinyMyDoorsExtension Extension
//
//  Created by Florent THOMAS-MOREL on 12/22/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        let template = generateTemplate(family: complication.family)
        let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template!)
        handler(entry)
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        let template = generateTemplate(family: complication.family)
        let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template!)
        handler([entry])
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        let template = generateTemplate(family: complication.family)
        let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template!)
        handler([entry])
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        let template = generateTemplate(family: complication.family)
        handler(template)
    }
    
    func generateTemplate(family: CLKComplicationFamily) -> CLKComplicationTemplate? {
        var template: CLKComplicationTemplate? = nil
        switch family {
        case .modularSmall:
            let modularSmall = CLKComplicationTemplateModularSmallSimpleImage()
            modularSmall.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Complication/Modular"))
            template = modularSmall
        case .modularLarge:
            let modularLarge = CLKComplicationTemplateModularLargeStandardBody()
            modularLarge.headerImageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Complication/Modular"))
            modularLarge.headerTextProvider = CLKSimpleTextProvider(text: "MyDoors")
            modularLarge.body1TextProvider = CLKSimpleTextProvider(text: "Ouvrir l'application")
            template = modularLarge
        case .utilitarianSmall:
            let utilitarianSmall = CLKComplicationTemplateUtilitarianSmallFlat()
            utilitarianSmall.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Complication/Utilitarian"))
            utilitarianSmall.textProvider = CLKSimpleTextProvider(text: "MDRS")
            template = utilitarianSmall
        case .utilitarianLarge:
            let utilitarianLarge = CLKComplicationTemplateUtilitarianLargeFlat()
            utilitarianLarge.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Complication/Utilitarian"))
            utilitarianLarge.textProvider = CLKSimpleTextProvider(text: "MyDoors")
            template = utilitarianLarge
        case .utilitarianSmallFlat:
            let utilitarianSmall = CLKComplicationTemplateUtilitarianSmallFlat()
            utilitarianSmall.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Complication/Circular"))
            utilitarianSmall.textProvider = CLKSimpleTextProvider(text: "MyDoors")
            template = utilitarianSmall
        case .circularSmall:
            let circularSmall = CLKComplicationTemplateCircularSmallSimpleImage()
            circularSmall.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Complication/Circular"))
            template = circularSmall
        case .extraLarge:
            let extraLarge = CLKComplicationTemplateExtraLargeSimpleImage()
            extraLarge.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "Complication/Extra Large"))
            template = extraLarge
        }
        return template
    }
    
}
