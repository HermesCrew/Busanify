//
//  ReviewViewController.swift
//  Busanify
//
//  Created by MadCow on 2024/9/25.
//

import UIKit
import PhotosUI
import Kingfisher

class ReviewViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    private let reviewViewModel: ReviewViewModel
    private let authViewModel = AuthenticationViewModel.shared
    
    private var currentRating: Double {
        get {
            return self.rateStackView.getStarCounts()
        }
    }
    private var selections = [String : PHPickerResult]()
    private var selectedAssetIdentifiers = [String]()
    private var selectedImages: [UIImage] = []
    private var imageItems: [ImageData] = []
    
    weak var delegate: AddReviewViewControllerDelegate?
    
    var selectedPlace: Place
    var selectedReview: Review?
    
    private lazy var rateStackView: RatingStackView = {
        let stackView = RatingStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
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
    
    private lazy var contentTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 10
        textView.text = self.selectedReview == nil ? NSLocalizedString("writeContent", comment: "") : self.selectedReview?.content
        textView.textColor = self.selectedReview == nil ? .systemGray3 : .label
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        
        return textView
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("save", comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        
        button.addAction(UIAction { [weak self] _ in
            if self?.selectedReview == nil {
                self?.addReview()
            } else {
                self?.editReview()
            }
        }, for: .touchUpInside)
        
        return button
    }()
    
    // 로딩 뷰
    private let loadingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.isHidden = true
        return view
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        return indicator
    }()
    
    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "Uploading"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    init(reviewViewModel: ReviewViewModel, selectedPlace: Place) {
        self.reviewViewModel = reviewViewModel
        self.selectedPlace = selectedPlace
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setupTapGesture()
        
        contentTextView.delegate = self
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.dragDelegate = self
        photoCollectionView.dropDelegate = self
        photoCollectionView.dragInteractionEnabled = true
        photoCollectionView.reorderingCadence = .immediate
        
        photoCollectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "PhotoCollectionViewCell")
        
        if let editReview = selectedReview {
            self.rateStackView.setStarCount(editReview.rating)
            self.contentTextView.text = editReview.content
            self.imageItems = editReview.photoUrls.map { ImageData.url($0) }
            self.photoCollectionView.reloadData()
            updateSaveButtonState()
        }
    }
    
    private func configureUI() {
        // 내비게이션 leftitem 추가
        self.title = selectedPlace.title
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(cancelButtonTapped))
        
        view.backgroundColor = .systemBackground
        view.addSubview(rateStackView)
        view.addSubview(addButton)
        view.addSubview(photoCollectionView)
        view.addSubview(contentTextView)
        view.addSubview(saveButton)
        view.addSubview(loadingView)
        loadingView.addSubview(activityIndicator)
        loadingView.addSubview(loadingLabel)
        
        updateSaveButtonState()
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        photoCollectionView.translatesAutoresizingMaskIntoConstraints = false
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            rateStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            rateStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addButton.widthAnchor.constraint(equalToConstant: 50),
            addButton.heightAnchor.constraint(equalToConstant: 50),
            addButton.centerYAnchor.constraint(equalTo: photoCollectionView.centerYAnchor),
            
            photoCollectionView.topAnchor.constraint(equalTo: rateStackView.bottomAnchor, constant: 20),
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
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor, constant: -20),
            
            loadingLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 10),
            loadingLabel.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor)
        ])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if selectedReview == nil {
            return self.selectedImages.count
        } else {
            return self.imageItems.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        
        if selectedReview == nil {
            cell.configure(with: self.selectedImages[indexPath.item])
        } else {
            let imageData = imageItems[indexPath.item]
            switch imageData {
            case .url(let imageUrl):
                cell.configure(with: imageUrl)
            case .image(let image):
                cell.configure(with: image)
            }
        }
        cell.deleteButton.tag = indexPath.item
        cell.deleteButton.addTarget(self, action: #selector(self.deleteButtonTapped(_:)), for: .touchUpInside)
        
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
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        if selectedReview == nil {
            let item = selectedImages[indexPath.item]
            let itemProvider = NSItemProvider(object: item)
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = item
            return [dragItem]
        } else {
            let item = imageItems[indexPath.item]
            let itemProvider: NSItemProvider
            
            switch item {
            case .url(let urlString):
                // URL String을 NSItemProvider에 제공
                itemProvider = NSItemProvider(object: urlString as NSString)
            case .image(let image):
                // UIImage를 NSItemProvider에 제공
                itemProvider = NSItemProvider(object: image)
            }
            
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = item // 드래그하는 객체 자체를 보관
            
            return [dragItem]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }
        
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                collectionView.performBatchUpdates({
                    // 데이터 소스 업데이트
                    if selectedReview == nil {
                        let movedImage = selectedImages.remove(at: sourceIndexPath.item)
                        selectedImages.insert(movedImage, at: destinationIndexPath.item)
                    } else {
                        let movedImage = imageItems.remove(at: sourceIndexPath.item)
                        imageItems.insert(movedImage, at: destinationIndexPath.item)
                    }
                    
                    // 컬렉션 뷰에서 셀 이동
                    collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
                }, completion: { _ in
                    self.updateCellTags()
                })
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.localDragSession != nil
    }
    
    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let parameters = UIDragPreviewParameters()
        
        // 꾹 누르고 이미지 이동 시 둥글게 유지되도록
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
            parameters.visiblePath = UIBezierPath(roundedRect: cell.imageView.bounds, cornerRadius: 10)
        }
        
        return parameters
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    @objc private func deleteButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        if selectedReview == nil {
            self.selectedImages.remove(at: index)
        } else {
            self.imageItems.remove(at: index)
        }
        
        DispatchQueue.main.async {
            self.photoCollectionView.performBatchUpdates({
                self.photoCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)]) // 컬렉션뷰에서 인덱스로 삭제
            }) { _ in
                // 삭제 후 나머지 셀들이 있다면 태그 업데이트
                self.photoCollectionView.reloadData()
            }
        }
    }
    
    private func updateCellTags() {
        let totalItems = photoCollectionView.numberOfItems(inSection: 0)  // 섹션이 하나이므로 0번째 섹션 사용
        for item in 0..<totalItems {
            let indexPath = IndexPath(item: item, section: 0)
            if let cell = photoCollectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
                cell.deleteButton.tag = item
            }
        }
    }
    
    private func addReview() {
        showLoading()
        Task {
            do {
                try await reviewViewModel.createReview(token: authViewModel.getToken(), content: contentTextView.text, placeId: self.selectedPlace.id, rating: currentRating, photos: selectedImages)
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.hideLoading()
                    self.delegate?.didCreateReview()
                    self.dismiss(animated: true)
                    self.delegate?.showToastMessage("Post uploaded successfully")
                }
            } catch {
                print("Failed to create post: \(error)")
                DispatchQueue.main.async { [weak self] in
                    self?.hideLoading()
                    self?.showErrorAlert(message: "Failed to create post. Please try again.")
                }
            }
        }
    }
    
    private func editReview() {
        showLoading()
        Task {
            do {
                try await reviewViewModel.editReview(token: authViewModel.getToken(), content: contentTextView.text, reviewId: self.selectedReview!.id, rating: currentRating, photos: imageItems)
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.hideLoading()
                    self.delegate?.didCreateReview()
                    self.dismiss(animated: true)
                    self.delegate?.showToastMessage("Post uploaded successfully")
                }
            } catch {
                print("Failed to create post: \(error)")
                DispatchQueue.main.async { [weak self] in
                    self?.hideLoading()
                    self?.showErrorAlert(message: "Failed to create post. Please try again.")
                }
            }
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: NSLocalizedString("error", comment: ""), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // 입력된 내용이 있으면 Alert 띄우기
    @objc private func cancelButtonTapped() {
        if !selectedImages.isEmpty || !contentTextView.text.isEmpty && contentTextView.textColor != .systemGray3 {
            let alert = UIAlertController(title: NSLocalizedString("discardUnsavedChanges", comment: ""), message: NSLocalizedString("discardUnsavedChangesMessageForAdd", comment: ""), preferredStyle: .alert)
            
            let discardAction = UIAlertAction(title: NSLocalizedString("discard", comment: ""), style: .destructive) { _ in
                self.navigationController?.popViewController(animated: true)
            }
            let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
            
            alert.addAction(discardAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 로딩 뷰 띄우기
    private func showLoading() {
        navigationItem.leftBarButtonItem?.isEnabled = false
        loadingView.isHidden = false
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    private func hideLoading() {
        loadingView.isHidden = true
        activityIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
    }
}

extension ReviewViewController: PHPickerViewControllerDelegate {
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
                if selectedReview == nil {
                    self.selectedImages.append(image)
                } else {
                    self.imageItems.append(ImageData.image(image))
                }
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

extension ReviewViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard contentTextView.textColor == .systemGray3 else { return }
        contentTextView.text = nil
        contentTextView.textColor = .label
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if contentTextView.text.isEmpty {
            contentTextView.text = "Write Review"
            contentTextView.textColor = .systemGray3
        }
        updateSaveButtonState()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateSaveButtonState()
    }
    
    private func updateSaveButtonState() {
        let isPlaceholder = contentTextView.textColor == .systemGray3
        let textIsEmpty = contentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        saveButton.isEnabled = !(isPlaceholder || textIsEmpty)
        saveButton.alpha = saveButton.isEnabled ? 1.0 : 0.5
    }
}

protocol AddReviewViewControllerDelegate: NSObject {
    func didCreateReview()
    func showToastMessage(_ message: String)
}
