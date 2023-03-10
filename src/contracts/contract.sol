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

    address private deployer;

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () ERC20("DegreeToken", "DTOK") {
        _mint(msg.sender, 1000000 * (10 ** uint256(decimals())));
        deployer = msg.sender;
    }

    function deployerAddress () public view returns (address) {
        return deployer;
    }

    function DTOKTransfer(address from, address to, uint value) public {
        _transfer(from, to, value);
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

    DegreeToken dt;

    uint public constant FRAIS_DE_VERIFICATION_DE_DIPLOME = 10;
    uint public constant REMUNERATION_EVALUATION_ETUDIANT = 15;

    uint nombreEtablissement;
    uint nombreEntreprise;
    uint nombreEtudiant;
    uint nombreDiplome;

    mapping (address => Etablissement) public etablissements;
    mapping (address => Entreprise) public entreprises;
    mapping (uint256 => Etudiant) public etudiants;
    mapping (uint256 => Diplome) public diplomes;
    mapping (uint256 => uint256) public etudiantEtablissement; // Mapping qui permet de retrouver l'id de l'établissement d'un étudiant

    constructor() {
        nombreEtablissement = 0;
        nombreEtudiant = 0;
        nombreEntreprise = 0;
        nombreDiplome = 0;
    }

    /**
     * Retourne true si l'agent en paramètre est enregistré dans un établissement, sinon false
     */
    function estAgentValideEtablissement (address agent) private view returns (bool) {
        Etablissement memory etablissement = etablissements[agent];
        // On vérifie que l'idAgent est différent de 0 car si la clé (agent) n'existe pas dans le mapping,
        // etablissement sera créé avec tous ses attributs avec des valeurs par défaut (ici 0).
        // Comme un idAgent est toujours supérieur à 0, on peutl 'utiliser comme valeur témoin.
        return (etablissement.idEes != 0);
    }

    /**
     * Retourne true si l'agent en paramètre est enregistré dans une enterprise, sinon false
     */
    function estAgentValideEntreprise (address agent) private view returns (bool) {
        Entreprise memory entreprise = entreprises[agent];
        return (entreprise.idEntreprise != 0);
    }

    /**
     * Retourne true si les données sur l'étudiant en paramètre attestent qu'il a fait son stage de fin d'études 
     * dans l'entreprise représentée par l'agent en paramètre, sinon false
     */
    function etudiantStageEntreprise(uint256 idEtudiant, address agent) private view returns (bool) {
        Etudiant memory etudiant = etudiants[idEtudiant];
        Entreprise memory entreprise = entreprises[agent];
        return (etudiant.entrepriseStagePFE == entreprise.idEntreprise);
    }

    /**
     * Retourne true si l'étudiant en paramètre est enregistré dans un établissement, sinon false
     */
    function estEtudiantValide (uint256 idEtudiant) private view returns (bool) {
        Etudiant memory etudiant = etudiants[idEtudiant];
        return (etudiant.idEtudiant != 0);
    }
    
    /**
     * Retourne true si l'étudiant en paramètre est lié à l'établissement en paramètre, sinon false
     */
    function estEtudiantValideDansEtablissement (uint256 idEtudiant, uint256 idEes) private view returns (bool) {
        return (etudiantEtablissement[idEtudiant] == idEes);
    }

    /**
     * Retourne true si les deux strings sont identiques, sinon false
     */
    function compareString(string memory str1, string memory str2) public pure returns (bool) {
        return keccak256(abi.encodePacked(str1)) == keccak256(abi.encodePacked(str2));
    }

    // Erreur levée lorsqu'un agent non autorisé effectue une action
    error AgentInvalide(address agentRequested, string message);

    // Erreur levée lorsqu'une entreprise tente d'évaluer un étudiant n'ayant pas fait son stage de fin d'étude en son sein
    error EtudiantEntrepriseIncorrecte(uint256 etudiantRequested,address agentRequested, string message);

    // Erreur levée lorsqu'un diplome est détecté comme invalide  
    error DiplomeInvalide(uint256 diplomeRequested, uint256 idChecked, string message);

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
            etudiantEtablissement[nombreEtudiant] = etablissements[msg.sender].idEes;
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
                require(compareString(etudiants[idEtudiant].evaluation, ""), "L'etudiant a deja ete evalue");
                etudiants[idEtudiant].evaluation = evalution;
                dt.DTOKTransfer(dt.deployerAddress(), msg.sender, REMUNERATION_EVALUATION_ETUDIANT * (10 ** uint256(dt.decimals())));
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
     * Permet à l'entreprise d'acquérir des tokens
     */
    function acquerirToken() public payable {
        //Utiliser les fonctions de l'ERC20 avec les balances ?
        uint tknToBuy = msg.value * 100; //Rapport de 100 (1 ether = 100 degreeTkn)
        require (dt.balanceOf(dt.deployerAddress()) - tknToBuy >= 0, "Transaction annulee, pas assez de token en banque");
        dt.DTOKTransfer(dt.deployerAddress(), msg.sender, tknToBuy);
    }

    /**
     * Vérifie l’authenticité d’un diplôme et paie les frais en tokens.
     */
    function verifierDiplome(uint256 idDiplome) public {
        if (estAgentValideEntreprise(msg.sender)) {
            
            dt.DTOKTransfer(dt.deployerAddress(), msg.sender, FRAIS_DE_VERIFICATION_DE_DIPLOME * (10 ** uint256(dt.decimals())));
            
            Diplome memory diplome = diplomes[idDiplome];

            if(!estEtudiantValide(diplome.idTitulaire)) {
                revert DiplomeInvalide({
                    diplomeRequested: idDiplome,
                    idChecked: diplome.idTitulaire,
                    message: "L'etudiant titulaire du diplome n'est enregistre dans aucun etablissements, le diplome n'est donc pas valide"
                });
            }
            
            if(!estEtudiantValideDansEtablissement(diplome.idTitulaire, diplome.idEes)) {
                revert DiplomeInvalide({
                    diplomeRequested: idDiplome,
                    idChecked: diplome.idEes,
                    message: "L'etudiant titulaire du diplome n'est pas enregistre dans l'etablissement ayant delivre le diplome, le diplome n'est donc pas valide"
                });
            }
          
        } else {
            revert AgentInvalide({
                agentRequested: msg.sender,
                message: "L'agent ayant initie la verification du diplome n'est enregistre dans aucune Entreprise"
            });
        }
    }
}