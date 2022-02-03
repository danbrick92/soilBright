//
//  SecondViewController.swift
//  SoilBright
//
//  Created by Dan Brickner on 6/14/20.
//  Copyright © 2020 Dan Brickner. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    let bluetooth = Shared.instance
    
    @IBOutlet weak var connectStatus: UILabel!

    @IBAction func simulateButton(_ sender: Any) {
        bluetooth.simulation = true
        nextScreen()
    }
    
    @IBAction func resetButton(_ sender: Any) {
        // this button resets the sensor if connected
        if (bluetooth.simulation == false && bluetooth.hasConnected) {
            bluetooth.sendData("reset")
            //sleep(7)
            connectionEstablished()
        }
        // it takes simulation mode off if it was on before
        else{
            bluetooth.simulation = false
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set methods in bluetooth
        bluetooth.updateLabel = updateLabel // set bluetooth singleton updateLabel method to this one
        bluetooth.connectionEstablished = connectionEstablished
        // Check if connected
        if ("connected" == bluetooth.dataReceived)
        {
            nextScreen()
        }
    }
    
    func nextScreen(){
        connectStatus.text = "Connected"
        bluetooth.dataReceived = ""
        if (bluetooth.simulation == false) {
            //sleep(3)
            
        }
        bluetooth.secondController = true
        self.performSegue(withIdentifier: "connectCalibrate", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkControllerState()
        viewDidLoad()
    }
    
    // Checks to see if we need to reset back to start/cal screen
    func checkControllerState(){
        let state = bluetooth.checkExpectedMode(className: "second")
        bluetooth.secondController = false
        if (state == "start"){
            self.performSegue(withIdentifier: "backStartSecond", sender: self)
        }
        else if (state == "second"){
            bluetooth.dataReceived = ""
            if (bluetooth.simulation) {
                bluetooth.simulation = true
            }
            else {
                bluetooth.sendData("reset")
                //sleep(5)
                connectionEstablished()
            }
        }
    }
    
    func connectionEstablished(){
        bluetooth.sendData("bluetooth_ready")
    }
    
    func updateLabel(){
        viewDidLoad()
    }
    
    @IBOutlet weak var TextHere: UILabel!
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
