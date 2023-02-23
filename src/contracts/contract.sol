// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `ERC20` functions.
 */
contract DegreeToken is ERC20 {

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () ERC20("DegreeToken", "DTOK") {
        _mint(msg.sender, 1000000 * (10 ** uint256(decimals())));
    }
}

contract DegreeManagement {
    
    struct EES {
        uint256 idEes;
        string nom;
        string typeEtablissement;
        string pays;
        string adresse;
        string siteWeb;
        string idAgent;
    }

    struct Etudiant {
        uint256 idEtudiant;
        string nom;
        string prenom;
        string dateDeNaissance;
        string sexe;
        string nationalite;
        string statutCivile;
        string adresse;
        string couriel;
        string telephone;
        string section;
        string sujetPFE;
        string entrepriseStagePFA;
        string nomPrenomMaitreStage;
        string dateDebutStage;
        string dateFinStage;
        string evaluation;
    }

    struct Entreprise {
        uint256 idEntreprise;
        string nom;
        string secteur;
        string dateCreation;
        string classificationTaille;
        string pays;
        string adresse;
        string courriel;
        string telephone;
        string siteWeb;
    }

    struct Diplome {
        uint256 idDiplome;
        uint256 idTitulaire;
        string nomEES;
        uint256 idEES;
        string pays;
        string typeDiplome;
        string specialite;
        string mention;
        string date;
    }
}