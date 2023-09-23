const express = require('express');
const { graphqlHTTP } = require('express-graphql');
const { buildSchema } = require('graphql');

let { Web3 } = require('web3');
let provider = new Web3.providers.HttpProvider("http://127.0.0.1:7545");
let web3 = new Web3(provider);


// Définissez votre schéma GraphQL
const schema = buildSchema(`
  type SmartContract {
    id: ID
    name: String
    description: String
  }

  type Query {
    getContract(id: ID): SmartContract
  }

  type Mutation {
    createContract(name: String, description: String): SmartContract
  }
`);


// Importez le contrat intelligent (assurez-vous que le chemin est correct)
const RentManagement = require('./contracts/RentManagement');

// Initialisez une instance Web3 (assurez-vous de le configurer correctement)


// Créez une instance du contrat intelligent en utilisant l'adresse du contrat
const rentContract = new web3.eth.Contract(
  RentManagement.abi,
  ''
);


// Simulez la création de contrats intelligents (remplacez par votre logique réelle)
const contracts = [];

// Implémentez la résolution de la requête GraphQL
const root = {
  getContract: ({ id }) => {
    return contracts.find(contract => contract.id === id);
  },
  createContract: ({ name, description }) => {
    const newContract = {
      id: contracts.length + 1,
      name,
      description,
    };
    contracts.push(newContract);
    return newContract;
  },
};

// Initialisez l'application Express
const app = express();


app.post('/api/create-contract', (req, res) => {
  try {
    const contractData = req.body; // Les données du contrat à créer
    const newContract = createSmartContract(contractData);

    res.status(201).json({ message: 'Contrat intelligent créé avec succès', contract: newContract });
  } catch (error) {
    res.status(500).json({ error: 'Erreur lors de la création du contrat intelligent' });
  }
});

app.post('/api/buy-tokens', (req, res) => {
  try {

    const purchaseData = req.body; // Les données d'achat de tokens
    // Exemple de traitement de l'achat :
    // const result = buyTokens(purchaseData);
    res.status(200).json({ message: 'Achat de tokens réussi', result });
  } catch (error) {
    res.status(500).json({ error: 'Erreur lors de lachat de tokens' });
  }
});


app.post('/api/pay-rent', async (req, res) => {
  try {
    const { privateKey, amount } = req.body; // Données de paiement reçues depuis le client
    const senderAddress = ''; // Adresse du propriétaire immobilier

    // Signer la transaction avec la clé privée du propriétaire
    const gas = await web3.eth.estimateGas({
      from: senderAddress,
      to: '',
      value: '0x0',
      data: rentContract.methods.payRent().encodeABI(),
    });

    const tx = {
      from: senderAddress,
      to: '',
      gas,
      data: rentContract.methods.payRent().encodeABI(),
    };

    const signedTx = await web3.eth.accounts.signTransaction(tx, privateKey);
    const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);

    if (receipt.status) {
      res.status(200).json({ message: 'Loyer payé avec succès' });
    } else {
      res.status(500).json({ error: 'Erreur lors du paiement du loyer' });
    }
  } catch (error) {
    res.status(500).json({ error: 'Erreur lors du paiement du loyer' });
  }
});

app.post('/api/list-token-for-sale', (req, res) => {
  try {

    const listingData = req.body; // Les données de mise en vente
    const result = listTokensForSale(listingData);

    res.status(201).json({ message: 'Tokens mis en vente avec succès', result });
  } catch (error) {
    res.status(500).json({ error: 'Erreur lors de la mise en vente des tokens' });
  }
});


app.post('/api/buy-token', (req, res) => {
  try {

    const purchaseData = req.body; // Les données d'achat de tokens
    const result = buyTokensOnSecondaryMarket(purchaseData);

    res.status(200).json({ message: 'Achat de tokens sur le marché secondaire réussi', result });
  } catch (error) {
    res.status(500).json({ error: 'Erreur lors de lachat de tokens sur le marché secondaire' });
  }
});



// Ajoutez un point de terminaison GraphQL
app.use('/graphql', graphqlHTTP({
  schema: schema,
  rootValue: root,
  graphiql: true, // Activez l'interface graphique pour tester les requêtes GraphQL
}));


// Lancez le serveur Express
const port = 3000;
app.listen(port, () => {
  console.log(`Serveur GraphQL écoutant sur le port ${port}`);
});
