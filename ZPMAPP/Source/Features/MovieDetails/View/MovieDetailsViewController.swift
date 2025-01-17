//
//  MovieDetailsViewController.swift
//  ZPMAPP
//
//  Created by Hellen on 24/08/21.
//

import UIKit

protocol MovieDetailsViewControllerProtocol: AnyObject {

    func showMovieListError(_ errorMessage: String)
}

class MovieDetailsViewController: UIViewController {
    
    // MARK: - IBOutlets

    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Private Properties
    
    var controllerMovieDetails = ControllerMovieDetails()

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        navigationItem.backButtonTitle = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showLoginIfNeeded()
        showLoading()
        controllerMovieDetails.fetchMovieDetails()
        hideLoading()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        controllerMovieDetails.viewController = self
        
        DetailsCell.registerOn(tableView)
        SaveWatchLaterCell.registerOn(tableView)
        DescriptionCell.registerOn(tableView)
        WhereToWatchCell.registerOn(tableView)
        MoviesNearbyCell.registerOn(tableView)
        CustomCastCell.registerOn(tableView)
        RecommendationTableViewCell.registerOn(tableView)
        EmptyViewCell.registerOn(tableView)
        EmptySectionCell.registerOn(tableView)
    }
    
    private func getDetailsCell() -> UITableViewCell {
        let identifier = DetailsCell.identifier
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
                as? DetailsCell else { return UITableViewCell() }
        
        let movie = controllerMovieDetails.getMovie()
        let details = controllerMovieDetails.getDetails()

        cell.setupCell(movie, details: details ?? Details())
        
        return cell

    }
    
    private func getSaveWatchLaterCell() -> UITableViewCell {
        let identifier = SaveWatchLaterCell.identifier
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
                as? SaveWatchLaterCell else { return UITableViewCell() }
        cell.setupDelegate(delegate: self)
        
        return cell
    }
    
    private func getDescriptionCell() -> UITableViewCell {
        let identifier = DescriptionCell.identifier
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
                as? DescriptionCell else { return UITableViewCell() }
        
        
        let movie = controllerMovieDetails.getMovie()
        cell.setupCell(movie)
        
        return cell
    }
    
    private func getWhereToWatchCell() -> UITableViewCell {
        let identifier = WhereToWatchCell.identifier
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
                as? WhereToWatchCell else { return UITableViewCell() }
        
        return cell
    }
    
    private func getMoviesNearbyCell() -> UITableViewCell {
        let identifier = MoviesNearbyCell.identifier
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
                as? MoviesNearbyCell else { return UITableViewCell() }
        
        return cell
    }
    
    private func getCustomCastCell() -> UITableViewCell {
        let identifier = CustomCastCell.identifier
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
                as? CustomCastCell else { return UITableViewCell() }
        
        let details = controllerMovieDetails.getDetails()
        cell.setupCell(details)

        return cell
    }

    private func getRecommendations() -> UITableViewCell {
        let identifier = RecommendationTableViewCell.identifier

        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
                as? RecommendationTableViewCell else { return UITableViewCell() }
        
        let detail = controllerMovieDetails.getDetails()

        cell.setupCell(detail)
        return cell
    }

    private func getEmptyView() -> UITableViewCell {
        let identifier = EmptyViewCell.identifier

        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
                as? EmptyViewCell else { return UITableViewCell() }
        cell.setupCell(title: "Opss", message: "Não encontramos a descrição e os detalhes do filme")

        return cell
    }

    private func getEmpySectionView(title: String, message: String) -> UITableViewCell {
        let identifier = EmptySectionCell.identifier

        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
                as? EmptySectionCell else { return UITableViewCell()}

        cell.setupCell(title: title, message: message)
        return cell
    }


    private func checkEmptyStateToBuildDetailsCell() -> UITableViewCell {
        if controllerMovieDetails.checkOverviewEmptyState() == true {
            return getEmptyView()
        } else {
            return getDescriptionCell()
        }
    }

    private func checkEmptyStateToBuildCastCell() -> UITableViewCell {
        if controllerMovieDetails.checkCastEmptyState() == true {
            return getEmpySectionView(title: "Algo deu errado", message: "Não encontramos o elenco do filme")
        }
        return getCustomCastCell()
    }

    private func checkEmptyStateToBuildRecommendationsCell() -> UITableViewCell {
        if controllerMovieDetails.checkRecommendationsEmptyState() == true {
            return getEmpySectionView(title: "Não deu match :(", message: "Não encontramos nenhum filme recomendado")
        }
        return getRecommendations()
    }
    
    private func alert(title: String, message: String) {
        let alert: UIAlertController = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showLoginIfNeeded() {
        if self.controllerMovieDetails.userIsLogged() {
            return
        }
        proceedToLogin()
    }
    
    private func proceedToLogin() {
        let identifier = String(describing: LoginViewController.self)
        let loginController = UIStoryboard(name: "Login", bundle: nil)
        guard let viewController = loginController.instantiateViewController(identifier: identifier)
                as? LoginViewController else { return }
        
        let navigationController = UINavigationController(rootViewController: viewController)
        
        present(navigationController, animated: true)
    }
    
    private func proceedToProfile() {
        let identifier = String(describing: ProfileViewController.self)
        let profileController = UIStoryboard(name: "Profile", bundle: nil)
        
        guard let viewController = profileController.instantiateViewController(identifier: identifier) as? ProfileViewController else { return }
        
        
        self.hidesBottomBarWhenPushed = false
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - UITableView Protocol Extensions

extension MovieDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    enum DetailsSection: Int, CaseIterable {
        case details
        case saveWatchLater
        case description
        case moviesNearby
        case customCast
        case recommendations
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return DetailsSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = DetailsSection(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch section {
        case .details:
            return getDetailsCell()
        case .saveWatchLater:
            return getSaveWatchLaterCell()
        case .description:
            return checkEmptyStateToBuildDetailsCell()
        case .moviesNearby:
            return getMoviesNearbyCell()
        case .customCast:
            return checkEmptyStateToBuildCastCell()
        case .recommendations:
            return checkEmptyStateToBuildRecommendationsCell()
        }
    }
}

// MARK: - HomeViewControllerDelegate Extensions

extension MovieDetailsViewController: MovieDetailsViewControllerProtocol {

    func showMovieListError(_ errorMessage: String) {
        self.alert(title: "Ixe, Deu ruim!", message: "Houve um erro ao apresentar a lista de filmes")
    }
}

extension MovieDetailsViewController: SaveWatchLaterProtocol {

    func saveMovieDB(tag: Tag) {
        self.controllerMovieDetails.saveMovieDB(tag: tag)
        self.alert(title: "Minha lista", message: "O filme foi adicionado com sucesso na sua lista de filmes")
    }
}

extension MovieDetailsViewController: NavViewCellProtocol {
    
    func goBack() {
        self.proceedToProfile()
    }
}
