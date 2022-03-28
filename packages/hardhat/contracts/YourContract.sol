pragma solidity ^0.8.0;

// import "./abstractions/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


// Interface for checking the address that owns an ERC721
interface IERC721 {
    function owner() external returns (address owner);

    function ownerOf(uint256 tokenId) external returns (address owner);
}

contract YourContract {
    using SafeMath for uint256;

    struct Project {
        mapping(address => bool) owners;
        address nftContract;
        string name;
        uint256 projectId;
        uint256 numberOfLeaderboards;
    }

    struct MemberRow{
        uint256 numberOfVotes;
        address[] voters; // may have 0x addresses, which indicates a changed/deleted vote
        mapping(address => uint256) addressToIndex;
        // mapping(address => bool) voterToHasVoted;
    }

    struct Leaderboard {
        string name;
        uint256 projectId;
        uint256 leaderBoardId;
        uint256 leaderboardCount; // How many leaderboards have been archived
        uint256 epoch; // Days?
        uint256 blockStart;
        uint256 blockEnd;
        bool nftRequired;
        uint256 numberOfNftsRequired;
        address[] members; // Addresses that have received votes (used to iterate), make sure to not have duplicates
        address[] voters;
        mapping(address => MemberRow) rows;
        mapping(address => bool) voterToHasVoted;
    }

    uint256 public projectCount = 0;
    uint256[] public projectIds;
    mapping(uint256 => Project) public projectIdToProject; 
    // mapping(uint256 => Leaderboard[]) public projectIdToLeaderboards;
    mapping(uint256 => mapping(uint256 => Leaderboard)) public projectIdToLeaderboardIdToLeaderboard;
    mapping(uint256 => mapping(uint256 => Leaderboard[])) public leaderboardArchive;

    function getLeaderboard(uint256 _projectId, uint256 _leaderboardId) 
        external 
        view
        returns (
            string memory,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            bool,
            uint256
        ) 
    {
        Leaderboard storage leaderboard = projectIdToLeaderboardIdToLeaderboard[_projectId][_leaderboardId];
        return (
            leaderboard.name,
            leaderboard.projectId,
            leaderboard.leaderBoardId,
            leaderboard.leaderboardCount,
            leaderboard.epoch,
            leaderboard.blockStart,
            leaderboard.blockEnd,
            leaderboard.nftRequired,
            leaderboard.numberOfNftsRequired
        );
    }

    function getProjectName(uint256 _projectId) external view returns (string memory) {
        return projectIdToProject[_projectId].name;
    }

    function getProjectLeaderboardCount(uint256 _projectId) external view returns (uint256) {
        return projectIdToProject[_projectId].numberOfLeaderboards;
    }

    function getProjectCount() external view returns (uint256) {
        return projectCount;
    }
    
    function registerProject(address _nftContract, string memory _name) public {
        // Verify that the person calling function is owner of NFT contract
        // address nftContractOwner = IERC721(_nftContract).owner(); // REMOVE FOR TESTING
        // require(nftContractOwner == msg.sender, "You do not own this NFT contract."); // REMOVE FOR TESTING

        // Create new project and add it to mapping
        Project storage newProject = projectIdToProject[projectCount];
        newProject.owners[msg.sender] = true;
        newProject.nftContract = _nftContract;
        newProject.name = _name;
        newProject.projectId = projectCount;
        newProject.numberOfLeaderboards = 0;

        projectCount = projectCount.add(1);
    }

    function addOwnerToProject(uint256 _projectId, address _newOwner) public {
        require(projectIdToProject[_projectId].owners[msg.sender] == true, "You are not an owner of this project.");
        projectIdToProject[_projectId].owners[_newOwner] = true;
    }

    function createLeaderboardNftRequired(uint256 _projectId, string memory _leaderboardName, uint256 _time, uint256 _nftsRequired) public {
        require(projectIdToProject[_projectId].owners[msg.sender] == true, "You are not an owner of this project.");

        Leaderboard storage newLeaderboard = projectIdToLeaderboardIdToLeaderboard[_projectId][projectIdToProject[_projectId].numberOfLeaderboards];
        newLeaderboard.name = _leaderboardName;
        newLeaderboard.projectId = _projectId;
        newLeaderboard.leaderBoardId = projectIdToProject[_projectId].numberOfLeaderboards;
        newLeaderboard.leaderboardCount = 0;
        newLeaderboard.epoch = _time;
        newLeaderboard.blockStart = block.number;
        newLeaderboard.blockEnd = block.number + _time;
        newLeaderboard.nftRequired = true;
        newLeaderboard.numberOfNftsRequired = _nftsRequired;

        projectIdToProject[_projectId].numberOfLeaderboards = projectIdToProject[_projectId].numberOfLeaderboards.add(1);
    }

    function createLeaderboardOpen(uint256 _projectId, string memory _leaderboardName, uint256 _time) public {
        require(projectIdToProject[_projectId].owners[msg.sender] == true, "You are not an owner of this project.");

        Leaderboard storage newLeaderboard = projectIdToLeaderboardIdToLeaderboard[_projectId][projectIdToProject[_projectId].numberOfLeaderboards];
        newLeaderboard.name = _leaderboardName;
        newLeaderboard.projectId = _projectId;
        newLeaderboard.leaderBoardId = projectIdToProject[_projectId].numberOfLeaderboards;
        newLeaderboard.leaderboardCount = 0;
        newLeaderboard.epoch = _time;
        newLeaderboard.blockStart = block.number;
        newLeaderboard.blockEnd = block.number + _time;
        newLeaderboard.nftRequired = false;

        projectIdToProject[_projectId].numberOfLeaderboards = projectIdToProject[_projectId].numberOfLeaderboards.add(1);
    }

    function archiveAndResetLeaderboard(uint256 _projectId, uint256 _leaderboardId) internal {
        Leaderboard storage leaderboardArchived = leaderboardArchive[_projectId][_leaderboardId][projectIdToLeaderboardIdToLeaderboard[_projectId][_leaderboardId].leaderboardCount];
        leaderboardArchived = projectIdToLeaderboardIdToLeaderboard[_projectId][_leaderboardId];
        // leaderboardArchive[_projectId][_leaderboardId][projectIdToLeaderboardIdToLeaderboard[_projectId][_leaderboardId].leaderboardCount] = projectIdToLeaderboardIdToLeaderboard[_projectId][_leaderboardId];

        Leaderboard storage leaderboardNew = projectIdToLeaderboardIdToLeaderboard[_projectId][_leaderboardId];
        leaderboardNew.leaderboardCount = leaderboardNew.leaderboardCount.add(1);
        leaderboardNew.blockStart = block.number;
        leaderboardNew.blockEnd = block.number + leaderboardNew.epoch;
        delete leaderboardNew.members;
        
        // Need to iterate through both mappings and reset each entry
        address[] memory members = projectIdToLeaderboardIdToLeaderboard[_projectId][_leaderboardId].members;
        for (uint256 i = 0; i < members.length; i++) {
            delete projectIdToLeaderboardIdToLeaderboard[_projectId][_leaderboardId].rows[members[i]];
            // If delete does not properly erase addressToIndex mapping, will need to use loop below, need to test
            /* address[] memory rowVoters = projectIdToLeaderboardIdToLeaderboard[_projectId][_leaderboardId].rows[members[i]].voters;
            for (uint256 j = 0; j < rowVoters.length; j++) {
                projectIdToLeaderboardIdToLeaderboard[_projectId][_leaderboardId].rows[members[i]].addressToIndex[rowVoters[j]] = 0;
            } */
        }
        address[] memory voters = projectIdToLeaderboardIdToLeaderboard[_projectId][_leaderboardId].voters;
        for (uint256 i = 0; i < voters.length; i++) {
            projectIdToLeaderboardIdToLeaderboard[_projectId][_leaderboardId].voterToHasVoted[voters[i]] = false;
        }

    }

    function castVote(uint256 _projectId, uint256 _leaderboardId, address _member, uint256 _nftTokenId) public {
        require(projectIdToLeaderboardIdToLeaderboard[_projectId][_leaderboardId].epoch != 0, "This leaderboard does not exist.");

        // address nftOwner = IERC721(projectIdToProject[_projectId].nftContract).ownerOf(_nftTokenId); // REMOVE FOR TESTING
        // require(nftOwner == msg.sender, "You do not own the NFT based on the token ID provided."); // REMOVE FOR TESTING

        if (projectIdToLeaderboardIdToLeaderboard[_projectId][_leaderboardId].blockEnd <= block.number) {
            archiveAndResetLeaderboard(_projectId, _leaderboardId);
        }

        require(projectIdToLeaderboardIdToLeaderboard[_projectId][_leaderboardId].voterToHasVoted[msg.sender] == false, "You have already voted on this leaderboard.");

        projectIdToLeaderboardIdToLeaderboard[_projectId][_leaderboardId].voterToHasVoted[msg.sender] = true;
        projectIdToLeaderboardIdToLeaderboard[_projectId][_leaderboardId].voters.push(msg.sender);

        MemberRow storage member = projectIdToLeaderboardIdToLeaderboard[_projectId][_leaderboardId].rows[_member];
        member.addressToIndex[msg.sender] = member.voters.length; // is there better way than using voters.length?
        member.voters.push(msg.sender);
        member.numberOfVotes = member.numberOfVotes.add(1);

        if (member.numberOfVotes == 0) {
            projectIdToLeaderboardIdToLeaderboard[_projectId][_leaderboardId].members.push(_member);
        }
    }

    function changeVote(uint256 _projectId, uint256 _leaderboardId, address _member, address _newMember) public {
        require(projectIdToLeaderboardIdToLeaderboard[_projectId][_leaderboardId].voterToHasVoted[msg.sender] == true, "You have not voted on this leaderboard.");
        require(_member != _newMember, "Cannot change vote to the same member.");

        MemberRow storage member = projectIdToLeaderboardIdToLeaderboard[_projectId][_leaderboardId].rows[_member];
        /*
        for (uint256 i = 0; i < member.voters.length; i++) {
            if (member.voters[i] == msg.sender) {
                delete member.voters[i];
                break;
            }
        }
        */
        delete member.voters[member.addressToIndex[msg.sender]];
        delete member.addressToIndex[msg.sender];
        member.numberOfVotes = member.numberOfVotes.sub(1);

        MemberRow storage newMember = projectIdToLeaderboardIdToLeaderboard[_projectId][_leaderboardId].rows[_newMember];
        newMember.voters.push(msg.sender);
        newMember.numberOfVotes = member.numberOfVotes.add(1);

        if (newMember.numberOfVotes == 0) {
            projectIdToLeaderboardIdToLeaderboard[_projectId][_leaderboardId].members.push(_newMember);
        }
    }
}