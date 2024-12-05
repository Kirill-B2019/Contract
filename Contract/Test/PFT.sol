// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ProjectsFundTokenB {
    string public name = "Projects Fund Token";
    string public symbol = "PFTb";
    uint8 public decimals = 6;
    uint256 public totalSupply = 6626070150 * (10 ** uint256(decimals));

    string public logoURI; // To store the logo URL
    uint256 public tokenPrice; // Token price in TRX

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public owner; // To manage ownership

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event LogoUpdated(string logoURI);
    event TokenPriceUpdated(uint256 newPrice);

    constructor() {
        owner = msg.sender; // Set the deployer as the contract owner
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    function transfer(address to, uint256 value) public returns (bool success) {
        require(to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;

        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool success) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        require(to != address(0), "Invalid address");
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Allowance exceeded");

        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;

        emit Transfer(from, to, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        allowance[msg.sender][spender] += addedValue;
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = allowance[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "Decreased allowance below zero");

        allowance[msg.sender][spender] = currentAllowance - subtractedValue;
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }

    // Function to update the logo URI
    function updateLogo(string memory _logoURI) public onlyOwner {
        logoURI = _logoURI;
        emit LogoUpdated(logoURI);
    }

    // Function to set the token price
    function setTokenPrice(uint256 _tokenPrice) public onlyOwner {
        tokenPrice = _tokenPrice;
        emit TokenPriceUpdated(tokenPrice);
    }

    // Function to retrieve the token price
    function getTokenPrice() public view returns (uint256) {
        return tokenPrice;
    }
}
