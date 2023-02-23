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
        uint256 entrepriseStagePFE; // Correspond à l'id de l'entreprise dans le struct Entreprise
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

    /**
     * Retourne true si l'agent en paramètre est enregistré dans un établissement, sinon false
     */
    function estAgentValideEtablissement (address agent) private returns (bool) {
        Etablissement memory etablissement = etablissements[agent];
        // On vérifie que l'idAgent est différent de 0 car si la clé (agent) n'existe pas dans le mapping,
        // etablissement sera créé avec tous ses attributs avec des valeurs par défaut (ici 0).
        // Comme un idAgent est toujours supérieur à 0, on peutl 'utiliser comme valeur témoin.
        return (etablissement.idEes != 0);
    }

    /**
     * Retourne true si l'agent en paramètre est enregistré dans une enterprise, sinon false
     */
    function estAgentValideEntreprise (address agent) private returns (bool) {
        Entreprise memory entreprise = entreprises[agent];
        return (entreprise.idEntreprise != 0);
    }

    /**
     * Retourne true si les données sur l'étudiant en paramètre attestent qu'il a fait son stage de fin d'études 
     * dans l'entreprise représentée par l'agent en paramètre, sinon false
     */
    function etudiantStageEntreprise(uint256 idEtudiant, address agent) private returns (bool) {
        Etudiant memory etudiant = etudiants[idEtudiant];
        Entreprise memory entreprise = entreprises[agent];
        return (etudiant.entrepriseStagePFE == entreprise.idEntreprise);
    }

    // Erreur levée lorsqu'un agent non autorisé effectue une action
    error AgentInvalide(address agentRequested, string message);

    // Erreur levée lorsqu'une entreprise tente d'évaluer un étudiant n'ayant pas fait son stage de fin d'étude en son sein
    error EtudiantEntrepriseIncorrecte(uint256 etudiantRequested,address agentRequested, string message);

    /**
     * Créé un établissement
     */
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

    /**
     * Créé une entreprise
     */
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

    /**
     * Créé et sauvegarde un profil pour un étudiant
     */
    function creerEtudiant(Etudiant memory infoEtudiant) public {
        if (estAgentValideEtablissement(msg.sender)) {
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
        } else {
            revert AgentInvalide({
                agentRequested: msg.sender,
                message: "L'agent ayant initie la creation de l'etudiant n'est enregistre dans aucun Etablissemnt d'Enseignement Superieur"
            });
        }
    }

    /*
     * Créé et assigne un diplôme
     */
    function creerDiplome(Diplome memory infoDiplome, uint256 idEtudiant) public {
        if (estAgentValideEtablissement(msg.sender)) {
            Diplome memory diplome;
            nombreDiplome++;

            diplome.idDiplome = nombreDiplome;
            diplome.idTitulaire = idEtudiant;
            diplome.nomEes = etablissements[msg.sender].nom;
            diplome.idEes = etablissements[msg.sender].idEes;
            diplome.pays = infoDiplome.pays;
            diplome.typeDiplome = infoDiplome.typeDiplome;
            diplome.specialite = infoDiplome.specialite;
            diplome.mention = infoDiplome.mention;
            diplome.date = infoDiplome.date;

            diplomes[nombreDiplome] = diplome;
        } else {
            revert AgentInvalide({
                agentRequested: msg.sender,
                message: "L'agent ayant initie la creation du diplome n'est enregistre dans aucun Etablissemnt d'Enseignement Superieur"
            });
        }
    }

    /**
     * Evalue un étudiant et rémunère l'évaluateur
     */
    function evaluerEtudiant(uint256 idEtudiant, string memory evalution) public {
        if (estAgentValideEntreprise(msg.sender)) {
            if (etudiantStageEntreprise(idEtudiant, msg.sender)) {
                etudiants[idEtudiant].evaluation = evalution;
                //Rémunération en tokens
            } else {
                revert EtudiantEntrepriseIncorrecte({
                    etudiantRequested: idEtudiant,
                    agentRequested: msg.sender,
                    message: "L'etudiant evalue par l'agent ayant initie son evaluatio n'a pas fait son stage de fin d'etude dans l'entreprise concernee"
            });
            }
        } else {
            revert AgentInvalide({
                agentRequested: msg.sender,
                message: "L'agent ayant initie l'evaluation de l'etudiant n'est enregistre dans aucune Entreprise"
            });
        }
    }

    /**
     * Permet à la boite d'acquérir des tokens
     */
    function acquerirToken(uint amount) public {
        //Utiliser les fonctions de l'ERC20 avec les balances ?
    }

    /**
     * Vérifie l’authenticité d’un diplôme et paie les frais en tokens.
     */
    function verifierDiplome() public {
         
    }

}