//
//  ResultsViewController.swift
//  SoilBright
//
//  Created by Dan Brickner on 6/22/20.
//  Copyright © 2020 Dan Brickner. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController {
    @IBAction func nextButton(_ sender: Any) {
        self.performSegue(withIdentifier: "resultsLearning", sender: self)
    }
    
    @IBAction func urlButton(_ sender: Any) {
        let url = URL(string: "https://www.gardenia.net/plant-finder")
               
        UIApplication.shared.open(url!)
        
    }
    @IBOutlet weak var weight: UILabel!
    @IBOutlet weak var moisture: UILabel!
    let bluetooth = Shared.instance

    override func viewDidLoad() {
        super.viewDidLoad()
        bluetooth.updateLabel = updateLabel // set bluetooth singleton updateLabel method to this one
        bluetooth.connectionEstablished = connectionEstablished
        // Do any additional setup after loading the view.
        weight.text = classify_weight( w: bluetooth.weight)
        moisture.text = classify_moisture( m: bluetooth.moisture)
        // Do any additional setup after loading the view.
    }
    
    func updateLabel () {
        
    }
    
    func connectionEstablished(){
        
    }
    
    func classify_weight(w : String) -> String{
        let volume = 17.139 //cm**3
        let weight_float = (w as NSString).doubleValue
        let density = weight_float/volume
        var soil_type = ""
        if (density <= 1.28) {
            soil_type = "Soil Type: Clay"
        }
        else if (density > 1.28 && density <= 1.44){
            soil_type = "Soil Type: Silt/Loam"
        }
        else{
            soil_type = "Soil Type: Sand"
        }
        return soil_type
    }
    
    func classify_moisture(m: String) -> String{
        var moisture_type = ""
        let moisture_float = (m as NSString).doubleValue
        if (moisture_float < 50){
            moisture_type = "Soil Moisture: Dry"
        }
        else if (moisture_float >= 50 && moisture_float <= 75){
            moisture_type = "Soil Moisture: Medium"
        }
        else{
            moisture_type = "Soil Moisture: Wet"
        }
        return moisture_type
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
