//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Deepak Kumar on 05/08/19.
//  Copyright © 2019 Deepak Kumar. All rights reserved.
//

import UIKit
import CoreData

final class ListVC: UIViewController {
    // MARK: Properties
    @IBOutlet private weak var tblView: UITableView!
    let coreDataManager = CoreDataManager()
    var selectedIndex: Int!
    var arrNote: [Note] = []
    var arrNoteManagedObject: [NSManagedObject] = []
    let cellHeight: CGFloat = 100
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailVC = segue.destination as! DetailVC
        detailVC.delegate = self
        if segue.identifier == "DetailVC" {
            detailVC.isAdd = true
        }
    }
    
    // MARK: - Private methods
    private func initialSetup() {
        getNotesFromDb()
    }
    
    private func getNotesFromDb() {
        coreDataManager.fetch { (arrManagedObject) in
            self.arrNoteManagedObject = arrManagedObject ?? []
            self.arrNoteManagedObject.forEach { (noteManagedObject) in
                let img = UIImage(data: (noteManagedObject.value(forKey: NoteKeys.img.rawValue) as? Data)!)
                let note = Note(dict: [NoteKeys.img.rawValue: img,
                                       NoteKeys.title.rawValue: noteManagedObject.value(forKey: NoteKeys.title.rawValue),
                                       NoteKeys.desc.rawValue: noteManagedObject.value(forKey: NoteKeys.desc.rawValue), NoteKeys.time.rawValue: noteManagedObject.value(forKey: NoteKeys.time.rawValue)
                    ])
                self.arrNote.append(note)
            }
            self.arrNote.reverse()
            self.tblView.reloadData()
        }
    }
    
    private func addToDb(note: Note) {
        let imgData = note.img?.jpegData(compressionQuality: 0.8)
        let dataDict: [String: Any] = [NoteKeys.img.rawValue: imgData!,
                       NoteKeys.title.rawValue: note.title,
                       NoteKeys.desc.rawValue: note.desc, NoteKeys.time.rawValue: note.time
        ]
        coreDataManager.save(entityName: CoreDataKeys.entityName.rawValue, dataDict: dataDict) { (managedObject) in
            self.arrNoteManagedObject.append(managedObject!)
        }
    }
}

// MARK: - TblView Datasource Delegate
extension ListVC: UITableViewDataSource, UITableViewDelegate {
    // Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrNote.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTVC") as! ListTVC
        cell.configure(note: arrNote[indexPath.row])
        return cell
    }
    
    // Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        if let viewC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailVC") as? DetailVC {
            viewC.isAdd = false
            viewC.delegate = self
            viewC.note = arrNote[indexPath.row]
            navigationController?.pushViewController(viewC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            coreDataManager.delete(time: arrNote[indexPath.row].time)
            arrNoteManagedObject.remove(at: indexPath.row)
            arrNote.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}

// MARK: - DetailVC Delegate
extension ListVC: DetailVcDelegate {
    func noteAddedOrEdited(noteDict: [String: Any], isAdd: Bool) {
        let note = Note(dict: noteDict)
        if isAdd {
            arrNote.insert(note, at: 0)
            addToDb(note: note)
        } else {
            arrNote[selectedIndex] = note
            let imgData = note.img?.jpegData(compressionQuality: 0.8)
            var tempNoteDict = noteDict
            tempNoteDict[NoteKeys.img.rawValue] = imgData!
            coreDataManager.update(dictData: tempNoteDict, note: arrNoteManagedObject[selectedIndex])
        }
        tblView.reloadData()
    }
}
