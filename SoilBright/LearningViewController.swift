//
//  LearningViewController.swift
//  SoilBright
//
//  Created by Dan Brickner on 7/1/20.
//  Copyright © 2020 Dan Brickner. All rights reserved.
//

import UIKit

class LearningViewController: UIViewController {

    // variables
    var firstLoad = true
    var currentLesson = 0
    var subLesson = 0
    var jsonObject = FullLesson(numbers: [FullLesson.LessonPlan(lessonName: "null", lessons: ["null"])])
    
    struct FullLesson: Decodable {
        struct LessonPlan: Decodable {
            let lessonName: String
            let lessons: [String]
        }
        let numbers:[LessonPlan]
    }
    
    @IBOutlet weak var lessonName: UILabel!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var lesson: UIImageView!
    
    // selection control
    @IBAction func valueChanged(_ sender: Any) {
        // determine selection
        currentLesson = segment.selectedSegmentIndex
        // load lesson
        subLesson = 0
        loadLesson()
    }
    
    // lesson control
    @IBAction func lessonBack(_ sender: Any) {
        if (subLesson == 0){
            subLesson = jsonObject.numbers[currentLesson].lessons.count - 1
        }
        else{
            subLesson -= 1
        }
        loadLesson()
    }
    
    @IBAction func lessonNext(_ sender: Any) {
        if (subLesson == jsonObject.numbers[currentLesson].lessons.count - 1){
            subLesson = 0
        }
        else{
            subLesson += 1
        }
        loadLesson()
    }
    @IBAction func forumButton(_ sender: Any) {
        let url = URL(string: "http://www.soilbright.freeforums.net")
               
        UIApplication.shared.open(url!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (firstLoad){
            jsonObject = readLocalFile(forName: "lessons")!
            //for number in jsonObject.numbers{
             //   print(number.lessons)
            //}
            loadLesson()
            firstLoad = false
        }
    }
    
    func loadLesson(){
        var newText = (jsonObject.numbers[currentLesson].lessonName)
        lessonName.text = newText
        newText = (jsonObject.numbers[currentLesson].lessons[subLesson]) + ".png"
        let image = UIImage(named: newText)
        lesson.image = image
        //lesson.text = newText
    }
    
    private func readLocalFile(forName name: String) -> FullLesson? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name,
                                                 ofType: "json"),
                let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                print(jsonData)
                let decodedData = try JSONDecoder().decode(FullLesson.self,
                from: jsonData)
                return decodedData
            }
        } catch {
            print(error)
        }
        
        return nil
    }
}
