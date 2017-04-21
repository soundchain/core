pragma solidity ^0.4.9;

import "./SoundToken.sol";
import "./ERC23Interface.sol";

contract MasterContract {
    
    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }
    
    // License structure required to allow multiple tracks be associated with one token.
    struct License {
        address assignedToken;
        bytes32 licenseSig;
        mapping (bytes32 => uint256) trackPrice;
    }
    
    // Shows if token is registered by this MasterContract or its side token contract.
    mapping (address => bool) public trackToken;
    
    // Mapping needed to find license by its signature.
    mapping (bytes32 => License) licenses;
    
    // Mapping is needed to find wich license is assigned to a given track.
    mapping (bytes32 => bytes32) trackLicense;
    
    // Owner of contract.
    address public owner;
    
    // SOCH-Token contract address.
    address public SOCHContract;
    
    //TODO
    function MasterContract() {
        owner = msg.sender;
    }
    
    // Function is called when one of tracks is listened to calculate and pay PayPerPlay rewards in SOCH 
    // to SoundToken contract assigned to this track by license.
    // @param _trackSig listened track signature
    // @param _times number of times track was listened
    function trackListened(bytes32 _trackSig, uint256 _times) onlyOwner {
        if(trackToken[licenses[trackLicense[_trackSig]].assignedToken]) {
            ERC23 asset = ERC23(SOCHContract);
            if(!asset.transfer(licenses[trackLicense[_trackSig]].assignedToken, _times * licenses[trackLicense[_trackSig]].trackPrice[_trackSig])) {
                throw;
            }
        }
    }
    
    // Creates a new SoundToken contract and returns its address.
    // default token contract creation params
    function createTrackToken(uint256 _initialSupply, string _name, string _symbol, int _decimals) onlyOwner returns (address newToken) {
        newToken = new SoundTokens(_initialSupply, _name, _symbol, _decimals);
        trackToken[newToken]=true;
    }
    
    // Register a track by its signature to a given license with specified PerPlay price.
    // @param _trackSig listened track signature
    // @param _licenseSig signature of license where track will be registered
    // @param _price per play price of this track
    function registerTrack(bytes32 _trackSig, bytes32 _licenseSig, uint256 _price) onlyOwner {
        licenses[_licenseSig].trackPrice[_trackSig] = _price;
        trackLicense[_trackSig] = _licenseSig;
    }
    
    // Changes track price on license assigned to this track.
    // @param _trackSig listened track signature
    // @param _price new price
    function updateTrackPrice(bytes32 _trackSig, uint256 _price) onlyOwner {
        licenses[trackLicense[_trackSig]].trackPrice[_trackSig] = _price;
    }
    
    
    // Creates an empty license with no token contract assigned
    // @param _licenseSig new license signature
    function createLicense(bytes32 _licenseSig) onlyOwner {
        licenses[_licenseSig].licenseSig = _licenseSig;
    }
    
    // Creates a new license with assigned SoundToken contract
    // default token params + license signature
    function createLicense(bytes32 _licenseSig, uint256 _initialSupply, string _name, string _symbol, int _decimals) onlyOwner returns (address _assignedToken) {
        licenses[_licenseSig].licenseSig = _licenseSig;
        licenses[_licenseSig].assignedToken = createTrackToken(_initialSupply, _name, _symbol, _decimals);
    }
    
    // Returns signature of given track
    // @param _trackSig given track signature
    function getTrackLicense(bytes32 _trackSig) constant returns (bytes32 _license){
        return trackLicense[_trackSig];
    }
    
    // Returns current PerPlay price of given track.
    // @param _trackSig given track signature
    function getTrackPrice(bytes32 _trackSig) constant returns (uint256 _price){
        return licenses[trackLicense[_trackSig]].trackPrice[_trackSig];
    }
}
