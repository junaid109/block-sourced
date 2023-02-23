// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract CrowdFunding {
    struct Funder {
        address addr;
        uint amount;
    }

    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 goal;
        uint256 deadline;
        uint256 amountCollected;
        string image;
        address[] donators;
        uint256[] donations; 
    }
    
    mapping(uint256 => Campaign) public campaigns;
    uint256 public numCampaigns = 0;

    function createCampaign(address _owner, 
    string memory _title, 
    string memory _description, 
    uint256 _goal, 
    uint256 _deadline, 
    string memory _image) 
    public returns(uint256){
        Campaign memory newCampaign = Campaign(_owner, _title, _description, _goal, _deadline, 0, _image, new address[](0), new uint256[](0));

        require(newCampaign.deadline > block.timestamp, "Deadline must be in the future");

        newCampaign.owner = _owner;
        newCampaign.title = _title;
        newCampaign.description = _description;
        newCampaign.goal = _goal;
        newCampaign.deadline = _deadline;
        newCampaign.image = _image;

        campaigns[numCampaigns] = newCampaign;
        numCampaigns++;

        return numCampaigns;
    }
    

  function donateToCampaign(uint256 _id) public payable {
        require(campaigns[_id].deadline > block.timestamp, "Deadline has passed");
        require(msg.value > 0, "Donation must be greater than 0");

        campaigns[_id].amountCollected += msg.value;
        campaigns[_id].donators.push(msg.sender);
        campaigns[_id].donations.push(msg.value);
        
        (bool sent,) = payable(campaigns[_id].owner).call{value: msg.value}("");

        if(sent) {
            campaigns[_id].amountCollected += msg.value;
        }
    }

    function getDonators(uint256 _id) public view returns(address[] memory, uint256[] memory) {
        return (campaigns[_id].donators, campaigns[_id].donations);
    }

    function getCampaign() public view returns(Campaign[] memory) {
        // require that there are more than 0 campaigns
        require(numCampaigns > 0, "No Campaigns Available");
        // create a new array to store the campaigns
        Campaign[] memory campaign = new Campaign[](numCampaigns);
        // loop through all the campaigns and return the campaign
        for(uint256 i = 0; i < numCampaigns; i++) {
            Campaign storage c = campaigns[i];
            campaign[i] = c;
        }
        return campaign;
    }


    constructor() {}
}