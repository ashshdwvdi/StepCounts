//
//  HomeViewModel.swift
//  StepCounts
//
//  Created by Ashish Dwivedi on 26/03/21.
//

class HomeViewModel: ViewModel {
    private var viewHandler: HomeViewHandling? = nil
    
    func setViewHandler(_ viewHandler: HomeViewHandling?) {
        self.viewHandler = viewHandler
    }
    
    func callLoad() {
        self.viewHandler?.showLoader()
    }
    
    func hideLoad() {
        self.viewHandler?.hideLoader()
    }
}
