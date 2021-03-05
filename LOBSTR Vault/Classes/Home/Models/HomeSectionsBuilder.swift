import Foundation

protocol HomeSectionsBuilder {
  func buildSections() -> [HomeSection]
}

struct HomeSectionsBuilderImpl: HomeSectionsBuilder {
  func buildSections() -> [HomeSection] {
    let transactionsToSign = HomeSection(type: .transactionsToSign,
                                         rows: [.numberOfTransactions("-")])
    let vaultPublicKey = HomeSection(type: .vaultPublicKey,
                                     rows: [.publicKey("-")])
    let signersTotalNumber = HomeSection(type: .signersTotalNumber,
                                         rows: [.totalNumber(0)])
    let signers = HomeSection(type: .listOfSigners,
                              rows: [])    
    let bottom = HomeSection(type: .bottom, rows: [.bottom])
    
    return [transactionsToSign,
            vaultPublicKey,
            signersTotalNumber,
            signers,            
            bottom]
  }
}
