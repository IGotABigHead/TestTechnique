// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RentManagement is Ownable {
    IERC20 public token; // Le contrat ERC20 représentant les tokens immobiliers
    uint256 public rentAmount; // Montant du loyer en tokens
    address[] public propertyOwners; // Liste des propriétaires immobiliers
    mapping(address => bool) public isPropertyOwner; // Vérifier si une adresse est propriétaire
    mapping(address => uint256) public rentCollected; // Montant du loyer collecté par propriétaire
    mapping(address => uint256) public tokenHoldings; // Soldes de tokens des détenteurs

    event RentPaid(address indexed propertyOwner, uint256 amount);
    event RentDistributed(address indexed tokenHolder, uint256 amount);

    // Constructeur du contrat
    constructor(address _tokenAddress, uint256 _rentAmount) {
        token = IERC20(_tokenAddress);
        rentAmount = _rentAmount;
    }

    // Fonction pour permettre aux propriétaires immobiliers de payer le loyer
    function payRent() public {
        require(
            isPropertyOwner[msg.sender],
            "Seuls les proprietaires immobiliers peuvent payer le loyer"
        );

        // Vérifier que le locataire a suffisamment de tokens pour payer le loyer
        require(
            token.balanceOf(msg.sender) >= rentAmount,
            "Solde insuffisant pour payer le loyer"
        );

        // Transférer le loyer du locataire au contrat
        token.transferFrom(msg.sender, address(this), rentAmount);

        // Mettre à jour le montant du loyer collecté par le propriétaire
        rentCollected[msg.sender] += rentAmount;
        emit RentPaid(msg.sender, rentAmount);
    }

    // Fonction pour distribuer les gains aux détenteurs de tokens
    function distributeGains() public {
        uint256 totalRentCollected = address(this).balance;

        // Distribuer les gains aux détenteurs de tokens en fonction de leur solde
        for (uint256 i = 0; i < propertyOwners.length; i++) {
            address propertyOwner = propertyOwners[i];
            uint256 gain = (rentCollected[propertyOwner] *
                tokenHoldings[propertyOwner]) / totalRentCollected;
            tokenHoldings[propertyOwner] += gain;
            emit RentDistributed(propertyOwner, gain);
        }
    }

    // Fonction pour ajouter un propriétaire immobilier
    function addPropertyOwner(address owner) public onlyOwner {
        require(
            !isPropertyOwner[owner],
            "Cette adresse est deja un proprietaire immobilier"
        );
        isPropertyOwner[owner] = true;
        propertyOwners.push(owner);
    }
}
