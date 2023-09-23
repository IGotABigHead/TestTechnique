// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SecondaryMarket is Ownable {
    IERC20 public token; // Le contrat ERC20 représentant les tokens immobiliers
    uint256 public tokenPrice; // Prix de vente par token
    mapping(address => uint256) public tokensForSale; // Tokens disponibles à la vente

    event TokenListed(address indexed seller, uint256 amount);
    event TokenSold(
        address indexed buyer,
        address indexed seller,
        uint256 amount
    );

    // Constructeur du contrat
    constructor(address _tokenAddress, uint256 _tokenPrice) {
        token = IERC20(_tokenAddress);
        tokenPrice = _tokenPrice;
    }

    // Fonction pour mettre en vente des tokens
    function listTokensForSale(uint256 amount) public {
        require(amount > 0, "Le montant doit etre superieur a zero");
        require(
            token.balanceOf(msg.sender) >= amount,
            "Solde insuffisant pour la vente"
        );

        tokensForSale[msg.sender] += amount;
        emit TokenListed(msg.sender, amount);
    }

    // Fonction pour acheter des tokens en vente
    function buyTokens(address seller, uint256 amount) public {
        require(amount > 0, "Le montant doit etre superieur a zero");
        require(
            tokensForSale[seller] >= amount,
            "Le vendeur n'a pas suffisamment de tokens en vente"
        );
        require(
            token.balanceOf(msg.sender) >= amount * tokenPrice,
            "Solde insuffisant pour l'achat"
        );

        uint256 totalPrice = amount * tokenPrice;

        // Transférer les tokens achetés à l'acheteur
        token.transferFrom(seller, msg.sender, amount);

        // Transférer le paiement au vendeur
        token.transferFrom(msg.sender, seller, totalPrice);

        // Mettre à jour les soldes des tokens en vente
        tokensForSale[seller] -= amount;

        emit TokenSold(msg.sender, seller, amount);
    }
}
