// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RealEstateToken is ERC20 {
    address public owner;

    // Constructeur du contrat
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply,
        address _owner
    ) ERC20(_name, _symbol) {
        owner = _owner;
        _mint(_owner, _initialSupply);
    }

    // Fonction pour transférer des tokens
    function transferTokens(address _to, uint256 _amount) public {
        require(
            msg.sender == owner,
            "Seul le proprietaire peut effectuer cette operation."
        );
        _transfer(msg.sender, _to, _amount);
    }
}
