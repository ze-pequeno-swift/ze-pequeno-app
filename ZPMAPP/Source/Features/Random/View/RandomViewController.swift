//
//  RandomViewController.swift
//  ZPMAPP
//
//  Created by Vitor Lentos on 25/08/21.
//

import UIKit

class RandomViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var objectView: UIView!
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var chooseGenreTextField: UITextField!
    
    @IBOutlet weak var chooseNoteTextField: UITextField!
    
    @IBOutlet weak var goButton: UIButton!
    
    @IBOutlet weak var genreButton: UIButton!
    
    @IBOutlet weak var noteButton: UIButton!
    
    private var selectedGenre: Bool = false
    
    private var selectedNote: Bool = false
    
    let randomController = RandomController()
    
    var sortedMovie: Movie?
    
    var genre: String?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    // MARK: - Private Functions
    
    private func setupUI() {
        headerView.roundCorners(cornerRadius: 8.0, typeCorners: [.topLeft, .topRight])
        goButton.roundCorners(cornerRadius: 8.0, typeCorners: [.bottomRight, .bottomLeft, .topRight, .topLeft])
        objectView.roundCorners(cornerRadius: 8.0, typeCorners: [.bottomRight, .bottomLeft, .topRight, .topLeft])
    }

    @IBAction private func sortedMovie(_ sender: UIButton) {
        guard let genre = genre else { return }
        randomController.fetchRandomList(genreSelected: genre) {
            self.proceedToSuggestion()
        }
    }
    
    private func setupActions() {
        chooseGenreTextField.attributedPlaceholder = NSAttributedString(string: "   Escolha um gênero", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        chooseNoteTextField.attributedPlaceholder = NSAttributedString(string: "   Escolha uma nota mínima", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])

        chooseGenreTextField.isUserInteractionEnabled = false
        chooseNoteTextField.isUserInteractionEnabled = false
        
        genreButton.addTarget(self, action: #selector(didSelectedGenreField), for: .touchUpInside)
        noteButton.addTarget(self, action: #selector(didSelectedNoteField), for: .touchUpInside)
        
        randomController.delegate = self
    }
    
    @objc
    private func didSelectedGenreField() {
        selectedGenre = true
        
        let picker = ZPPickerBuilder()
            .set(delegate: self)
            .set(title: "Genêros")
            .set(pickerData: randomController.pickerDataGenre)
            .set(confirmLabel: "Selecionar")
            .set(cancelLabel: "Cancelar")
            .build()

        present(picker, animated: true)
    }
    
    @objc
    private func didSelectedNoteField() {
        selectedNote = true
        
        let picker = ZPPickerBuilder()
            .set(delegate: self)
            .set(title: "Nota mínima - TMDB")
            .set(pickerData: randomController.pickerDataNote)
            .set(confirmLabel: "Selecionar")
            .set(cancelLabel: "Cancelar")
            .build()

        present(picker, animated: true)
    }
    
    private func set(genreField withGenre: String?) {
        chooseGenreTextField.text = withGenre
    }
    
    private func set(noteField withNote: String?) {
        chooseNoteTextField.text = withNote
    }
    
    private func proceedToSuggestion() {
        let identifier = "SuggestionViewController"
        let randomController = UIStoryboard(name: "Random", bundle: nil)
        guard let viewController = randomController.instantiateViewController(identifier: identifier)
                as? SuggestionViewController else { return }
        
        viewController.sortedMovie = sortedMovie
        present(viewController, animated: true)
    }
}

extension RandomViewController: ZPPickerDelegate {
    
    func didSelectPicker(atRow row: Int, withKey key: String) {
        
        if selectedGenre {
            selectedGenre.toggle()
            
            let genre = randomController.pickerDataGenre[row]
            set(genreField: genre)
            self.genre = genre
        }
        
        if selectedNote {
            selectedNote.toggle()
            
            let note = randomController.pickerDataNote[row]
            set(noteField: note)
            randomController.get(note: note)
        }
    }
}

extension RandomViewController: RandomControllerProtocol {
    
    func get(sortedMovie: Movie?) {
        self.sortedMovie = sortedMovie
    }
}
