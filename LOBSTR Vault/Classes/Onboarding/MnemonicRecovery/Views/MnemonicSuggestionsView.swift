import UIKit

protocol MnemonicSuggestionsViewDelegate {
  func suggestionWordWasPressed(_ suggestionWord: String)
}

class MnemonicSuggestionsView: UIView {
  @IBOutlet var collectionView: UICollectionView!
  
  var suggestionList: [String] = []
  var delegate: MnemonicSuggestionsViewDelegate?
  
  // MARK: - Lifecycle
  
  override func awakeFromNib() {
    collectionView.delegate = self
    collectionView.dataSource = self
    
    collectionView.register(UINib(nibName: "MnemonicSuggestionsViewCell", bundle: Bundle.main),
                            forCellWithReuseIdentifier: "MnemonicSuggestionsViewCell")
  }
  
  // MARK: - Private
  
  func setData(suggestions: [String]) {
    suggestionList = suggestions
    collectionView.reloadData()
  }
}

// MARK: UICollection

extension MnemonicSuggestionsView: UICollectionViewDelegate, UICollectionViewDataSource,
  UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      numberOfItemsInSection section: Int) -> Int {
    return suggestionList.count
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MnemonicSuggestionsViewCell",
                                                  for: indexPath) as! MnemonicSuggestionsViewCell
    cell.title.text = suggestionList[indexPath.item]        
    cell.layer.cornerRadius = 5
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      didSelectItemAt indexPath: IndexPath) {
    let suggestionWord = suggestionList[indexPath.row]
    collectionView.reloadData()
    
    delegate?.suggestionWordWasPressed(suggestionWord)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout
    collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 10.0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 79, height: 36)
  }
}
