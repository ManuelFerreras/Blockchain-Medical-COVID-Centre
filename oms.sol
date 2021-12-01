pragma solidity >= 0.8.0;

// SPDX-License-Identifier: UNLICENSED

contract OMSCovid {

    // -------------------------------------------- Declaration -------------------------------------------- //


    // Contract Owner
    address public owner;

    // Constructor
    constructor() {

        // Set Owner
        owner = msg.sender;

    }

    // Medical Centres. medicalCentre address => gestureSystem.
    mapping (address => bool) medicalCentreValidation;

    // MedicalCentre Address to its Contract
    mapping (address => address) public medicalCentresContracts;

    // Array of verificated medicalCentres.
    address[] medicalCentresAddresses;

    // Array of requests
    address[] requests;

    // Events
    event newValidatedCentre(address);
    event newContract(address, address);
    event accessRequest(address);

    // OnlyOwner Modifier
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner.");
        _;
    }

    // Check it is a validated centre
    modifier onlyValidatedCentre() {
        require(medicalCentreValidation[msg.sender] == true, "Not a validated medical centre.");
        _;
    }


    // -------------------------------------------- Logic -------------------------------------------- //

    // Validate new medical centre.
    function validateMedicalCentre(address _centre) public onlyOwner {

        // Set state to medicalCentre
        medicalCentreValidation[_centre] = true;

        // Trigger Event.
        emit newValidatedCentre(_centre);

    }

    // Factory
    function medicalCentreFactory() public onlyValidatedCentre {

        // Create Smart Contract
        address _medicalCentreAddress = address(new MedicalCentre(msg.sender));

        // Adds the address to existing contracts.
        medicalCentresAddresses.push(_medicalCentreAddress);

        // Store contract address to medical centre.
        medicalCentresContracts[msg.sender] = _medicalCentreAddress;

        // Trigger Event.
        emit newContract(_medicalCentreAddress, msg.sender);

    }

    function requestAccess() public {

        // Add request to array
        requests.push(msg.sender);

        // Trigger event
        emit accessRequest(msg.sender);

    }

    function getAccessRequests() public view onlyOwner returns(address[] memory) {

        return(requests);

    }



}



contract MedicalCentre {

    // -------------------------------------------- Declarations -------------------------------------------- //

    // Contract Owner
    address public owner;
    address public contractAddress;

    // Constructor
    constructor (address _owner) {

        // Sets owner
        owner = _owner;

        // Set contract Address
        contractAddress = address(this);

    }

    // client hash => (result, ipfs)
    mapping (bytes32 => results) covidResults;

    struct results {
        bool result;
        string ipfsCode;
    }

    // Events
    event newResult(string, bool);

    // Only Medical Centre
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // emit new result
    function emitNewResult(string memory _clientId, bool _testResult, string memory _ipfsCode) public onlyOwner {

        // Client Id Hash
        bytes32 _clientHash = keccak256(abi.encodePacked(_clientId));

        // hash => result
        covidResults[_clientHash] = results(_testResult, _ipfsCode);

        // Trigger Event
        emit newResult(_ipfsCode, _testResult);

    }

    // Get results
    function getResult(string memory _clientId) public view returns (string memory, string memory) {

        // Client hash
        bytes32 _clientHash = keccak256(abi.encodePacked(_clientId));

        // Return boolean as a string
        string memory _resultTest;

        // Check state and assing value based on its value.
        _resultTest = covidResults[_clientHash].result ? "Positive" : "Negative";

        return (_resultTest, covidResults[_clientHash].ipfsCode);

    }

}