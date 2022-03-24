// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.8.21;

contract ElectiveSystem {
    address public chairman;

    struct Voter {
        uint weight;  // 权重
        address trustee; // 被委托者
        bool voted; // 是否投票
        uint ballotIdex; // 投票提案
    }

    struct Proposal {
        bytes32 Name;
        uint ticketNum;
    }

    Proposal[] public proposals;
    mapping(address=>Voter) public voters;

    constructor(bytes32[] memory _proposalNames){
        chairman = msg.sender;
        voters[msg.sender].weight = 1;
        for (uint i; i< _proposalNames.length; i++){
            proposals.push(Proposal({
                Name: _proposalNames[i],
                ticketNum: 0
                }));
        }
    }

    function giveAddressVote(address _to) public {
        require(msg.sender == chairman, "The caller is not the chairperson");
        require(!voters[_to].voted, "to vote");
        require(voters[_to].weight == 0, "authorized");
        voters[_to].weight = 1;
    }


    function entrust(address _to) public {
        // 1、被委托者不能是自己
        require(msg.sender != _to, "The entrusted person is himself");
        // 2、被委托者不能出现循环，被委托者是否有被委托，被委托方是不是自己
        while (voters[_to].trustee != address(0)){
            require(voters[_to].trustee != msg.sender,"Delegated closed loop");
        }
        // 3、自己是否已投票
        require(!voters[msg.sender].voted, "caller has voted");

        // 4、自己是否有票数
        require(voters[msg.sender].weight != 0, "The caller does not have voting rights");

        // 5、被委托方地址不能为 0
        require(_to != address(0), "The entrusted address is illegal");

        voters[msg.sender].trustee = _to;

        voters[msg.sender].weight = 0;
        voters[msg.sender].voted = true;

        if (voters[_to].voted){
            proposals[voters[_to].ballotIdex].ticketNum += 1;
        } else {
            voters[_to].weight += 1;
        }
    }

    function votiing(uint _proposalIdex) public {
        // 是否已投票
        require(!voters[msg.sender].voted, "caller has voted");
        // 票数是否为0
        require(voters[msg.sender].weight != 0, "The caller does not have voting rights");
        proposals[_proposalIdex].ticketNum += voters[msg.sender].weight;
        voters[msg.sender].weight = 0;
        voters[msg.sender].voted = true;
        voters[msg.sender].ballotIdex = _proposalIdex;
    }

    function getWinnerProposal() public view returns(bytes32 name, uint num){
        name = bytes32(0);
        num = 0;
        for (uint i; i < proposals.length; i++){
            if(proposals[i].ticketNum > num){
                num = proposals[i].ticketNum;
                name = proposals[i].Name;
            }
        }
    }

}


