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

    struct Etablissement {
        uint256 idEes;
        string nom;
        string typeEtablissement;
        string pays;
        string adresse;
        string siteWeb;
        address idAgent;
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
        string nomEes;
        uint256 idEes;
        string pays;
        string typeDiplome;
        string specialite;
        string mention;
        string date;
    }

    uint nombreEtablissement;
    uint nombreEntreprise;
    uint nombreEtudiant;
    uint nombreDiplome;

    mapping (address => Etablissement) public etablissements;
    mapping (address => Entreprise) public entreprises;
    mapping (uint => Etudiant) public etudiants;
    mapping (uint => Diplome) public diplomes;

    constructor() {
        nombreEtablissement = 0;
        nombreEtudiant = 0;
        nombreEntreprise = 0;
        nombreDiplome = 0;
    }

    function estAgentValideEtablissement (address agent) private returns (bool) {
        return (etablissements[agent] != 0);
    }

    function estAgentValideEntreprise (address agent) private returns (bool) {
        return (entreprises[agent] != 0);
    }

    function creerEtablissement (Etablissement memory infoEtablissement) public {
        Etablissement memory etablissement;
        nombreEtablissement++;

        etablissement.idEes = nombreEtablissement;
        etablissement.nom = infoEtablissement.nom;
        etablissement.typeEtablissement = infoEtablissement.typeEtablissement;
        etablissement.pays = infoEtablissement.pays;
        etablissement.adresse = infoEtablissement.adresse;
        etablissement.siteWeb = infoEtablissement.siteWeb;
        etablissement.idAgent = msg.sender;

        etablissements[msg.sender] = etablissement;
    }

    function creerEntreprise (Entreprise memory infoEntreprise) public {
        Entreprise memory entreprise;
        nombreEntreprise++;

        entreprise.idEntreprise = nombreEntreprise;
        entreprise.nom = infoEntreprise.nom;
        entreprise.secteur = infoEntreprise.secteur;
        entreprise.dateCreation = infoEntreprise.dateCreation;
        entreprise.classificationTaille = infoEntreprise.classificationTaille;
        entreprise.pays = infoEntreprise.pays;
        entreprise.adresse = infoEntreprise.adresse;
        entreprise.courriel = infoEntreprise.courriel;
        entreprise.telephone = infoEntreprise.telephone;
        entreprise.siteWeb = infoEntreprise.siteWeb;

        entreprises[msg.sender] = entreprise;
    }

    function creerEtudiant(Etudiant memory infoEtudiant) public {
        Etudiant memory etudiant;
        nombreEtudiant++;

        etudiant.idEtudiant = nombreEtudiant;
        etudiant.nom = infoEtudiant.nom;
        etudiant.prenom = infoEtudiant.prenom;
        etudiant.dateDeNaissance = infoEtudiant.dateDeNaissance;
        etudiant.sexe = infoEtudiant.sexe;
        etudiant.nationalite = infoEtudiant.nationalite;
        etudiant.statutCivile = infoEtudiant.statutCivile;
        etudiant.adresse = infoEtudiant.adresse;
        etudiant.couriel = infoEtudiant.couriel;
        etudiant.telephone = infoEtudiant.telephone;
        etudiant.section = infoEtudiant.section;
        etudiant.sujetPFE = infoEtudiant.sujetPFE;
        etudiant.entrepriseStagePFE = infoEtudiant.entrepriseStagePFE;
        etudiant.nomPrenomMaitreStage = infoEtudiant.nomPrenomMaitreStage;
        etudiant.dateDebutStage = infoEtudiant.dateDebutStage;
        etudiant.dateFinStage = infoEtudiant.dateFinStage;

        etudiants[nombreEtudiant] = etudiant;
    }

    function creerDiplome(Diplome memory infoDiplome, uint256 idEtudiant) public {
        Diplome memory diplome;
        nombreDiplome++;

        diplome.idDiplome = nombreDiplome;
        diplome.idTitulaire = idEtudiant;
        diplome.nomEes = etablissements[msg.sender].nomEes;
        diplome.idEes = etablissements[msg.sender].idEes;
        diplome.pays = infoDiplome.pays;
        diplome.typeDiplome = infoDiplome.typeDiplome;
        diplome.specialite = infoDiplome.specialite;
        diplome.mention = infoDiplome.mention;
        diplome.date = infoDiplome.date;

        diplomes[nombreDiplome] = diplome;
    }
}