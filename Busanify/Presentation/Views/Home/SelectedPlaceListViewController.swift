//
//  SelectedPlaceListViewController.swift
//  Busanify
//
//  Created by MadCow on 2024/7/20.
//

import UIKit
import Combine

class SelectedPlaceListViewController: UIViewController {
    
    private var cancellable = Set<AnyCancellable>()
    var placeViewModel = SelectedPlaceListViewModel()
    var locationDelegate: MoveToMapLocation?
    
    private lazy var placeListTableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.register(SelectedPlaceListTableViewCell.self, forCellReuseIdentifier: "SelectedPlaceListTableViewCell")
        
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setSubscriber()
        setTableView()
    }
    
    func setSubscriber() {
        self.placeViewModel.fetchPlaces()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] searchedPlaces in
                guard let self = self else { return }
                self.placeListTableView.reloadData()
            }
            .store(in: &cancellable)
    }
    
    func setTableView() {
        self.view.addSubview(placeListTableView)
        
        NSLayoutConstraint.activate([
            placeListTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            placeListTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            placeListTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            placeListTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}

extension SelectedPlaceListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.placeViewModel.getPlaces().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SelectedPlaceListTableViewCell", for: indexPath) as? SelectedPlaceListTableViewCell else {
            return UITableViewCell()
        }
        
        if self.placeViewModel.getPlaces().count > 0 {
            let place = self.placeViewModel.getPlaces()[indexPath.row]
            Task {
                await cell.configureUI(place: place)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlace = self.placeViewModel.getPlaces()[indexPath.row]
        locationDelegate?.moveTo(lat: selectedPlace.lat, lng: selectedPlace.lng)
    }
}
