//
//  LessonOverviewViewController.swift
//  FirstFive
//
//  Created by Adam Kinney on 11/27/15.
//  Changed by David S Reich - 2016.
//  Changed by John Cook - 2017.
//  Copyright © 2015 Musikyoshi. All rights reserved.
//
import UIKit
import Foundation
import SwiftyJSON

class LessonOverviewViewController: UIViewController,UITableViewDataSource, UITableViewDelegate{
    
    var selectedTuneId: String?
    var selectedTuneName: String?
    var selectedRhythmId: String?
    var selectedRhythmName: String?
    var lessonsJson: JSON?
    
    

    let noteIds = [55,57,58,60,62,63,65,67,69,70,72]
    var actionNotes = [Note]()
    var selectedNote : Note?
    

    
    override func viewDidLoad() {
        if actionNotes.count == 0 {
            for nId in noteIds {
                actionNotes.append(NoteService.getNote(nId)!)
            }
        } else {
            print("did load test")
        }
    
     }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Lesson 1" // + profile.currentLessonNumber
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.landscapeRight)
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
    }
    
    let tuneSegueIdentifier = "ShowTuneSegue"
    let longToneSegueIdentifier = "ShowLongToneSegue"
    let rhythmSegueIdentifier = "ShowRhythmSegue"
    let informationBoardIdentifier = "InformationBoardSegue"
    
    // MARK: - Navigation
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard identifier != longToneSegueIdentifier else { return false }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.title = ""
        
        if segue.identifier == tuneSegueIdentifier {
            if let destination = segue.destination as? TuneExerciseViewController {
                destination.exerciseName = selectedTuneId!
                destination.isTune = true
            }
        } else if segue.identifier == rhythmSegueIdentifier {
            if let destination = segue.destination as? TuneExerciseViewController {
                destination.exerciseName = selectedRhythmId!
                destination.isTune = false
            }
        }
        else if segue.identifier == longToneSegueIdentifier {
            if let destination = segue.destination as? LongToneViewController {
                if let sn = selectedNote
                {
                    //TO DO -- is -2 correct??
                    //                    let an = NoteService.getNote(sn.orderId-2)
                    let an = NoteService.getNote(sn.orderId)
                    print("sn: \(sn.orderId) - 2?? ==>")
                    print("an == \(String(describing: an?.orderId))")
                    destination.targetNote = an
                    destination.targetNoteID = sn.orderId
                    destination.noteName = (selectedNote?.fullName)!
                }
                else
                {
                    destination.targetNote = NoteService.getNote(destination.kC4)
                    destination.targetNoteID = destination.kC4
                }
                
            }
        }
    }
    

    public func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let count = lessonsJson?.count {
            
            return count
        }
        return 0
        
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LessonItemCell", for: indexPath)
        
        // Configure the cell...
        if let lessons = lessonsJson{
            
            cell.textLabel?.text = lessons[indexPath.row]["title"].string
        }
        
        
        return cell
        
  
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //Here we are going to seguae to the exercise that the user selected whcih could by content-type - rythm, long tone, tune, or information board.
        
        
        if let lesssonType = LessonItemType(rawValue: (lessonsJson?[indexPath.row]["type"].string?.lowercased())!){
            
            switch lesssonType {
            case .longTone:
                performSegue(withIdentifier: longToneSegueIdentifier, sender: self)
            case .rythm:
                if let musicFile = lessonsJson?[indexPath.row]["resource"].string!
                {
                    selectedRhythmId = String(musicFile.characters.dropLast(4))
                }
                performSegue(withIdentifier: rhythmSegueIdentifier, sender: self)
            case .tune:
                if let musicFile = lessonsJson?[indexPath.row]["resource"].string!
                {
                    selectedTuneId = String(musicFile.characters.dropLast(4))
                }
                performSegue(withIdentifier: tuneSegueIdentifier, sender: self)
            case .informnationNode:
                performSegue(withIdentifier: informationBoardIdentifier, sender: self)
              
            }

        }
        
        
        
    }
    
    
}
