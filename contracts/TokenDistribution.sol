// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenDistribution is Ownable {
    IERC20 public token; // Le contrat ERC20 représentant les tokens immobiliers
    mapping(address => uint256) public allocations; // Mapping des allocations des investisseurs

    event Allocated(address indexed investor, uint256 amount);

    // Constructeur du contrat
    constructor(address _tokenAddress) {
        token = IERC20(_tokenAddress);
    }

    // Fonction pour allouer des tokens à un investisseur
    function allocateTokens(address investor, uint256 amount) public onlyOwner {
        require(investor != address(0), "Adresse de l'investisseur invalide");
        require(amount > 0, "Le montant doit etre superieur a zero");

        allocations[investor] += amount;
        emit Allocated(investor, amount);
    }

    // Fonction pour distribuer les tokens alloués
    function distributeTokens() public onlyOwner {
        for (uint256 i = 0; i < address(this).balance; i++) {
            address investor = address(uint160(uint256(i))); // Conversion de l'index en adresse
            uint256 allocation = allocations[investor];

            if (allocation > 0) {
                allocations[investor] = 0; // Réinitialiser l'allocation
                token.transfer(investor, allocation); // Transférer les tokens à l'investisseur
            }
        }
    }
}
