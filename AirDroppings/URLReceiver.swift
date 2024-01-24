//
//  URLReceiver.swift
//  FlightBriefing
//
//  Created by Johan Nyman on 2022-06-12.
//  Copyright © 2022 JN Avionics. All rights reserved.
//

import UIKit
import Logging



class URLReceiver {
    
    func openURL(_ url: URL, in mainView: MainMenuViewController) -> Bool {

        
        //File reception
        Log.trace(message: "File reception of \(url.lastPathComponent)", in: .urlScheme)

        var data: Data
        do {
            if url.startAccessingSecurityScopedResource() {
                defer {
                    url.stopAccessingSecurityScopedResource()
                }

                //a:
                data = try Data(contentsOf: url, options: .mappedIfSafe)

            } else {

                //MARK: This is where I end up every time, meaning that startAccessing... returns false.
                // If I instead comment out the whole securityScoped part, and only keep the line at (a:), I will instead get
                // "The file “FlightBriefing Package-4D6E-A2B1-97-0.fltpkg” couldn’t be opened because you don’t have permission to view it."

                throw Log.createError(NSLocalizedString("Unable to access security scoped data", comment: "Security scope unwilling to let go of the file."), code: 6, domain: "SecurityScopedFileDomain")
            }
        } catch {
            let message = {
                if (error as NSError).domain == "SecurityScopedFileDomain" {
                    return "Data is privacy protected, unable to read file."
                } else {
                    return "Unable to access data."
                }
            }()
            Log.error(error, message: message, in: .urlScheme)
            //Tell user in an ugly hack
            Task { @MainActor in
                mainView.showAlert(title: "Error", message: message, buttonTitle: "OK")
            }
            return false; //No use continue
        }
        
        if url.pathExtension == "pltinp" {
            
            return loadInputWith(data: data, mainView: mainView, userInteraction: true)
            
        } else if url.pathExtension == "fltpkg" {
            
            guard let subdir = url.lastPathComponent.components(separatedBy: ".").first else {
                return false
            }
            
            return loadFlightWith(data: data, subdir: subdir, mainView: mainView)

        } else if url.pathExtension == "flt" {
            
            guard let subdir = url.lastPathComponent.components(separatedBy: ".").first else {
                return false
            }
            
            return loadPackageWith(data: data, subdir: subdir, mainView: mainView)
        }
        
        Log.notify(message: "Unhandled reception of \(url)", in: .urlScheme)
        return false
    }
    
    //MARK: - Flight reception by airdrop or mail
    
    private func loadFlightWith(data: Data,
                                subdir: String,
                                mainView: MainMenuViewController) -> Bool {
        //Parse data
        do {
            guard let dataArray = try NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClass: NSData.self, from: data) as [Data]? else {
                return false
            }

            Log.trace(message: "Flight parsed, \(dataArray.count) parts.", in: .urlScheme)
            return true
        } catch {
            Log.error(error, message: "Invalid flight received.", in: .urlScheme)
            //Tell user in an ugly hack
            Task { @MainActor in
                mainView.showAlert(title: "Error", message: "Invalid flight file.", buttonTitle: "OK")
            }
            return false; //No use continue
        }
    }
    
    //MARK: - PilotInput reception by airdrop or mail
    
    private func loadInputWith(data: Data, mainView: MainMenuViewController, userInteraction: Bool) -> Bool {

        do {
            guard let receivedInput = try JSONSerialization.jsonObject(with: data,
                                                                       options: []) as? Dictionary<String, AnyObject> else {
                return false
            }
            
            //Load input in main view
            return mainView.receiveAirdrop(input: receivedInput, askUser: userInteraction)
            
        } catch {
            Log.error(error, message: "Invalid pilotInput received.", in: .urlScheme)
            //Tell user in an ugly hack
            Task { @MainActor in
                mainView.showAlert(title: "Error", message: "Invalid pilot input.", buttonTitle: "OK")
            }
            return false; //No use continue
        }
        
    }
    
    //MARK: - Entire package reception by airdrop or mail
    
    private func loadPackageWith(data: Data, subdir: String, mainView: MainMenuViewController) -> Bool {

        do {
            //Load the data
            guard let dataArray = try NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClass: NSData.self, from: data) as [Data]?,
                  dataArray.count == 2,
                  let flightData = dataArray.first,
                  let input = dataArray.last else {
                      return false
                  }
            
            
            Log.trace(message: "Loading flight", in: .urlScheme)

            Task.init(priority: .background) {

                //Load flight
                _ = loadFlightWith(data: flightData, subdir: subdir, mainView: mainView)

                //Load input
                //...After a while to permit the flight to exist first (parsed in another thread)
                sleep(10)
                //Convert to await (above) in a future version
                
                Log.trace(message: "Loading input", in: .urlScheme)

                _ = loadInputWith(data: input, mainView: mainView, userInteraction: false)

                //Hide HUD
                //...After a while to permit the input to be completed first (parsed in another thread)
                sleep(5)
                Log.trace(message: "Done!", in: .urlScheme)

            }
            
            return true //and hope it works out...
            
        } catch {
            Log.error(error, message: "Invalid flight package received.", in: .urlScheme)
            //Tell user in an ugly hack
            Task { @MainActor in
                mainView.showAlert(title: "Error", message: "Invalid flight file.", buttonTitle: "OK")
            }
            return false; //No use continue
        }
    }
    
}
