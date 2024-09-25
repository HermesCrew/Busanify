//
//  ImagePreviewViewController.swift
//  Busanify
//
//  Created by 장예진 on 9/25/24.
//

import UIKit

class ImagePreviewViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    private var imageUrls: [String]
    
    init(imageUrls: [String]) {
        self.imageUrls = imageUrls
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupScrollView()
        setupPageControl()
        setupCloseButton()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loadImages()
    }
    
    private func setupScrollView() {
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupPageControl() {
        pageControl.numberOfPages = imageUrls.count
        pageControl.currentPage = 0
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = .gray
        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func loadImages() {
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        for (index, urlString) in imageUrls.enumerated() {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            imageView.translatesAutoresizingMaskIntoConstraints = true

            if let url = URL(string: urlString) {
                imageView.kf.setImage(with: url)
            }

            // (이미지 여러 개일때) 이미지 뷰의 프레임을 스크롤뷰 크기와 맞춤
            imageView.frame = CGRect(
                x: scrollView.frame.size.width * CGFloat(index),
                y: 0,
                width: scrollView.frame.size.width,
                height: scrollView.frame.size.height
            )
            scrollView.addSubview(imageView)
        }

        // 스크롤 뷰의 콘텐츠 크기를 설정
        scrollView.contentSize = CGSize(
            width: scrollView.frame.size.width * CGFloat(imageUrls.count),
            height: scrollView.frame.size.height
        )
    }
    
    // exit(닫기)
    private func setupCloseButton() {
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("닫기", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    @objc private func didTapCloseButton() {
        dismiss(animated: true, completion: nil)
    }
}

extension ImagePreviewViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.frame.size.width)
        pageControl.currentPage = Int(pageIndex)
    }
}
