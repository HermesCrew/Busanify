//
//  UpdatePostViewController.swift
//  Busanify
//
//  Created by 이인호 on 9/23/24.
//

import UIKit
import PhotosUI

class UpdatePostViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    private let postViewModel: PostViewModel
    private let authViewModel = AuthenticationViewModel.shared
    private var post: Post
    
    private var selections = [String : PHPickerResult]()
    private var selectedAssetIdentifiers = [String]()
    private var imageItems: [ImageData] = []
    private var initialContent: String = ""
    private var initialImageItems: [ImageData] = []
    
    weak var delegate: AddPostViewControllerDelegate?
    weak var updateDelegate: UpdatePostViewControllerDelegate?
    
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
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 10
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        
        return textView
    }()
    
    private lazy var updateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("save", comment: ""), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        
        button.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.updatePost()
        }, for: .touchUpInside)
        
        return button
    }()
    
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
    
    init(postViewModel: PostViewModel, post: Post) {
        self.postViewModel = postViewModel
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configure()
        setupTapGesture()
        
        contentTextView.delegate = self
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.dragDelegate = self
        photoCollectionView.dropDelegate = self
        photoCollectionView.dragInteractionEnabled = true
        photoCollectionView.reorderingCadence = .immediate
        
        photoCollectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "PhotoCollectionViewCell")
        
        initialContent = post.content
        initialImageItems = post.photoUrls.map { ImageData.url($0) }
    }
    
    private func configureUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(cancelButtonTapped))
        title = NSLocalizedString("editPost", comment: "")
        view.backgroundColor = .systemBackground
        view.addSubview(addButton)
        view.addSubview(photoCollectionView)
        view.addSubview(contentTextView)
        view.addSubview(updateButton)
        view.addSubview(loadingView)
        loadingView.addSubview(activityIndicator)
        loadingView.addSubview(loadingLabel)
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        photoCollectionView.translatesAutoresizingMaskIntoConstraints = false
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        updateButton.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addButton.widthAnchor.constraint(equalToConstant: 80),
            addButton.heightAnchor.constraint(equalToConstant: 80),
            addButton.centerYAnchor.constraint(equalTo: photoCollectionView.centerYAnchor),
            
            photoCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            photoCollectionView.leadingAnchor.constraint(equalTo: addButton.trailingAnchor, constant: 16),
            photoCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            photoCollectionView.heightAnchor.constraint(equalToConstant: 120),
            
            contentTextView.topAnchor.constraint(equalTo: photoCollectionView.bottomAnchor, constant: 10),
            contentTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contentTextView.bottomAnchor.constraint(equalTo: updateButton.topAnchor, constant: -16),
            
            updateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            updateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            updateButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            updateButton.heightAnchor.constraint(equalToConstant: 50),
            
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
    
    @objc private func cancelButtonTapped() {
        let contentChanged = contentTextView.text != initialContent
        let imagesChanged = imageItems != initialImageItems
        
        if contentChanged || imagesChanged {
            let alert = UIAlertController(title: NSLocalizedString("discardUnsavedChanges", comment: ""), message: NSLocalizedString("discardUnsavedChangesMessageForEdit", comment: ""), preferredStyle: .alert)
            
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
    
    func configure() {
        //        self.existingImageUrls = post.photoUrls
        self.contentTextView.text = post.content
        self.imageItems = post.photoUrls.map { ImageData.url($0) }
        self.photoCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        
        let imageData = imageItems[indexPath.item]
        
        switch imageData {
        case .url(let imageUrl):
            cell.configure(with: imageUrl)
        case .image(let image):
            cell.configure(with: image)
        }
        //        if indexPath.item < existingImageUrls.count {
        //            let imageUrl = existingImageUrls[indexPath.item]
        //            cell.configure(with: imageUrl)
        //        } else {
        //            let image = selectedImages[indexPath.item - existingImageUrls.count]
        //            cell.configure(with: image)
        //        }
        cell.deleteButton.tag = indexPath.item
        cell.deleteButton.addTarget(self, action: #selector(self.deleteButtonTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }
        
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                collectionView.performBatchUpdates({
                    // 데이터 소스 업데이트
                    let movedItem = imageItems.remove(at: sourceIndexPath.item)
                    imageItems.insert(movedItem, at: destinationIndexPath.item)
                    
                    // 컬렉션 뷰에서 셀 이동
                    collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
                }, completion: { _ in
                    self.updateCellTags()
                })
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
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
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
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
    
    @objc private func deleteButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        
        imageItems.remove(at: index)
        
        DispatchQueue.main.async {
            self.photoCollectionView.performBatchUpdates({
                self.photoCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)]) // 컬렉션뷰에서 인덱스로 삭제
            }) { _ in
                self.photoCollectionView.reloadData()
            }
        }
    }
    
    private func updatePost() {
        showLoading()
        Task {
            do {
                let imgStrs = try await postViewModel.updatePost(token: authViewModel.getToken(), id: post.id, content: contentTextView.text, photos: imageItems)
                
                print("imgStrs count >> \(imgStrs.count)")
                self.post.content = contentTextView.text
                self.post.photoUrls = imgStrs
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.hideLoading()
                    self.delegate?.didCreatePost()
                    self.updateDelegate?.didUpdatePost(post: post)
                    self.navigationController?.popViewController(animated: true)
                    self.delegate?.showToastMessage("Post edited successfully")
                    self.updateDelegate?.showToastMessage(messaage: "Post Updated")
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
}

extension UpdatePostViewController: PHPickerViewControllerDelegate {
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
                self.imageItems.append(ImageData.image(image))
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

extension UpdatePostViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let textIsEmpty = contentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        updateButton.isEnabled = !textIsEmpty
        updateButton.alpha = updateButton.isEnabled ? 1.0 : 0.5
    }
}

protocol UpdatePostViewControllerDelegate: NSObject {
    func didUpdatePost(post: Post)
    func showToastMessage(messaage: String)
}

extension ImageData: Equatable {
    static func == (lhs: ImageData, rhs: ImageData) -> Bool {
        switch (lhs, rhs) {
        case (.url(let lhsUrl), .url(let rhsUrl)):
            return lhsUrl == rhsUrl
        case (.image(let lhsImage), .image(let rhsImage)):
            return lhsImage.pngData() == rhsImage.pngData()
        default:
            return false
        }
    }
}
