//
//  CalibrationViewController.swift
//  SoilBright
//
//  Created by Dan Brickner on 6/22/20.
//  Copyright © 2020 Dan Brickner. All rights reserved.
//

import UIKit

class CalibrationViewController: UIViewController {

    @IBOutlet weak var calInitInput: UITextField!
    
    let bluetooth = Shared.instance
    
    @IBAction func calInitSubmit(_ sender: Any) {
        if (bluetooth.simulation == false){
            bluetooth.sendData(calInitInput.text!)
        }
        else {
            nextScreen()
        }
        
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        bluetooth.updateLabel = updateLabel // set bluetooth singleton updateLabel method to this one
        bluetooth.connectionEstablished = connectionEstablished
        calInitInput.keyboardType = UIKeyboardType.numberPad
        //let tap = UIGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        //view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
        if (bluetooth.dataReceived == "ready_for_weight")
        {
            nextScreen()
        }
    }
    
    func nextScreen() {
        bluetooth.dataReceived = "null"
        bluetooth.calController = true
        self.performSegue(withIdentifier: "calibrateWeight", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkControllerState()
        viewDidLoad()
    }
    
    func checkControllerState(){
        let state = bluetooth.checkExpectedMode(className: "calibrate")
        if (state == "start"){
            bluetooth.dataReceived = "null"
            self.performSegue(withIdentifier: "backStartCal", sender: self)
        }
        else if (state == "second"){
            bluetooth.dataReceived = "null"
            self.performSegue(withIdentifier: "backSecondCal", sender: self)
        }
    }
    
    func updateLabel () {
        viewDidLoad()
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
