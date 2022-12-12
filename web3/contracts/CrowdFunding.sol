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
        uint256 amount = msg.value;
        Campaign storage campaign = campaigns[_id];
        require(campaign.deadline > block.timestamp, "Deadline has passed");
        require(msg.value > 0, "Donation must be greater than 0");

        campaign.amountCollected += msg.value;
        campaign.donators.push(msg.sender);
        campaign.donations.push(amount);
        
        (bool sent,) = payable(campaign.owner).call{value: msg.value}("");

        if(sent) {
            campaign.amountCollected = campaign.amountCollected + amount;
        }
    }

    function getDonators(uint256 _id) public view returns(address[] memory, uint256[] memory) {
        return (campaigns[_id].donators, campaigns[_id].donations);
    }

    function getCampaign() public view returns(Campaign[] memory) {
        Campaign[] memory campaign = new Campaign[](numCampaigns);
        for(uint256 i = 0; i < numCampaigns; i++) {
            Campaign storage c = campaigns[i];
            campaign[i] = c;
        }
        return campaign;
    }


    constructor() {}
}