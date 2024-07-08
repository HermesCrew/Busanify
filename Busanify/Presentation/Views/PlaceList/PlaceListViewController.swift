//
//  PlaceListViewController.swift
//  Busanify
//
//  Created by seokyung on 7/1/24.
//

/*
 다음주까지 끝내기!
 북마크 기능 넣기 / 로그인했을 때 보이는거랑 안 했을 때 안 보이게 하는 거 처리가 좀 어렵지만 일단 ㄱㄱ
 별점 표시
 주소 영업시간 numberofline 설정할지
 셀 크기 유동적으로/고정으로.. 등등 고민
 포스트맨
 이디야라고 검색했을 때 내 가장 가까운 곳에는 이디야 꽃집, 사용자가 찾는 건 카페 이럴 때 검색결과 뭘 보여줄 지 고민
 관광공사-> 쇼핑 숙박 나머지는 부산광역시 제공
 쇼핑, 숙박 이미지 확인
 9월 전에 개발 완
 */

import UIKit
import Combine

class PlaceListViewController: UIViewController {
    private let viewModel: PlaceListViewModel
    private var cancellables = Set<AnyCancellable>()
    private let tableView = UITableView()
    
    init(viewModel: PlaceListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        bindViewModel()
        fetchPlaces()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        tableView.register(PlaceTableViewCell.self, forCellReuseIdentifier: "PlaceCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 140
        //tableView.estimatedRowHeight = 120
    }
    
    private func bindViewModel() {
        viewModel.$placeCellViewModels
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func fetchPlaces() {
        viewModel.fetchPlaces(typeId: .touristAttraction, lang: "eng", lat: 35.07885, lng: 129.04402, radius: 3000)
    }
}

extension PlaceListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.placeCellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as? PlaceTableViewCell else {
            return UITableViewCell()
        }
        
        let cellViewModel = viewModel.placeCellViewModels[indexPath.row]
        cell.configure(with: cellViewModel)
        
        return cell
    }
}
