// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract dPharma {
    struct Prescription {
        string description;
        string medications;
        address patientId;
        address pharmacyId;
        address doctorId;
    }

    // Array to store all prescriptions
    Prescription[] public prescriptions;

    mapping(address => uint256) public withdrawnFunds;

    // Mapping to store roles for each address
    mapping(address => string) public roles;

    // Modifier to ensure only doctors can add prescriptions
    modifier onlyDoctor() {
        require(
            keccak256(bytes(roles[msg.sender])) == keccak256(bytes("doctor")),
            "Only doctors can add prescriptions"
        );
        _;
    }

    // Modifier to ensure only patient can get the donation
    modifier onlyPatient(){
        require(
            keccak256(bytes(roles[msg.sender])) == keccak256(bytes("patient")), "Only patient can have the donation");
        _;
    }

    // Function to set roles for users
    function setRole(string memory role) public {
        roles[msg.sender] = role;
    }
    
    // Function to get the role of a user
    function getRole(address user) public view returns (string memory) {
        return roles[user];
    }

    uint256 public minimumMoney = 10 * 1e18;
    uint256 public totalDonation = 0;
    event DonationReceived(address indexed donor, uint256 amount, uint256 timestamp);

    function donateMe() public payable {
        require(getConvertedPrice(msg.value) >= minimumMoney, "the amount of etherium should be more than 10Usd");

        totalDonation = totalDonation + msg.value;
        emit DonationReceived(msg.sender, msg.value, block.timestamp);
    }

    function getPrice() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc7cb1);
        (, int256 price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Price feed unavailable");
        return uint256(price * 1e10);  // 1
    }

    function getConvertedPrice(uint256 ethAmount) public view returns(uint256){
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUSD = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUSD;
    }

    mapping(address => bool) public receivedDonation;

    function hasPatientReceviedDonation() public view returns(bool){
        return receivedDonation[msg.sender];
    }

    function withdrawDonation() public onlyPatient{
        require(!receivedDonation[msg.sender], "Patient has already received a donation");
        require(isPatientListed[msg.sender], "Patient is not listed in the prescription");
        uint256 receivingAmount = (totalDonation * 7) / 100;

        receivedDonation[msg.sender] = true;
        payable(msg.sender).transfer(receivingAmount);
    }

    mapping(address => bool) public isPatientListed;

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Function to add a new prescription (restricted to doctors)
    function addPrescription(
        string memory _description,
        string memory _medications,
        address _patientId,
        address _pharmacyId
    ) public onlyDoctor {
        // Include the doctor's address (msg.sender) in the prescription
        prescriptions.push(Prescription({
            description: _description,
            medications: _medications,
            patientId: _patientId,
            pharmacyId: _pharmacyId,
            doctorId: msg.sender
        }));

        isPatientListed[_patientId] = true;
    }

    
    function getDoctorPrescription() public view returns (Prescription[] memory) {
    uint256 count = 0;

    // First loop: Count matching prescriptions
    for (uint256 i = 0; i < prescriptions.length; i++) {
        if (prescriptions[i].doctorId == msg.sender) {
            count++;
        }
    }

    // Create memory array with the exact size
    Prescription[] memory doctorPrescriptions = new Prescription[](count);
    uint256 index = 0;

    // Second loop: Populate the memory array
    for (uint256 i = 0; i < prescriptions.length; i++) {
        if (prescriptions[i].doctorId == msg.sender) {
            doctorPrescriptions[index] = prescriptions[i];
            index++;
        }
    }

    return doctorPrescriptions; // Return the array
    }

function getPharmacyPrescription() public view returns (Prescription[] memory) {
    uint256 count = 0;

    // First loop: Count matching prescriptions
    for (uint256 i = 0; i < prescriptions.length; i++) {
        if (prescriptions[i].pharmacyId == msg.sender) {
            count++;
        }
    }

    // Create memory array with the exact size
    Prescription[] memory pharmacyPrescriptions = new Prescription[](count);
    uint256 index = 0;

    // Second loop: Populate the memory array
    for (uint256 i = 0; i < prescriptions.length; i++) {
        if (prescriptions[i].pharmacyId == msg.sender) {
            pharmacyPrescriptions[index] = prescriptions[i];
            index++;
        }
    }

    return pharmacyPrescriptions; // Return the array
    }


    function getPatientPrescription() public view returns(Prescription[] memory){
        uint count = 0;
        for(uint i = 0; i < prescriptions.length; i++){
            if(prescriptions[i].patientId == msg.sender){
                count++;
            }
        }

        Prescription[] memory patientPrescription = new Prescription[](count);
        uint256 index = 0;
        for(uint i = 0; i < prescriptions.length; i++){
            if(prescriptions[i].patientId == msg.sender){
                patientPrescription[index] = prescriptions[i];
                index++;
            }
        }
        return patientPrescription;
    }

}


