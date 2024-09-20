//
//  PostViewController.swift
//  Busanify
//
//  Created by 이인호 on 9/19/24.
//

import UIKit
import PhotosUI

class AddPostViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private let postViewModel: PostViewModel
    private let authViewModel = AuthenticationViewModel.shared
    
    private var selections = [String : PHPickerResult]()
    private var selectedAssetIdentifiers = [String]()
    private var selectedImages: [UIImage] = []

    weak var delegate: AddPostViewControllerDelegate?
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "photo.badge.plus"), for: .normal)
        button.tintColor = .gray
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.cornerRadius = 10
        
        button.addAction(UIAction { [weak self] _ in
            self?.showPHPicker()
        }, for: .touchUpInside)
        
        return button
    }()
    
    private let photoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()
    
    private let contentTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 10
        textView.text = "Write content"
        textView.textColor = .systemGray3
        
        return textView
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Post", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        
        button.addAction(UIAction { [weak self] _ in
            self?.addPost()
        }, for: .touchUpInside)
        
        return button
    }()
    
    init(postViewModel: PostViewModel) {
        self.postViewModel = postViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        contentTextView.delegate = self
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "PhotoCollectionViewCell")
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(addButton)
        view.addSubview(photoCollectionView)
        view.addSubview(contentTextView)
        view.addSubview(saveButton)
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        photoCollectionView.translatesAutoresizingMaskIntoConstraints = false
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addButton.widthAnchor.constraint(equalToConstant: 50),
            addButton.heightAnchor.constraint(equalToConstant: 50),
            addButton.centerYAnchor.constraint(equalTo: photoCollectionView.centerYAnchor),
            
            photoCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            photoCollectionView.leadingAnchor.constraint(equalTo: addButton.trailingAnchor, constant: 16),
            photoCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            photoCollectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.20),
            
            contentTextView.topAnchor.constraint(equalTo: photoCollectionView.bottomAnchor, constant: 16),
            contentTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contentTextView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -16),
            
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        
        cell.configure(with: selectedImages, index: indexPath.item)
        cell.deleteButton.tag = indexPath.item
//        cell.deleteButton.addTarget(self, action: #selector(self.deleteButtonTapped(_:)), for: .touchUpInside)
        cell.currentIndex = indexPath.item
//        cell.imageUrls = snap.imageUrls
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width * 0.95
        var width = availableWidth / 3
        let screenHeight = UIScreen.main.bounds.height
        // 화면 높이에 따라 셀의 높이 조정
        let height: CGFloat
        if screenHeight <= 667 { // iPhone SE, 8, 7, 6s, 6 (4.7" 디스플레이)
            width *= 0.8
            height = width
        } else {
            height = width // 큰 화면에서는 정사각형 유지
        }
        return CGSize(width: width, height: height)
    }
    
//    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
//        <#code#>
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: any UICollectionViewDropCoordinator) {
//        <#code#>
//    }
    
    private func addPost() {
        Task {
            do {
                try await postViewModel.createPost(token: authViewModel.getToken(), content: contentTextView.text, photos: selectedImages)
            
                DispatchQueue.main.async {
                    self.delegate?.didCreatePost()
                    self.navigationController?.popViewController(animated: true)
                }
            } catch {
                print("Failed to create post: \(error)")
            }
        }
    }
}

extension AddPostViewController: PHPickerViewControllerDelegate {
    // MARK: - PHPickerViewControllerDelegate
    func showPHPicker() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 0
        config.selection = .ordered
        config.preferredAssetRepresentationMode = .current
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        
        present(picker, animated: true, completion: nil)
    }
    
    private func displayImage() {
        
        let dispatchGroup = DispatchGroup()
        // identifier와 이미지로 dictionary를 만듬 (selectedAssetIdentifiers의 순서에 따라 이미지를 받을 예정입니다.)
        var imagesDict = [String: UIImage]()
        
        for (identifier, result) in selections {
            
            dispatchGroup.enter()
            
            let itemProvider = result.itemProvider
            // 만약 itemProvider에서 UIImage로 로드가 가능하다면?
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                // 로드 핸들러를 통해 UIImage를 처리해 줍시다. (비동기적으로 동작)
                itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    
                    guard let image = image as? UIImage else { return }
                    
                    imagesDict[identifier] = image
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) { [weak self] in
            
            guard let self = self else { return }
            
            // 선택한 이미지의 순서대로 정렬하여 스택뷰에 올리기
            for identifier in self.selectedAssetIdentifiers {
                guard let image = imagesDict[identifier] else { return }
                self.selectedImages.append(image)
            }
            
            self.photoCollectionView.reloadData()
        }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        var newSelections = [String: PHPickerResult]()
        
        for result in results {
            let identifier = result.assetIdentifier!
            newSelections[identifier] = selections[identifier] ?? result
        }
        selections = newSelections
        selectedAssetIdentifiers = results.compactMap { $0.assetIdentifier }
        
        displayImage()
    }
}

extension AddPostViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard contentTextView.textColor == .systemGray3 else { return }
        contentTextView.text = nil
        contentTextView.textColor = .black
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if contentTextView.text.isEmpty {
            contentTextView.text = "Write content"
            contentTextView.textColor = .systemGray3
        }
    }
}

protocol AddPostViewControllerDelegate: NSObject {
    func didCreatePost()
}
