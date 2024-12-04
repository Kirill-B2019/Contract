// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface ITRC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract PFTWithPrice is ITRC20 {
    string public name = "Projects Fund Token Price";
    string public symbol = "PFTp";
    uint8 public decimals = 6;
    uint256 public override totalSupply = 6626070150000000;

    address public owner;
    mapping(address => uint256) private _balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    uint256 public currentXAUTPrice;
    uint256 public distributedTokens;

    constructor() {
        owner = msg.sender;
        _balanceOf[owner] = totalSupply;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balanceOf[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(amount > 0, "Amount must be greater than zero");
        require(_balanceOf[msg.sender] >= amount, "Insufficient balance");

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(allowance[sender][msg.sender] >= amount, "Allowance exceeded");
        require(_balanceOf[sender] >= amount, "Insufficient balance");

        _transfer(sender, recipient, amount);
        allowance[sender][msg.sender] -= amount;
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0), "Transfer to the zero address");
        require(_balanceOf[from] >= value, "Insufficient balance");

        _balanceOf[from] -= value;
        _balanceOf[to] += value;

        emit Transfer(from, to, value);
    }

    function updateXAUTPrice(uint256 _newPrice) public onlyOwner {
       currentXAUTPrice = _newPrice;
    }

    function getTokenPrice() public view returns (uint256) {
        require(currentXAUTPrice > 0, "XAUT price is not set");

        uint256 pricePerGram = (currentXAUTPrice * 1e6) / 28349523125;
        uint256 basePrice = pricePerGram / 100;
        return basePrice;
    }

    function distributeTokens(address recipient, uint256 amount) public onlyOwner {
        require(amount > 0, "Amount must be greater than zero");
        require(_balanceOf[owner] >= amount, "Not enough tokens");

        distributedTokens += amount;
        _balanceOf[owner] -= amount;
        _balanceOf[recipient] += amount;

        emit Transfer(owner, recipient, amount);
    }

}