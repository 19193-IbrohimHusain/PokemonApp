//
//  BaseCellNode.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 06/09/25.
//

import AsyncDisplayKit

class BaseCellNode: ASCellNode {
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        selectionStyle = .none
        configNode()
    }
    
    internal func configNode() {
        
    }
}
