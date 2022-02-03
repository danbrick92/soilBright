//
//  WeighViewController.swift
//  SoilBright
//
//  Created by Dan Brickner on 6/22/20.
//  Copyright © 2020 Dan Brickner. All rights reserved.
//

import UIKit

class WeighViewController: UIViewController {

    let bluetooth = Shared.instance
    @IBAction func readyButton(_ sender: Any) {
        if (bluetooth.simulation == false) {
            bluetooth.sendData("weight_ready")
        }
        else{
            bluetooth.weight = "70.0"
            nextScreen()
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        bluetooth.updateLabel = updateLabel // set bluetooth singleton updateLabel method to this one
        bluetooth.connectionEstablished = connectionEstablished
        if (bluetooth.weight != "null") {
            nextScreen()
        }
        // Do any additional setup after loading the view.
    }
    
    func nextScreen() {
        bluetooth.weightController = true
        self.performSegue(withIdentifier: "weighMoisture", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkControllerState()
        viewDidLoad()
    }
    
    func checkControllerState(){
        let state = bluetooth.checkExpectedMode(className: "weight")
        if (state == "start"){
            bluetooth.dataReceived = "null"
            self.performSegue(withIdentifier: "backStartWeight", sender: self)
        }
        else if (state == "second"){
            bluetooth.dataReceived = "null"
            self.performSegue(withIdentifier: "backSecondWeight", sender: self)
        }
    }
    
    func updateLabel () {
        if bluetooth.dataReceived != "null"{
            bluetooth.weight = bluetooth.dataReceived
            bluetooth.dataReceived = "null"
            viewDidLoad()
        }
        
    }
    
    func connectionEstablished(){
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
