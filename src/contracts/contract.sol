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
        string entrepriseStagePFE;
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
    
    // Relie un agent à une entreprise
    mapping(address => Entreprise) public agentAEntreprise;

    // Tableau contenant tous les Etablissements
    EES[] eesSet;

    // Tableau contenant tous les Etudiants
    Etudiant[] etudiantSet;

    // Mapping avec pour clé l'id d'un Etudiant et pour valeur l'id d'un EES
    mapping(uint => uint) public relationEtudiantEES;

    /*
     * Fonction de création d'un Etablissement d'Enseignmenet Supérieur avec ajout d'un agent
     */
    function creerEES(EES memory infoEes) public {
        EES memory ees;
        ees.idEes = (eesSet.length + 1);
        ees.nom = infoEes.nom;
        ees.typeEtablissement = infoEes.typeEtablissement;
        ees.pays = infoEes.pays;
        ees.adresse = infoEes.adresse;
        ees.siteWeb = infoEes.siteWeb;
        ees.idAgent = msg.sender;

        eesSet.push(ees);
    }

    /**
     * Function qui retourne l'établissement dont l'idAgent est celui passé en paramèter de la fonction.
     * Si l'agent en paramèter n'est associé à aucun établissment, on retourne un EES avec idEes = 0
     */
    function essParAgent(address _idAgent) private view returns(EES memory) {
        bool agentAssocie = false;
        uint i = 0;
        while(!agentAssocie && (i < (eesSet.length))) {
            agentAssocie = (_idAgent == eesSet[i].idAgent);
            i++;
        }

        if (!agentAssocie) {
            EES memory ees;
            ees.idEes = 0;
            return ees;
        } else {
            return eesSet[i];
        }
    }

    // Error lorsqu'un agent qui n'est pas affecté à un EES essaie d'ajouter un Etudiant
    error AgentInvalide(address agentRequested, string message);

    /*
     * Fonction de création de profil étudiant
     */
    function creerProfilEtudiant(Etudiant memory infoEtudiant) public {
        EES memory eesRecrutant = essParAgent(msg.sender);
        if(eesRecrutant.idEes == 0) {
            revert AgentInvalide({
                agentRequested: msg.sender,
                message: "L'agent ayant initie la creation de l'etudiant n'est enregistre dans aucun EES"
            });
        } else {
            Etudiant memory etudiant;
            etudiant.idEtudiant = (etudiantSet.length + 1);
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

            etudiantSet.push(etudiant);
            relationEtudiantEES[etudiant.idEtudiant] = eesRecrutant.idEes;
        }
    }

    /*
     * Fonction de création d'entreprise
     */
    function creerEntreprise(
        string nom, 
        string secteur, 
        string dateCreation, 
        string classificationTaille, 
        string pays, 
        string adresse, 
        string courriel, 
        string telephone, 
        string siteWeb) public {
            
            // TODO : la méthode de Maël avec struct ou quelque chose
            Entreprise memory entreprise = Entreprise(nom, secteur, dateCreation, classificationTaille, pays, adresse, courriel, telephone, siteWeb);

            agentAEntreprise[msg.sender] = entreprise;
    }

    /*
     * Vérifie si un agent de recrutement existe
     */
    function estAgentEntreprise(address agent) returns (bool) {
        return agentAEntreprise[agent] > 0;
    }

    function estEtudiantEntreprise(Etudiant etudiant, address agent) returns (bool) {
        return 
    }

    function evaluerEtudiantPFE(uint256 idEtudiant, string evaluation) {
        if (!estAgentEntreprise(msg.sender)) {
            revert AgentInvalide({
                agentRequested: msg.sender,
                message: "L'agent ayant initie l'evaluation de l'etudiant n'est enregistre pour aucune Entreprise"
            });
        } else if (!estEtudiantEntreprise(etudiantSet.)) {

        }
    }

}