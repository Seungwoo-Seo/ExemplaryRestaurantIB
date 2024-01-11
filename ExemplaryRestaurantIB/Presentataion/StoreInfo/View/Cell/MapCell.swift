//
//  MapCell.swift
//  ExemplaryRestaurantIB
//
//  Created by 서승우 on 2022/11/10.
//
import UIKit
import SnapKit

class MapCell: UITableViewCell {
    
    // MARK: View
    lazy var mapView: MTMapView = {
        let mapView = MTMapView(frame: .zero)
        mapView.baseMapType = .standard
        mapView.delegate = self
        
        return mapView
    }()
    
    
    // MARK: delegate
    weak var delegate: MapCellDelegate?
    
    
    // MARK: init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI_mapView() {
        self.delegate?.setupUI_mapView(self.mapView)
    }
    
}

// MARK: MTMapViewDelegate
extension MapCell: MTMapViewDelegate {
    
}

private extension MapCell {
    
    func setupLayout() {
        [mapView].forEach { contentView.addSubview($0) }
        
        mapView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    
}
