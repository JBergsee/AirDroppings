//
//  ViewController.swift
//  AirDroppings
//
//  Created by Johan Bergsee on 2024-01-23.
//
//

import UIKit
import Logging

class MainMenuViewController: UIViewController {


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showAlert(title: "Application started", buttonTitle: "OK")
    }

    func receiveAirdrop(input: Dictionary<String,AnyObject>, askUser: Bool) -> Bool {

        if (askUser) {

            //Warn user
            let msg = "Merging input from your colleague may overwrite your own if you have filled in the same fields.\nETOPS Master WILL overwrite your input.\nHow do you want to continue?"

            //merge button
            let mergeAction = UIAlertAction(title: "Merge input",
                                            style: .default) { action in

                Log.trace(message: "Merged airdropped input", in: .functionality)

            }

            //ETOPS Master button
            let etopsAction = UIAlertAction(title: "ETOPS Master",
                                            style: .destructive) { action in


                Log.trace(message: "Imported ETOPS Master", in: .functionality)

            }

            //Cancel button
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

            showAlert(title: "Import?", message: msg, actions: [mergeAction, etopsAction, cancelAction])

            return true

        } else {
            //add the input to the correct flight, without any user interaction
            //This is normally the case when importing a file.

            Log.trace(message: "Imported pilotInput for [unknown flight])", in: .functionality)

            return true
        }
    }
}

extension MainMenuViewController {

    func showAlert(title: String?, message: String? = "", buttonTitle: String) {

        let defaultAction = UIAlertAction(title: buttonTitle,
                                          style: .default,
                                          handler: nil)
        showAlert(title: title, message: message, actions: [defaultAction])
    }

    func showAlert(title: String?, message: String? = "", actions: Array<UIAlertAction>) {

        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)

        for action in actions {
            alert.addAction(action)
        }

        present(alert, animated: true)

    }
}
