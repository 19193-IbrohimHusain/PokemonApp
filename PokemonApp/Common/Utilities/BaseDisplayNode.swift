//
//  BaseDisplayNode.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 06/09/25.
//

import AsyncDisplayKit

class BaseDisplayNode: ASDisplayNode {
    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        configNode()
    }
    
    internal func configNode() {
        
    }
}
