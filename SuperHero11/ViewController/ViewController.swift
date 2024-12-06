import UIKit
import Alamofire
import Kingfisher

class ViewController: UIViewController {
    @IBOutlet private weak var heroImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var statsContentView: UIView!
    @IBOutlet private weak var bioContentView: UIView!
    
    private var statsLabels: [UILabel] = []
    private var bioLabels: [UILabel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        heroImageView.layer.cornerRadius = 75
        heroImageView.clipsToBounds = true
        heroImageView.contentMode = .scaleAspectFill
        heroImageView.backgroundColor = .systemGray5
        
        nameLabel.text = "Roll to get a hero!"
        
        setupStatsLabels()
        setupBioLabels()
    }
    
    private func setupStatsLabels() {
        let statNames = ["Intelligence", "Strength", "Speed", "Durability", "Power", "Combat"]
        statsLabels = statNames.map { name in
            let label = UILabel()
            label.font = .systemFont(ofSize: 14)
            label.text = "\(name): -"
            return label
        }
        
        let stackView = UIStackView(arrangedSubviews: statsLabels)
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        statsContentView.addSubview(stackView)
    }
    
    private func setupBioLabels() {
        let bioFields = ["Full Name", "Alter Egos", "Publisher", "First Appearance", "Place of Birth", "Alignment"]
        bioLabels = bioFields.map { field in
            let label = UILabel()
            label.font = .systemFont(ofSize: 14)
            label.text = "\(field): -"
            label.numberOfLines = 0
            return label
        }
        
        let stackView = UIStackView(arrangedSubviews: bioLabels)
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        bioContentView.addSubview(stackView)
    }
    
    @IBAction func heroRollDidTap(_ sender: UIButton) {
        let randomId = Int.random(in: 1...563)
        fetchHero(by: randomId)
    }
    
    private func fetchHero(by id: Int) {
        let urlString = "https://akabab.github.io/superhero-api/api/id/\(id).json"
        
        AF.request(urlString).responseData { [weak self] response in
            switch response.result {
            case .success(let data):
                self?.handleHeroData(data: data)
            case .failure(let error):
                print("Error fetching hero: \(error.localizedDescription)")
            }
        }
    }
    
    private func handleHeroData(data: Data) {
        do {
            let hero = try JSONDecoder().decode(Hero.self, from: data)
            
            DispatchQueue.main.async {
                self.updateUI(with: hero)
            }
            
            if let imageUrl = URL(string: hero.images.md) {
                DispatchQueue.main.async {
                    self.heroImageView.kf.setImage(with: imageUrl, placeholder: UIImage(named: "placeholder"))
                }
            }
            
        } catch {
            DispatchQueue.main.async {
                self.showError(message: error.localizedDescription)
            }
        }
    }
    
    private func updateUI(with hero: Hero) {
        nameLabel.text = hero.name
        
        let stats = [
            hero.powerstats.intelligence,
            hero.powerstats.strength,
            hero.powerstats.speed,
            hero.powerstats.durability,
            hero.powerstats.power,
            hero.powerstats.combat
        ]
        
        for (label, stat) in zip(statsLabels, stats) {
            let statName = label.text?.components(separatedBy: ":").first ?? ""
            label.text = "\(statName): \(stat)"
        }
        
        let bioInfo = [
            hero.biography.fullName,
            hero.biography.alterEgos,
            hero.biography.publisher,
            hero.biography.firstAppearance,
            hero.biography.placeOfBirth,
            hero.biography.alignment
        ]
        
        for (label, info) in zip(bioLabels, bioInfo) {
            let fieldName = label.text?.components(separatedBy: ":").first ?? ""
            label.text = "\(fieldName): \(info)"
        }
    }
    
    private func showError(message: String) {
        nameLabel.text = "Error: \(message)\nTry rolling again!"
        heroImageView.image = nil
        statsLabels.forEach { $0.text = $0.text?.components(separatedBy: ":").first.map { "\($0): -" } }
        bioLabels.forEach { $0.text = $0.text?.components(separatedBy: ":").first.map { "\($0): -" } }
    }
}
