//
//  DetailVC.swift
//  CoreDataDemo
//
//  Created by Deepak Kumar on 05/08/19.
//  Copyright © 2019 Deepak Kumar. All rights reserved.
//

import UIKit

protocol DetailVcDelegate: class {
    func noteAddedOrEdited(noteDict: [String: Any], isAdd: Bool)
}

final class DetailVC: UIViewController {
    // MARK: - Properties
    @IBOutlet private weak var btnSaveEdit: UIBarButtonItem!
    @IBOutlet private weak var imgView: UIImageView!
    @IBOutlet private weak var txtFldTitle: UITextField!
    @IBOutlet private weak var txtViewDesc: UITextView!
    @IBOutlet private weak var lblDescPlaceholder: UILabel!
    @IBOutlet private weak var lblWarning: UILabel!
    var imgPicker: UIImagePickerController!
    var isAdd = false
    weak var delegate: DetailVcDelegate?
    var note: Note?
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    // MARK: - Private Methods
    private func initialSetup() {
        imgView.isUserInteractionEnabled = isAdd
        if isAdd {
            btnSaveEdit.title = "Save"
        } else {
            txtFldTitle.isEnabled = false
            txtViewDesc.isEditable = false
            btnSaveEdit.title = "Edit"
        }
        setData()
        configureImgPicker()
    }
    
    private func setData() {
        guard let note = note else { return }
        imgView.layer.cornerRadius = imgView.frame.size.height / 2
        imgView.image = note.img
        txtFldTitle.text = note.title
        lblDescPlaceholder.isHidden = description != ""
        txtViewDesc.text = note.desc
    }
    
    private func configureImgPicker() {
        imgPicker = UIImagePickerController()
        imgPicker.allowsEditing = true
        imgPicker.delegate = self
        imgPicker.sourceType = .photoLibrary
    }
    
    // MARK: - IBActions
    @IBAction private func saveEditButtonTapped(_ sender: UIBarButtonItem) {
        if sender.title == "Save" {
            if txtFldTitle.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                view.layoutIfNeeded()
                UIView.animate(withDuration: 0.3) {
                    self.lblWarning.isHidden = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                        self.lblWarning.isHidden = true
                    })
                    self.view.layoutIfNeeded()
                }
            } else {
                btnSaveEdit.title = "Edit"
                imgView.isUserInteractionEnabled = false
                txtFldTitle.isEnabled = false
                txtViewDesc.isEditable = false
                let noteDict: [String: Any] = [NoteKeys.img.rawValue: imgView.image!,
                                               NoteKeys.title.rawValue: txtFldTitle.text!,
                                               NoteKeys.desc.rawValue: txtViewDesc.text!, NoteKeys.time.rawValue: Int(Date().timeIntervalSince1970)
                ]
                delegate?.noteAddedOrEdited(noteDict: noteDict, isAdd: isAdd)
            }
        } else {
            btnSaveEdit.title = "Save"
            imgView.isUserInteractionEnabled = true
            txtFldTitle.isEnabled = true
            txtViewDesc.isEditable = true
        }
    }
    
    @IBAction private func photoTapped(_ sender: UITapGestureRecognizer) {
        present(imgPicker, animated: true, completion: nil)
    }
}

// MARK: - UITextField Delegate
extension DetailVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtViewDesc.becomeFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate
extension DetailVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        lblDescPlaceholder.isHidden = textView.text.count > 0
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        lblDescPlaceholder.isHidden = textView.text.count > 0
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        lblDescPlaceholder.isHidden = textView.text.count > 0
    }
}

// MARK: - ImgPickerController Delegate
extension DetailVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pickedImg = info[.editedImage] as? UIImage else { return }
        imgView.image = pickedImg
        imgView.layer.cornerRadius = imgView.frame.size.height / 2
        dismiss(animated: true, completion: nil)
    }
}
